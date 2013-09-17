//
//  LFSCollectionViewController.m
//  CommentStream
//
//  Created by Eugene Scherba on 8/7/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import <StreamHub-iOS-SDK/LFSClient.h>
#import <AFNetworking/AFImageRequestOperation.h>

#import "LFSConfig.h"
#import "LFSAttributedTextCell.h"
#import "LFSCollectionViewController.h"

@interface LFSPostField : UITextField
// a subclass of UITextField that allows us to set custom
// padding/edge insets.
@property (nonatomic, assign) UIEdgeInsets textEdgeInsets;
@end

@implementation LFSPostField
@synthesize textEdgeInsets = _textEdgeInsets;
- (CGRect)textRectForBounds:(CGRect)bounds {
	return UIEdgeInsetsInsetRect([super textRectForBounds:bounds], _textEdgeInsets);
}
@end

@interface LFSCollectionViewController () {
    __weak UITableView* _tableView;
    LFSNewCommentViewController *_viewControllerNewComment;
}
@property (nonatomic, strong) NSMutableDictionary *authors;
@property (nonatomic, strong) NSMutableArray *content;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, readonly) LFSBootstrapClient *bootstrapClient;
@property (nonatomic, readonly) LFSStreamClient *streamClient;
@property (nonatomic, readonly) LFSPostField *postCommentField;

// render iOS7 status bar methods to be readwrite properties
@property (nonatomic, assign) BOOL prefersStatusBarHidden;
@property (nonatomic, assign) UIStatusBarAnimation preferredStatusBarUpdateAnimation;

@property (nonatomic, strong) UIBarButtonItem *postCommentItem;
- (BOOL)canReuseCells;
@end

// identifier for cell reuse
static NSString* const kAttributedTextCellReuseIdentifier = @"AttributedTextCellReuseIdentifier";

@implementation LFSCollectionViewController
{
    NSCache* _cellCache;
    UIActivityIndicatorView *_activityIndicator;
    UIView *_container;
    CGPoint _scrollOffset;
}

#pragma mark - Properties
@synthesize authors = _authors;
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

