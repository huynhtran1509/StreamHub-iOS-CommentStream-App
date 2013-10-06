//
//  LFSCollectionViewController.m
//  CommentStream
//
//  Created by Eugene Scherba on 8/7/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//


#define CACHE_SCALED_IMAGES
#define LOG_ALL_HTTP_REQUESTS

#import <StreamHub-iOS-SDK/LFSClient.h>
#import <AFNetworking/AFImageRequestOperation.h>

#ifdef LOG_ALL_HTTP_REQUESTS
#import <AFHTTPRequestOperationLogger/AFHTTPRequestOperationLogger.h>
#endif

#import <objc/objc-runtime.h>

#import "LFSConfig.h"
#import "LFSAttributedTextCell.h"
#import "LFSCollectionViewController.h"
#import "LFSDetailViewController.h"
#import "LFSTextField.h"

#import "LFSContentCollection.h"

@interface LFSCollectionViewController ()
@property (nonatomic, strong) LFSMutableContentCollection *content;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, readonly) LFSBootstrapClient *bootstrapClient;
@property (nonatomic, readonly) LFSStreamClient *streamClient;
@property (nonatomic, readonly) LFSTextField *postCommentField;

// render iOS7 status bar methods to be readwrite properties
@property (nonatomic, assign) BOOL prefersStatusBarHidden;
@property (nonatomic, assign) UIStatusBarAnimation preferredStatusBarUpdateAnimation;

@property (nonatomic, strong) LFSPostViewController *postCommentViewController;

@end

// some module-level constants
static NSString* const kCellReuseIdentifier = @"LFSContentCell";
static NSString* const kCellSelectSegue = @"detailView";
const static char kContentCellHeightKey;

@implementation LFSCollectionViewController
{
    BOOL _haveRetinaDevice;
    
    // NSCache automatically disposes its content when the available RAM is running low
    NSCache* _cellCache;
    
#ifdef CACHE_SCALED_IMAGES
    NSCache* _imageCache;
#endif
    
    UIActivityIndicatorView *_activityIndicator;
    UIView *_container;
    CGPoint _scrollOffset;
}

#pragma mark - Properties
@synthesize content = _content;
@synthesize bootstrapClient = _bootstrapClient;
@synthesize streamClient = _streamClient;
@synthesize dateFormatter = _dateFormatter;
@synthesize postCommentField = _postCommentField;
@synthesize collection = _collection;
@synthesize collectionId = _collectionId;

// render iOS7 status bar methods as writable properties
@synthesize prefersStatusBarHidden = _prefersStatusBarHidden;
@synthesize preferredStatusBarUpdateAnimation = _preferredStatusBarUpdateAnimation;

@synthesize postCommentViewController = _postCommentViewController;

- (LFSBootstrapClient*)bootstrapClient
{
    if (_bootstrapClient == nil) {
        _bootstrapClient = [LFSBootstrapClient
                            clientWithNetwork:[_collection objectForKey:@"network"]
                            environment:[_collection objectForKey:@"environment"] ];
    }
    return _bootstrapClient;
}

- (LFSStreamClient*)streamClient
{
    // return StreamClient while also setting it's callback in case
    // StreamClient needs to be initialized
    if (_streamClient == nil) {
        _streamClient = [LFSStreamClient
                         clientWithNetwork:[_collection objectForKey:@"network"]
                         environment:[_collection objectForKey:@"environment"] ];
        
        __weak typeof(self) weakSelf = self;
        [self.streamClient setResultHandler:^(id responseObject) {
            //NSLog(@"%@", responseObject);
            [weakSelf addTopLevelContent:[[responseObject objectForKey:@"states"] allValues]
                             withAuthors:[responseObject objectForKey:@"authors"]];
            
        } success:nil failure:nil];
    }
    return _streamClient;
}

