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
#import "LFSDetailViewController.h"
#import "LFSTextField.h"

@interface LFSCollectionViewController () {
    __weak UITableView* _tableView;
    LFSNewCommentViewController *_viewControllerNewComment;
}

@property (nonatomic, strong) NSMutableDictionary *authors;
@property (nonatomic, strong) NSMutableArray *content;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, readonly) LFSBootstrapClient *bootstrapClient;
@property (nonatomic, readonly) LFSStreamClient *streamClient;
@property (nonatomic, readonly) LFSTextField *postCommentField;

// render iOS7 status bar methods to be readwrite properties
@property (nonatomic, assign) BOOL prefersStatusBarHidden;
@property (nonatomic, assign) UIStatusBarAnimation preferredStatusBarUpdateAnimation;

- (BOOL)canReuseCells;
@end

// some module-level constants
static NSString* const kCellReuseIdentifier = @"AttributedTextCellReuseIdentifier";
static NSString* const kCellSelectSegue = @"detailView";

@implementation LFSCollectionViewController
{
    NSCache* _cellCache;
    UIActivityIndicatorView *_activityIndicator;
    UIView *_container;
    CGPoint _scrollOffset;
    
    // regular expression stuff (to replace 50px images with 75px)
    // TODO: move this to a separate class?
    NSRegularExpression *_regex1;
    NSRegularExpression *_regex2;
    NSString *_regexTemplate1;
    NSString *_regexTemplate2;
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
    
    if (LFS_SYSTEM_VERSION_LESS_THAN(LFSSystemVersion70)) {
        // A strong reference to UITableView in DTAttributedTextCell causes overrelease.
        // The following line is a work-around to that problem. This ought to be replaced
        // when the following fix by Cocoanetics is merged to master:
        // https://github.com/Cocoanetics/DTCoreText/issues/599
        // Note: this is an iOS6 issue only.
        //
        _tableView = (__bridge id)CFBridgingRetain(self.tableView);
    }
    
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
    [_postCommentField setPlaceholder:@"Write a comment..."];


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
    _viewControllerNewComment = nil;
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
    
    // set system cache for URL data to 5MB
    [[NSURLCache sharedURLCache] setMemoryCapacity:1024*1024*5];
    
    _dateFormatter = [[NSDateFormatter alloc] init];
    
    
    // {{{ Regex stuff
    //
    // We will handle two types of avatar URLs:
    // http://gravatar.com/avatar/c228ecbc43be06cc999c08cf020f9fde/?s=50&d=http://avatars-staging.fyre.co/a/anon/50.jpg
    // http://avatars.fyre.co/a/26/6dbce19ef7452f69164e857d55d173ae/50.jpg?v=1375324889"
    //
    NSError *regexError1 = nil;
    _regex1 = [NSRegularExpression
                      regularExpressionWithPattern:@"([?&])s=50(&?)"
                      options:NSRegularExpressionCaseInsensitive
                      error:&regexError1];
    NSAssert(regexError1 == nil, @"Error creating regex: %@", regexError1.description);
    
    _regexTemplate1 = @"$1s=75$2";
    
    NSError *_regexError2 = nil;
    _regex2 = [NSRegularExpression
                      regularExpressionWithPattern:@"/50.([a-zA-Z]+)\\b"
                      options:NSRegularExpressionCaseInsensitive
                      error:&_regexError2];
    NSAssert(regexError1 == nil, @"Error creating regex: %@", regexError1.description);
    _regexTemplate2 = @"/75.$1";
    // }}}
    
    [self wheelContainerSetup];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // hide status bar for iOS7 and later
    [self setStatusBarHidden:LFS_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(LFSSystemVersion70)
               withAnimation:UIStatusBarAnimationNone];
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
    
    _regex1 = nil;
    _regex2 = nil;
    _regexTemplate1 = nil;
    _regexTemplate2 = nil;
    
    _postCommentField.delegate = nil;
    _postCommentField = nil;
    
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
    [self.navigationController
     setToolbarHidden:(scrollView.contentOffset.y <= _scrollOffset.y)
     animated:YES];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                 willDecelerate:(BOOL)decelerate
{
    _scrollOffset = scrollView.contentOffset;
}

#pragma mark - Private methods
- (void)startStreamWithBoostrap
{
    // If we have some data, do not clear it and do not run bootstrap.
    // Instead, grab the latest event ID and start streaming from there
    
    if (_content.count == 0) {
        [_authors removeAllObjects];
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
        NSNumber *eventId = [[_content objectAtIndex:0u] objectForKey:@"event"];
        [self.streamClient setCollectionId:self.collectionId];
        [self.streamClient startStreamWithEventId:eventId];
    }
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [self performSegueWithIdentifier:kCellSelectSegue sender:cell];
}

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
            cell = (LFSAttributedTextCell *)[tableView
                                             dequeueReusableCellWithIdentifier:kCellReuseIdentifier];
        }
        if (!cell) {
            cell = [[LFSAttributedTextCell alloc]
                    initWithReuseIdentifier:kCellReuseIdentifier];
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
    

    // create 75px avatar url
    NSString *avatarURL1 = [_regex1 stringByReplacingMatchesInString:avatarURL
                                                               options:0
                                                                 range:NSMakeRange(0, [avatarURL length])
                                                          withTemplate:_regexTemplate1];
    NSString *avatarURL2 = [_regex2 stringByReplacingMatchesInString:avatarURL1
                                                           options:0
                                                             range:NSMakeRange(0, [avatarURL1 length])
                                                      withTemplate:_regexTemplate2];
    // load avatar images in a separate queue
    NSURLRequest *request =
    [NSURLRequest requestWithURL:[NSURL URLWithString:avatarURL2]];
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

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:kCellSelectSegue])
    {
        // Get reference to the destination view controller
        if ([segue.destinationViewController isKindOfClass:[LFSDetailViewController class]]) {
            if ([sender isKindOfClass:[UITableViewCell class]]) {
                NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
                LFSDetailViewController *vc = segue.destinationViewController;
                
                // assign model object(s)
                NSDictionary *content = [[_content objectAtIndex:indexPath.row] objectForKey:@"content"];
                vc.contentItem = content;
                vc.authorItem = [_authors objectForKey:[content objectForKey:@"authorId"]];
            }
        }
    }
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