@synthesize postCommentItem = _postCommentItem;

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
            NSLog(@"%@", responseObject);
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
    
    _authors = [NSMutableDictionary dictionary];
    _content = [NSMutableArray array];
    
    if (SYSTEM_VERSION_LESS_THAN(kSystemVersion70)) {
        // Under iOS 6, GSEventRunModal of GraphicsSerivces sends objc_release
        // to an already released (zombie) UITableView instance; the following
        // line is a work-around to that problem. TODO: Investigate
        // why this only happens when rendering table using DTCoreText attributed cells.
        _tableView = (__bridge id)CFBridgingRetain(self.tableView);
    }
    
    self.title = [_collection objectForKey:@"name"];
    
    // {{{ Navigation bar
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    [navigationBar setBarStyle:UIBarStyleDefault];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(kSystemVersion70)) {
        [navigationBar setBackgroundColor:[UIColor clearColor]];
        [navigationBar setTranslucent:YES];
    }
    // }}}
    
    // {{{ Toolbar
    
    _scrollOffset = CGPointMake(0.f, 0.f);
    
    CGRect rect = self.navigationController.navigationBar.frame;
    CGFloat recommendedTextFieldWidth = rect.size.width - 62.0f;
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (orientation == UIInterfaceOrientationLandscapeLeft ||
        orientation == UIInterfaceOrientationLandscapeRight)
    {
        // landscape (toolbar height is 32)
        _postCommentField = [[LFSPostField alloc]
                             initWithFrame:CGRectMake(0, 0, recommendedTextFieldWidth, 18)];
    }
    else
    {
        // portrait (toolbar height is 44)
        _postCommentField = [[LFSPostField alloc]
                             initWithFrame:CGRectMake(0, 0, recommendedTextFieldWidth, 30)];
    }
    
    [_postCommentField setDelegate:self];
    [_postCommentField setPlaceholder:@"Write a comment..."];
    [_postCommentField setFont:[UIFont systemFontOfSize:13.0f]];
    [_postCommentField setAutoresizingMask:(UIViewAutoresizingFlexibleHeight |
                                            UIViewAutoresizingFlexibleWidth)];
    
    _postCommentField.layer.masksToBounds = YES;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(kSystemVersion70)) {
        [_postCommentField setTextEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
        _postCommentField.layer.cornerRadius = 6.0f;
        _postCommentField.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        _postCommentField.layer.borderWidth = 0.5f;
        _postCommentField.layer.opacity = 0.0f;
        _postCommentField.layer.backgroundColor = [[UIColor whiteColor] CGColor];
    } else {
        [_postCommentField setTextEdgeInsets:UIEdgeInsetsMake(5, 8, 0, 0)];
        _postCommentField.layer.cornerRadius = 15.0f;
        _postCommentField.layer.opacity = 1.0f;
        _postCommentField.layer.backgroundColor = [[UIColor whiteColor] CGColor];
    }
    
    [self.navigationController.toolbar setBackgroundColor:[UIColor clearColor]];
    
    UIBarButtonItem *writeCommentItem = [[UIBarButtonItem alloc]
                                         initWithCustomView:_postCommentField];
    _postCommentItem = [[UIBarButtonItem alloc]
                        initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                        target:self
                        action:@selector(createComment:)];
    
    NSArray* toolbarItems = [NSArray arrayWithObjects:writeCommentItem, _postCommentItem, nil];
    self.toolbarItems = toolbarItems;
    
    UIToolbar *toolbar = self.navigationController.toolbar;
    [toolbar setBarStyle:UIBarStyleDefault];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(kSystemVersion70)) {
        [toolbar setBackgroundColor:[UIColor clearColor]];
        [toolbar setTranslucent:YES];
    }
    _viewControllerNewComment = nil;
    // }}}
    
    /*
     if you enable static row height in this demo then the cell height is determined
     from the tableView.rowHeight. Cells can be reused in this mode.
     If you disable this then cells are prepared and cached to reused their internal
     layouter and layoutFrame. Reuse is not recommended since the cells are cached anyway.
     */
    
    
    // establish a cache for prepared cells because heightForRowAtIndexPath and
    // cellForRowAtIndexPath both need the same cell for an index path
    _cellCache = [[NSCache alloc] init];
    
    // set system cache for URL data to 5MB
    [[NSURLCache sharedURLCache] setMemoryCapacity:1024*1024*5];
    
    _dateFormatter = [[NSDateFormatter alloc] init];
    
    [self wheelContainerSetup];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    [self getBootstrapInfo];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // add some pizzas by animating the toolbar from below (this serves
    // as a live reminder to the user that he/she can post a comment)
    [self.navigationController setToolbarHidden:NO animated:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    // hide the navigation controller here
    [super viewWillDisappear:animated];
    [self.streamClient stopStream];
    [self.navigationController setToolbarHidden:YES animated:animated];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
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
    
    _postCommentItem.target = nil;
    _postCommentItem = nil;
    
    [_cellCache removeAllObjects];
    _cellCache = nil;
    _streamClient = nil;
    _bootstrapClient = nil;
    
    _authors = nil;
    _content = nil;
    _container = nil;
    _activityIndicator = nil;
    _dateFormatter = nil;
}

#pragma mark - UIActivityIndicator
-(void)wheelContainerSetup
{
    _container = [[UIView alloc] initWithFrame:self.view.frame];
    [_container setBackgroundColor:[UIColor whiteColor]]; // should be white by default...
    
    // set autoresizing to support landscape mode
    [_container setAutoresizingMask:(UIViewAutoresizingFlexibleWidth |
                                     UIViewAutoresizingFlexibleHeight)];
    
    // init actvity indicator
    _activityIndicator = [[UIActivityIndicatorView alloc]
                          initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _activityIndicator.hidesWhenStopped = YES; // we hide it manually anyway
    
    // center activity indicator
    CGPoint center = self.view.center;
    center.y -= 44.0f;
    [_activityIndicator setCenter:center];
    
    // set autoresizing to support landscape mode
    [_activityIndicator setAutoresizingMask:(UIViewAutoresizingFlexibleBottomMargin |
                                             UIViewAutoresizingFlexibleHeight |
                                             UIViewAutoresizingFlexibleLeftMargin |
                                             UIViewAutoresizingFlexibleRightMargin |
                                             UIViewAutoresizingFlexibleTopMargin |
                                             UIViewAutoresizingFlexibleWidth)];
    
    [_container addSubview:_activityIndicator];
    [self.view addSubview:_container];
}

-(void)wheelContainerTeardown
{
    _activityIndicator = nil;
    _container = nil;
}

-(void)startSpinning
{
    _container.hidden = NO;
    _activityIndicator.hidden = NO;
    [_activityIndicator startAnimating];
}

-(void)stopSpinning {
    _container.hidden = YES;
    _activityIndicator.hidden = YES;
    [_activityIndicator stopAnimating];
}

#pragma mark - Status bar

-(void)setStatusBarHidden:(BOOL)hidden
            withAnimation:(UIStatusBarAnimation)animation
{
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)])
    {
        // iOS 7
        _prefersStatusBarHidden = hidden;
        _preferredStatusBarUpdateAnimation = animation;
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
                frame.origin.y = 0;
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
    if (scrollView.contentOffset.y <= _scrollOffset.y) {
        [self.navigationController setToolbarHidden:YES animated:YES];
    } else{
        [self.navigationController setToolbarHidden:NO animated:YES];
    }
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    _scrollOffset = scrollView.contentOffset;
}