-(LFSPostViewController*)postCommentViewController
{
    // lazy-instantiate LFSPostViewController
    static NSString* const kLFSMainStoryboardId = @"Main";
    static NSString* const kLFSPostCommentViewControllerId = @"postComment";
    
    if (_postCommentViewController == nil) {
        UIStoryboard *storyboard = [UIStoryboard
                                    storyboardWithName:kLFSMainStoryboardId
                                    bundle:nil];
        _postCommentViewController =
        (LFSPostViewController*)[storyboard
                                 instantiateViewControllerWithIdentifier:
                                 kLFSPostCommentViewControllerId];
    }
    return _postCommentViewController;
}

#pragma mark - Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // see if we are on a Retina device
    UIScreen *screen = [UIScreen mainScreen];
    _haveRetinaDevice = [screen respondsToSelector:@selector(scale)] && [screen scale] == 2.f;

    _content = [[LFSMutableContentCollection alloc] init];
    
    self.title = [_collection objectForKey:@"_name"];
    
    // {{{ Navigation bar
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    [navigationBar setBarStyle:UIBarStyleDefault];
    
    if (LFS_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(LFSSystemVersion70)) {
        [navigationBar setBackgroundColor:[UIColor clearColor]];
        [navigationBar setTranslucent:YES];
    }
    // }}}
    
    // {{{ Toolbar
    
    _scrollOffset = CGPointMake(0.f, 0.f);
    
    // in landscape mode, toolbar height is 32, in portrait, it is 44
    CGFloat textFieldWidth =
    self.navigationController.navigationBar.frame.size.width -
    (LFS_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(LFSSystemVersion70) ? 32.f : 25.f);
    
    BOOL isPortrait = UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication]
                                                        statusBarOrientation]);
    _postCommentField = [[LFSTextField alloc]
                         initWithFrame:
                         CGRectMake(0.f, 0.f, textFieldWidth, (isPortrait ? 30.f : 18.f))];

    [_postCommentField setDelegate:self];
    [_postCommentField setPlaceholder:@"Write a comment…"];


    UIBarButtonItem *writeCommentItem = [[UIBarButtonItem alloc]
                                         initWithCustomView:_postCommentField];
    [self setToolbarItems:
     [NSArray arrayWithObjects:writeCommentItem, nil]];
    
    UIToolbar *toolbar = self.navigationController.toolbar;
    [toolbar setBackgroundColor:[UIColor clearColor]];
    [toolbar setBarStyle:UIBarStyleDefault];
    if (LFS_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(LFSSystemVersion70))
    {
        // iOS7
        [toolbar setBackgroundColor:[UIColor clearColor]];
        [toolbar setTranslucent:YES];
    }
    else
    {
        // iOS6
        [toolbar setBarStyle:UIBarStyleDefault];
        //[toolbar setTintColor:[UIColor lightGrayColor]];
    }
    _postCommentViewController = nil;
    // }}}
    
    /*
     if you enable static row height in this demo then the cell height 
     is determined from the tableView.rowHeight. Cells can be reused 
     in this mode. If you disable this then cells are prepared and cached
     to reused their internal layouter and layoutFrame. Reuse is not
     recommended since the cells are cached anyway.
     */
    
    // establish a cache for prepared cells because heightForRowAtIndexPath and
    // cellForRowAtIndexPath both need the same cell for an index path
    _cellCache = [[NSCache alloc] init];
    
#ifdef CACHE_SCALED_IMAGES
    _imageCache = [[NSCache alloc] init];
#endif
    
    // set system cache for URL data to 5MB
    [[NSURLCache sharedURLCache] setMemoryCapacity:1024*1024*5];
    
    _dateFormatter = [[NSDateFormatter alloc] init];
    
    [self wheelContainerSetup];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // hide status bar for iOS7 and later
    [self setStatusBarHidden:LFS_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(LFSSystemVersion70)
               withAnimation:UIStatusBarAnimationNone];
    
#ifdef LOG_ALL_HTTP_REQUESTS
    [[AFHTTPRequestOperationLogger sharedLogger] startLogging];
