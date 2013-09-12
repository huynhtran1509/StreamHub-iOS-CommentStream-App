//
//  LFViewController.m
//  CommentStream
//
//  Created by Eugene Scherba on 8/7/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import <StreamHub-iOS-SDK/LFSClient.h>
#import <DTCoreText/DTImageTextAttachment.h>
#import <DTCoreText/DTLinkButton.h>
#import <AFNetworking/AFImageRequestOperation.h>

#import "LFSConfig.h"
#import "DTLazyImageView+TextContentView.h"
#import "LFSAttributedTextCell.h"
#import "LFSViewController.h"

@interface LFSViewController () <DTAttributedTextContentViewDelegate, DTLazyImageViewDelegate>
@property (nonatomic, strong) NSMutableDictionary *authors;
@property (nonatomic, strong) NSMutableArray *content;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic, readonly) LFSBootstrapClient *bootstrapClient;
@property (strong, nonatomic, readonly) LFSStreamClient *streamClient;

@property (strong, nonatomic, readonly) NSDictionary *collectionInfo;
- (BOOL)canReuseCells;
@end

// identifier for cell reuse
NSString * const AttributedTextCellReuseIdentifier = @"AttributedTextCellReuseIdentifier";

@implementation LFSViewController
{
    BOOL     _useStaticRowHeight;
    NSCache* _cellCache;
}

#pragma mark - Properties
@synthesize authors = _authors;
@synthesize content = _content;
@synthesize bootstrapClient = _bootstrapClient;
@synthesize streamClient = _streamClient;
@synthesize dateFormatter = _dateFormatter;
@synthesize collectionInfo = _collectionInfo;

- (LFSBootstrapClient*)bootstrapClient
{
    if (_bootstrapClient == nil) {
        _bootstrapClient = [LFSBootstrapClient
                            clientWithNetwork:[_collectionInfo objectForKey:@"network"]
                            environment:[_collectionInfo objectForKey:@"environment"] ];
    }
    return _bootstrapClient;
}

- (LFSStreamClient*)streamClient
{
    // return StreamClient while also setting it's callback in case
    // StreamClient needs to be initialized
    if (_streamClient == nil) {
        _streamClient = [LFSStreamClient
                         clientWithNetwork:[_collectionInfo objectForKey:@"network"]
                         environment:[_collectionInfo objectForKey:@"environment"]];
        
        __weak typeof(self) weakSelf = self;
        [self.streamClient setResultHandler:^(id responseObject) {
            //NSLog(@"%@", responseObject);
            [weakSelf addTopLevelContent:[[responseObject objectForKey:@"states"] allValues]
                             withAuthors:[responseObject objectForKey:@"authors"]];
            
        } success:nil failure:nil];
    }
    return _streamClient;
}

#pragma mark - Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // set which collection to show content for...
    LFSConfig *config = [[LFSConfig alloc] initWithPlist:@"LFSConfig"];
    _collectionInfo = [[config collections] objectAtIndex:0u];
    
    _authors = [NSMutableDictionary dictionary];
    _content = [NSMutableArray array];
    
    _useStaticRowHeight = NO;
    
    /*
     if you enable static row height in this demo then the cell height is determined from the tableView.rowHeight.
     Cells can be reused in this mode.
     If you disable this then cells are prepared and cached to reused their internal layouter and layoutFrame.
     Reuse is not recommended since the cells are cached anyway.
     */
    
    if (_useStaticRowHeight) {
        self.tableView.rowHeight = 60.0f;
    }
    else {
        // establish a cache for prepared cells because heightForRowAtIndexPath and cellForRowAtIndexPath
        // both need the same cell for an index path
        _cellCache = [[NSCache alloc] init];
    }
    
    // Hide Status Bar
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        // iOS 7
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    } else {
        // iOS 6
        [[UIApplication sharedApplication] setStatusBarHidden:YES
                                                withAnimation:UIStatusBarAnimationSlide];
    }
    
    // set system cache for URL data to 5MB
    [[NSURLCache sharedURLCache] setMemoryCapacity:1024*1024*5];
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getBootstrapInfo];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    _cellCache = nil;
}

- (void) dealloc
{
    _authors = nil;
    _content = nil;
    _cellCache = nil;
}


#pragma mark - UIViewController

// Hide Status Bar
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - Private methods