#pragma mark - Private methods
- (void)getBootstrapInfo
{
    [self startSpinning];
    
    // clear all previous data
    [_authors removeAllObjects];
    [_content removeAllObjects];
    
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

-(void)addTopLevelContent:(NSArray*)content withAuthors:(NSDictionary*)authors
{
    // This method is responsible for both adding content from Bootstrap and
    // for streaming new updates.
    [_authors addEntriesFromDictionary:authors];
    
    NSPredicate *p = [NSPredicate predicateWithFormat:@"vis == 1"];
    NSArray *filteredContent = [content filteredArrayUsingPredicate:p];
    NSRange contentSpan;
    contentSpan.location = 0;
    contentSpan.length = [filteredContent count];
    [_content insertObjects:filteredContent
                      atIndexes:[NSIndexSet indexSetWithIndexesInRange:contentSpan]];
    
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

#pragma mark - UITextFieldDelegate

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self createComment:textField];
    return NO;
}

#pragma mark - UITableViewControllerDelegate

// disable this method to get static height = better performance
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LFSAttributedTextCell *cell = (LFSAttributedTextCell *)[self tableView:tableView
                                                     cellForRowAtIndexPath:indexPath];
    return [cell requiredRowHeightInTableView:tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_content count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // uniquing of NSIndexPath objects was disabled in iOS5, so use a string
    // key as a workaround
    NSString *key = [NSString stringWithFormat:@"%d-%d", indexPath.section, indexPath.row];
    LFSAttributedTextCell *cell = [_cellCache objectForKey:key];

    if (!cell) {
        if ([self canReuseCells]) {
            cell = (LFSAttributedTextCell *)[tableView dequeueReusableCellWithIdentifier:kAttributedTextCellReuseIdentifier];
        }
        if (!cell) {
            cell = [[LFSAttributedTextCell alloc]
                    initWithReuseIdentifier:kAttributedTextCellReuseIdentifier];
        }
        // cache the cell, if there is a cache
        [_cellCache setObject:cell forKey:key];
        
        // LFAttributedTextCell specifics
        cell.attributedTextContextView.shouldDrawImages = NO;
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
                                              [cell assignImage:image];
                                          }
                                          failure:nil];
    [operation start];
    
    // To test embedded images:
    //NSString *html =
    //[NSString stringWithFormat:@"<img src=\"%@\"/><div style=\"font-family:Avenir\">%@</div>",
    // avatarURL, bodyHTML];
    NSString *html = [NSString stringWithFormat:@"<div style=\"font-family:Avenir\">%@</div>", bodyHTML];
    
    [cell setHTMLString:html];
}

#pragma mark - Events
-(IBAction)createComment:(id)sender
{
    if (_viewControllerNewComment == nil) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        _viewControllerNewComment =
        (LFSNewCommentViewController*)[storyboard instantiateViewControllerWithIdentifier:@"commentNew"];
        _viewControllerNewComment.collection = self.collection;
        _viewControllerNewComment.collectionId = self.collectionId;
    }
    [self presentViewController:_viewControllerNewComment animated:YES completion:nil];
}

@end