#endif
    
    [self startStreamWithBoostrap];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // add some pizzas by animating the toolbar from below (we want
    // to encourage users to post comments and this feature serves as
    // almost a call to action)
    [self.navigationController setToolbarHidden:NO animated:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    // hide the navigation controller here
    [super viewWillDisappear:animated];
    [self.streamClient stopStream];
    
#ifdef LOG_ALL_HTTP_REQUESTS
    [[AFHTTPRequestOperationLogger sharedLogger] stopLogging];
#endif
    
    [self.navigationController setToolbarHidden:YES animated:animated];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
#ifdef CACHE_SCALED_IMAGES
    [_imageCache removeAllObjects];
#endif
    [_cellCache removeAllObjects];
}

- (void) dealloc
{
    [self wheelContainerTeardown];
    self.navigationController.delegate = nil;
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;

    _postCommentField.delegate = nil;
    _postCommentField = nil;
    
#ifdef CACHE_SCALED_IMAGES
    [_imageCache removeAllObjects];
    _imageCache = nil;
#endif
    [_cellCache removeAllObjects];
    _cellCache = nil;
    
    _streamClient = nil;
    _bootstrapClient = nil;
    
    _content = nil;
    _container = nil;
    _activityIndicator = nil;
    _dateFormatter = nil;
}

#pragma mark - UIActivityIndicator
-(void)wheelContainerSetup
{
    _container = [[UIView alloc] initWithFrame:self.view.bounds];
    [_container setBackgroundColor:[UIColor whiteColor]]; // should be white by default...
    
    // set autoresizing to support landscape mode
    [_container setAutoresizingMask:(UIViewAutoresizingFlexibleWidth |
                                     UIViewAutoresizingFlexibleHeight)];
    
    // init actvity indicator
    _activityIndicator = [[UIActivityIndicatorView alloc]
                          initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _activityIndicator.hidesWhenStopped = YES; // we hide it manually anyway
    
    // center activity indicator
    [_activityIndicator setCenter:_container.center];
    
    // set autoresizing to support landscape mode
    [_activityIndicator setAutoresizingMask:(UIViewAutoresizingFlexibleBottomMargin |
                                             UIViewAutoresizingFlexibleLeftMargin |
                                             UIViewAutoresizingFlexibleRightMargin |
                                             UIViewAutoresizingFlexibleTopMargin)];
    
    [_container addSubview:_activityIndicator];
}

-(void)wheelContainerTeardown
{
    _activityIndicator = nil;
    _container = nil;
}

-(void)startSpinning
{
    [_container setFrame:self.view.bounds];
    [self.view addSubview:_container];
    _container.hidden = NO;
    _activityIndicator.hidden = NO;
    [_activityIndicator startAnimating];
}

-(void)stopSpinning
{
    [_activityIndicator stopAnimating];
    _activityIndicator.hidden = YES;
    _container.hidden = YES;
    [_container removeFromSuperview];
}

#pragma mark - Status bar

-(void)setStatusBarHidden:(BOOL)hidden
            withAnimation:(UIStatusBarAnimation)animation
{
    _prefersStatusBarHidden = hidden;
    _preferredStatusBarUpdateAnimation = animation;
    
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)])
    {
        // iOS 7
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
    else
    {
        // iOS 6
        [[UIApplication sharedApplication] setStatusBarHidden:hidden
                                                withAnimation:animation];
        if (self.navigationController) {
            UINavigationBar *navigationBar = self.navigationController.navigationBar;
            if (hidden && navigationBar.frame.origin.y > 0.f) {
                CGRect frame = navigationBar.frame;
                frame.origin.y = 0.f;
                navigationBar.frame = frame;
            } else if (!hidden && navigationBar.frame.origin.y < 20.f) {
                CGRect frame = navigationBar.frame;
                frame.origin.y = 20.f;
                navigationBar.frame = frame;
            }
        }
    }
}

#pragma mark - Toolbar behavior
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.navigationController
     setToolbarHidden:(scrollView.contentOffset.y <= _scrollOffset.y)
     animated:YES];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                 willDecelerate:(BOOL)decelerate
{
    _scrollOffset = scrollView.contentOffset;
}


#pragma mark - UITextFieldDelegate

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self createComment:textField];
    return NO;
}