- (void)getBootstrapInfo
{
    [self.bootstrapClient getInitForSite:[_collectionInfo objectForKey:@"site"]
                                 article:[_collectionInfo objectForKey:@"article"]
                               onSuccess:^(NSOperation *operation, id responseObject)
     {
         NSDictionary *headDocument = [responseObject objectForKey:@"headDocument"];
         [self addTopLevelContent:[headDocument objectForKey:@"content"]
                      withAuthors:[headDocument objectForKey:@"authors"]];
         NSDictionary *collectionSettings = [responseObject objectForKey:@"collectionSettings"];
         NSString *collectionId = [collectionSettings objectForKey:@"collectionId"];
         NSNumber *eventId = [collectionSettings objectForKey:@"event"];
         
         //NSLog(@"%@", responseObject);
         
         // we are already on the main queue...
         [self.streamClient setCollectionId:collectionId];
         [self.streamClient startStreamWithEventId:eventId];
     }
                               onFailure:^(NSOperation *operation, NSError *error)
     {
         NSLog(@"Error code %d, with description %@", error.code, [error localizedDescription]);
     }];
}

-(void)addTopLevelContent:(NSArray*)content withAuthors:(NSDictionary*)authors
{
    // This method is responsible for both adding content from Bootstrap and
    // for streaming new updates.
    [self.authors addEntriesFromDictionary:authors];
    
    NSPredicate *p = [NSPredicate predicateWithFormat:@"vis == 1"];
    NSArray *filteredContent = [content filteredArrayUsingPredicate:p];
    NSRange contentSpan;
    contentSpan.location = 0;
    contentSpan.length = [filteredContent count];
    [self.content insertObjects:filteredContent
                      atIndexes:[NSIndexSet indexSetWithIndexesInRange:contentSpan]];
    
    // also cause table to redraw
    if ([filteredContent count] == 1u) {
        // animate insertion
        [_tableView beginUpdates];
        [_tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:
                                            [NSIndexPath indexPathForRow:0 inSection:0]]
                          withRowAnimation:UITableViewRowAnimationNone];
        [_tableView endUpdates];
    }
    
    [_tableView reloadData];
}

#pragma mark - UITableViewControllerDelegate

// disable this method to get static height = better performance
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_useStaticRowHeight) {
        return tableView.rowHeight;
    }
    
    LFSAttributedTextCell *cell = (LFSAttributedTextCell *)[self tableView:tableView
                                                     cellForRowAtIndexPath:indexPath];
    return [cell requiredRowHeightInTableView:tableView];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.content count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // uniquing of NSIndexPath objects was disabled in iOS5, so use a string
    // key as a workaround
    NSString *key = [NSString stringWithFormat:@"%d-%d", indexPath.section, indexPath.row];
    LFSAttributedTextCell *cell = [_cellCache objectForKey:key];

    if (!cell) {
        if ([self canReuseCells]) {
            cell = (LFSAttributedTextCell *)[tableView dequeueReusableCellWithIdentifier:AttributedTextCellReuseIdentifier];
        }
        if (!cell) {
            cell = [[LFSAttributedTextCell alloc] initWithReuseIdentifier:AttributedTextCellReuseIdentifier];
        }
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        [cell.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [cell.noteView setTextAlignment:NSTextAlignmentRight];
        
        [cell setHasFixedRowHeight:_useStaticRowHeight];
        
        // cache it, if there is a cache
        [_cellCache setObject:cell forKey:key];
        
        // LFAttributedTextCell specifics
        cell.attributedTextContextView.shouldDrawImages = NO;
        cell.attributedTextContextView.delegate = self;
        
        // iOS7-like selected background color
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
        UIView *selectionColor = [[UIView alloc] init];
        selectionColor.backgroundColor = [UIColor colorWithRed:(217/255.0) green:(217/255.0) blue:(217/255.0) alpha:1];
        cell.selectedBackgroundView = selectionColor;
    }
    
    [self configureCell:cell forIndexPath:indexPath];
    return cell;
}

#pragma mark - Table and cell helpers

- (BOOL)canReuseCells
{
    // reuse does not work for variable height -- only reuse cells with fixed height
    return (![self respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)]);
}

- (void)setImage:(UIImage*)image forCell:(LFSAttributedTextCell*)cell
{
    // scale down image if we are not on a Retina device
    UIScreen *screen = [UIScreen mainScreen];
    if ([screen respondsToSelector:@selector(scale)] && [screen scale] == 2) {
        // we are on a Retina device
        cell.imageView.image = image;
        [cell setNeedsLayout];
    }
    else {
        // we are on a non-Retina device
        dispatch_queue_t queue =
        dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
            
            // scale image on a background thread
            // Note: to keep things simple, we do not worry about aspect ratio
            CGSize size = cell.imageView.frame.size;
            UIGraphicsBeginImageContext(size);
            [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
            UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            // display image on the main thread
            dispatch_sync(dispatch_get_main_queue(), ^{
                cell.imageView.image = scaledImage;
                [cell setNeedsLayout];
            });
        });
    }
}

// called every time a cell is configured
- (void)configureCell:(LFSAttributedTextCell *)cell forIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *content = [[_content objectAtIndex:indexPath.row] objectForKey:@"content"];
    NSDictionary *author = [_authors objectForKey:[content objectForKey:@"authorId"]];
    NSTimeInterval timeStamp = [[content objectForKey:@"createdAt"] doubleValue];
    
    NSString *authorName = [author objectForKey:@"displayName"];
    NSString *avatarURL = [author objectForKey:@"avatar"];
    NSString *bodyHTML = [content objectForKey:@"bodyHtml"];
    
    cell.titleView.text = authorName;
    NSString *dateTime = [self.dateFormatter
                          relativeStringFromDate:
                          [NSDate dateWithTimeIntervalSince1970:timeStamp]];
    cell.noteView.text = dateTime;
    
    // load avatar images in a separate queue
    NSURLRequest *request =
    [NSURLRequest requestWithURL:[NSURL URLWithString:avatarURL]];
    AFImageRequestOperation* operation = [AFImageRequestOperation
                                          imageRequestOperationWithRequest:request
                                          imageProcessingBlock:nil
                                          success: ^(NSURLRequest *req,
                                                     NSHTTPURLResponse *response,
                                                     UIImage *image)
                                          {
                                              [self setImage:image forCell:cell];
                                          }
                                          failure:nil];
    [operation start];
    
    // To test embedded images:
    //NSString *html = [NSString stringWithFormat:@"<img src=\"%@\"/><div style=\"font-family:Avenir\">%@</div>",
    // avatarURL, bodyHTML];
    NSString *html = [NSString stringWithFormat:@"<div style=\"font-family:Avenir\">%@</div>", bodyHTML];
    
    [cell setHTMLString:html];
}

#pragma mark - DTAttributedTextContentViewDelegate
-(UIView*)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView
                        viewForLink:(NSURL *)url
                         identifier:(NSString *)identifier
                              frame:(CGRect)frame
{
    DTLinkButton *btn = [[DTLinkButton alloc] initWithFrame:frame];
    btn.URL = url;
    [btn addTarget:self action:@selector(btnDidClick:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

-(UIView*)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView
                  viewForAttachment:(DTTextAttachment *)attachment frame:(CGRect)frame
{
    if ([attachment isKindOfClass:[DTImageTextAttachment class]]) {
        
        DTLazyImageView *imageView = [[DTLazyImageView alloc] initWithFrame:frame];
        imageView.textContentView = attributedTextContentView;
        imageView.delegate = self;
        
        // defer loading of image under given URL
        imageView.url = attachment.contentURL;
        return imageView;
    }
    return nil;
}

// allow display of images embedded in rich-text content
-(void)lazyImageView:(DTLazyImageView *)lazyImageView didChangeImageSize:(CGSize)size
{
    DTAttributedTextContentView *cv = lazyImageView.textContentView;
    NSURL *url = lazyImageView.url;
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"contentURL == %@", url];
    // update all attachments that match this URL (possibly multiple images with same size)
    for (DTTextAttachment *attachment in [cv.layoutFrame textAttachmentsWithPredicate:pred])
    {
        /*
         attachment.originalSize = imageSize;
         if (!CGSizeEqualToSize(imageSize, attachment.displaySize)) {
         attachment.displaySize = imageSize;
         }*/
        attachment.originalSize = size;
        lazyImageView.bounds = CGRectMake(0, 0, attachment.displaySize.width, attachment.displaySize.height);
    }
    
    // need to reset the layouter because otherwise we get the old framesetter or cached layout frames
    // see https://github.com/Cocoanetics/DTCoreText/issues/307
    cv.layouter = nil;
    
    // laying out the entire string,
    // might be more efficient to only layout the paragraphs that contain these attachments
    [cv relayoutText];
}

/*
-(UIView*)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView
            viewForAttributedString:(NSAttributedString *)string frame:(CGRect)frame
{
    // initialize and return your view here
}
*/

#pragma mark - Events

- (IBAction)btnDidClick:(DTLinkButton*)sender
{
    [[UIApplication sharedApplication] openURL:sender.URL];
}

@end