#pragma mark - Private methods
- (void)startStreamWithBoostrap
{
    // If we have some data, do not clear it and do not run bootstrap.
    // Instead, grab the latest event ID and start streaming from there
    
    if (_content.count == 0u) {
        [_content removeAllObjects];
        
        [self startSpinning];
        [self.bootstrapClient getInitForSite:[self.collection objectForKey:@"siteId"]
                                     article:[self.collection objectForKey:@"articleId"]
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
             [self setCollectionId:collectionId];
             [self.streamClient setCollectionId:collectionId];
             [self.streamClient startStreamWithEventId:eventId];
             [self stopSpinning];
         }
                                   onFailure:^(NSOperation *operation, NSError *error)
         {
             NSLog(@"Error code %d, with description %@", error.code, [error localizedDescription]);
             [self stopSpinning];
         }];
    }
    else {
        NSNumber *eventId = [[_content objectAtIndex:0u] eventId];
        [self.streamClient setCollectionId:self.collectionId];
        [self.streamClient startStreamWithEventId:eventId];
    }
}

-(void)addTopLevelContent:(NSArray*)content withAuthors:(NSDictionary*)authors
{
    // This method is responsible for both adding content from Bootstrap and
    // for streaming new updates.
    [_content addAuthorsCollection:authors];

    // TODO: move filtering to model/collection object?
    NSPredicate *p = [NSPredicate predicateWithFormat:@"vis == 1 && type == 0"];
    NSArray *filteredContent = [content filteredArrayUsingPredicate:p];
    NSRange contentSpan;
    contentSpan.location = 0u;
    contentSpan.length = [filteredContent count];
    [_content addObjectsFromArray:filteredContent];
    
    // also cause table to redraw
    if ([filteredContent count] == 1u) {
        // animate insertion
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:
                                                [NSIndexPath indexPathForRow:0 inSection:0]]
                              withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
    }
    
    [self.tableView reloadData];
}

#pragma mark - UITableViewControllerDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [self performSegueWithIdentifier:kCellSelectSegue sender:cell];
}

// disable this method to get static height = better performance
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LFSContent *content = [_content objectAtIndex:indexPath.row];
    NSNumber *cellHeight = objc_getAssociatedObject(content, &kContentCellHeightKey);
    CGFloat cellHeightValue;
    
    if (cellHeight == nil) {
        cellHeightValue = [LFSAttributedTextCell
                           cellHeightForBoundsWidth:tableView.bounds.size.width
                           withHTMLString:content.contentBodyHtml];
        objc_setAssociatedObject(content, &kContentCellHeightKey,
                                 [NSNumber numberWithFloat:cellHeightValue],
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    } else {
        cellHeightValue = [cellHeight floatValue];
    }
    
    return cellHeightValue;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_content count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LFSAttributedTextCell *cell;

    LFSContent *content = [_content objectAtIndex:indexPath.row];
    
    const NSString* const key = content.idString;
    cell = [_cellCache objectForKey:key];
    //cell = (LFSAttributedTextCell *)[tableView dequeueReusableCellWithIdentifier:
    //                                 kCellReuseIdentifier];
    
    if (!cell) {
        cell = [[LFSAttributedTextCell alloc]
                initWithReuseIdentifier:kCellReuseIdentifier];
        
        // content-independent configuration
        [cell setDateFormatter:self.dateFormatter];
    }
    
    // cache the cell
    [_cellCache setObject:cell forKey:key];
    
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - Table and cell helpers

// called every time a cell is configured
- (void)configureCell:(LFSAttributedTextCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    LFSContent *content = [_content objectAtIndex:indexPath.row];
    
    [cell setHTMLString:content.contentBodyHtml];
    [cell setContentDate:content.contentCreatedAt];
    [cell setIndicatorIcon:content.contentSourceIconSmall];
    
    NSNumber *cellHeight = objc_getAssociatedObject(content, &kContentCellHeightKey);
    [cell setRequiredBodyHeight:[cellHeight floatValue]];
    
    // always set an object
    LFSAuthor *author = content.author;
    NSNumber *moderator = [content.contentAnnotations objectForKey:@"moderator"];
    BOOL hasModerator = (moderator != nil && [moderator boolValue]);
    [cell setProfileLocal:[[LFSHeader alloc]
                           initWithDetailString:(author.twitterHandle ? [@"@" stringByAppendingString:author.twitterHandle] : @"")
                           attributeString:(hasModerator ? @"Moderator" : @"")
                           mainString:author.displayName
                           iconImage:nil]];
    

#ifdef CACHE_SCALED_IMAGES
    NSString *authorId = author.idString;
    UIImage *scaledImage = [_imageCache objectForKey:authorId];
    if (scaledImage) {
        [_imageCache setObject:scaledImage forKey:authorId];
        [cell.imageView setImage:scaledImage];
    }
    else {
#endif
        // load avatar images in a separate queue
        NSURLRequest *request = [NSURLRequest requestWithURL:
                                 [NSURL URLWithString:author.avatarUrlString75]];
        AFImageRequestOperation* operation = [AFImageRequestOperation
                                              imageRequestOperationWithRequest:request
                                              imageProcessingBlock:nil
                                              success:^(NSURLRequest *req,
                                                        NSHTTPURLResponse *response,
                                                        UIImage *image)
                                              {
                                                  [content.author setAvatarImage:image];
                                                  [self scaleImage:image forContent:content];
                                              }
                                              failure:nil];
        [operation start];
#ifdef CACHE_SCALED_IMAGES
    }
#endif
}

- (void)scaleImage:(UIImage*)image forContent:(LFSContent*)content
{
    CGRect targetRect;
    targetRect.origin = CGPointZero;
    targetRect.size = kCellImageViewSize;
    
    const NSString* const contentId = content.idString;
#ifdef CACHE_SCALED_IMAGES
    const NSString* const authorId = content.author.idString;
#endif
    
    dispatch_queue_t queue =
    dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0.f);
    dispatch_async(queue, ^{
        
        // scale image on a background thread
        // Note: this will not preserve aspect ratio
        UIImage *scaledImage;
#ifdef CACHE_SCALED_IMAGES
        scaledImage = [_imageCache objectForKey:authorId];
        if (scaledImage == nil) {
#endif
            // don't call UIGraphicsBeginImageContext when supporting Retina,
            // instead call UIGraphicsBeginImageContextWithOptions with zero for scale
            UIGraphicsBeginImageContextWithOptions(kCellImageViewSize, YES, 0.f);
            [image drawInRect:targetRect];
            scaledImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
#ifdef CACHE_SCALED_IMAGES
        }
        [_imageCache setObject:scaledImage forKey:authorId];
#endif
        // display image on the main thread
        dispatch_sync(dispatch_get_main_queue(), ^{
            LFSAttributedTextCell *cell = [_cellCache objectForKey:contentId];
            [cell.imageView setImage:scaledImage];
            [cell setNeedsLayout];
        });
    });
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:kCellSelectSegue])
    {
        // Get reference to the destination view controller
        if ([segue.destinationViewController isKindOfClass:[LFSDetailViewController class]]) {
            if ([sender isKindOfClass:[UITableViewCell class]]) {
                LFSAttributedTextCell *cell = (LFSAttributedTextCell *)sender;
                NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
                LFSDetailViewController *vc = segue.destinationViewController;
                
                // assign model object(s)
                LFSContent *contentItem = [_content objectAtIndex:indexPath.row];
                [vc setContentItem:contentItem];
                [vc setAvatarImage:contentItem.author.avatarImage];
                [vc setCollection:self.collection];
                [vc setCollectionId:self.collectionId];
                [vc setHideStatusBar:self.prefersStatusBarHidden];
            }
        }
    }
}

#pragma mark - Events

-(IBAction)createComment:(id)sender
{
    // configure destination controller
    [self.postCommentViewController setCollection:self.collection];
    [self.postCommentViewController setCollectionId:self.collectionId];
    
    [self presentViewController:self.postCommentViewController animated:YES completion:nil];
}

@end
