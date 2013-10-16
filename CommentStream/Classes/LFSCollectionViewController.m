//
//  LFSCollectionViewController.m
//  CommentStream
//
//  Created by Eugene Scherba on 8/7/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//


#define CACHE_SCALED_IMAGES

#import <StreamHub-iOS-SDK/LFSClient.h>
#import <AFNetworking/AFImageRequestOperation.h>

#import <objc/runtime.h>

#import "UIImage+LFSColor.h"

#import "LFSConfig.h"
#import "LFSAttributedTextCell.h"
#import "LFSDeletedCell.h"
#import "LFSCollectionViewController.h"
#import "LFSDetailViewController.h"
#import "LFSTextField.h"

#import "LFSUser.h"
#import "LFSContentCollection.h"

@interface LFSCollectionViewController ()
@property (nonatomic, strong) LFSMutableContentCollection *content;

@property (nonatomic, readonly) LFSBootstrapClient *bootstrapClient;
@property (nonatomic, readonly) LFSAdminClient *adminClient;
@property (nonatomic, readonly) LFSStreamClient *streamClient;
@property (nonatomic, readonly) LFSWriteClient *writeClient;

@property (nonatomic, readonly) LFSTextField *postCommentField;

@property (nonatomic, strong) LFSUser *user;

// render iOS7 status bar methods to be readwrite properties
@property (nonatomic, assign) BOOL prefersStatusBarHidden;
@property (nonatomic, assign) UIStatusBarAnimation preferredStatusBarUpdateAnimation;

@property (nonatomic, strong) LFSPostViewController *postViewController;

@property (nonatomic, strong) UIImage *placeholderImage;
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@end

// some module-level constants
static NSString* const kAttributedCellReuseIdentifier = @"LFSAttributedCell";
static NSString* const kDeletedCellReuseIdentifier = @"LFSDeletedCell";
static NSString* const kCellSelectSegue = @"detailView";

const static CGFloat kGenerationOffset = 20.f;
const static CGFloat kStatusBarHeight = 20.f;

const static char kAtttributedTextHeightKey;
const static char kAttributedTextValueKey;

@implementation LFSCollectionViewController
{
#ifdef CACHE_SCALED_IMAGES
    NSCache* _imageCache;
#endif
    
    UIActivityIndicatorView *_activityIndicator;
    UIView *_container;
    CGPoint _scrollOffset;
}

#pragma mark - Properties
@synthesize content = _content;
@synthesize user = _user;

@synthesize bootstrapClient = _bootstrapClient;
@synthesize streamClient = _streamClient;
@synthesize adminClient = _adminClient;
@synthesize writeClient = _writeClient;

@synthesize postCommentField = _postCommentField;
@synthesize collection = _collection;
@synthesize collectionId = _collectionId;
@synthesize placeholderImage = _placeholderImage;
@synthesize operationQueue = _operationQueue;

// render iOS7 status bar methods as writable properties
@synthesize prefersStatusBarHidden = _prefersStatusBarHidden;
@synthesize preferredStatusBarUpdateAnimation = _preferredStatusBarUpdateAnimation;

@synthesize postViewController = _postViewController;

-(LFSAdminClient*)adminClient
{
    if (_adminClient == nil) {
        _adminClient = [LFSAdminClient
                        clientWithNetwork:[self.collection objectForKey:@"network"]
                        environment:[self.collection objectForKey:@"environment"]];
    }
    return _adminClient;
}

- (LFSWriteClient*)writeClient
{
    if (_writeClient == nil) {
        _writeClient = [LFSWriteClient
                        clientWithNetwork:[self.collection objectForKey:@"network"]
                        environment:[self.collection objectForKey:@"environment"]];
    }
    return _writeClient;
}

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
                             withAuthors:[responseObject objectForKey:@"authors"]
                            visualInsert:YES];
            
        } success:nil failure:nil];
    }
    return _streamClient;
}

-(LFSPostViewController*)postViewController
{
    // lazy-instantiate LFSPostViewController
    static NSString* const kLFSMainStoryboardId = @"Main";
    static NSString* const kLFSPostCommentViewControllerId = @"postComment";
    
    if (_postViewController == nil) {
        UIStoryboard *storyboard = [UIStoryboard
                                    storyboardWithName:kLFSMainStoryboardId
                                    bundle:nil];
        _postViewController =
        (LFSPostViewController*)[storyboard
                                 instantiateViewControllerWithIdentifier:
                                 kLFSPostCommentViewControllerId];
        [_postViewController setDelegate:self];
    }
    return _postViewController;
}

#pragma mark - Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

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
    
    _scrollOffset = CGPointZero;
    
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
    _postViewController = nil;
    
    _streamClient = nil;
    _bootstrapClient = nil;
    _writeClient = nil;
    _adminClient = nil;
    
    _user = nil;
    // }}}
    
#ifdef CACHE_SCALED_IMAGES
    _imageCache = [[NSCache alloc] init];
#endif
    
    // set system cache for URL data to 5MB
    [[NSURLCache sharedURLCache] setMemoryCapacity:1024*1024*5];
    
    _placeholderImage = [UIImage imageWithColor:
                         [UIColor colorWithRed:232.f / 255.f
                                         green:236.f / 255.f
                                          blue:239.f / 255.f
                                         alpha:1.f]];
    
    _operationQueue = [[NSOperationQueue alloc] init];
    [_operationQueue setMaxConcurrentOperationCount:8];
    [self wheelContainerSetup];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // hide status bar for iOS7 and later
    [self setStatusBarHidden:LFS_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(LFSSystemVersion70)
               withAnimation:UIStatusBarAnimationNone];

    [self authenticateUser];
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
    [self.operationQueue cancelAllOperations];
    [self.navigationController setToolbarHidden:YES animated:animated];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
#ifdef CACHE_SCALED_IMAGES
    [_imageCache removeAllObjects];
#endif
}

- (void) dealloc
{
    [self wheelContainerTeardown];
    self.navigationController.delegate = nil;
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;

    _postViewController = nil;

    _streamClient = nil;
    _bootstrapClient = nil;
    _writeClient = nil;
    _adminClient = nil;

    _postCommentField.delegate = nil;
    _postCommentField = nil;
    
#ifdef CACHE_SCALED_IMAGES
    [_imageCache removeAllObjects];
    _imageCache = nil;
#endif

    _content = nil;
    _container = nil;
    _activityIndicator = nil;
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
            } else if (!hidden && navigationBar.frame.origin.y < kStatusBarHeight) {
                CGRect frame = navigationBar.frame;
                frame.origin.y = kStatusBarHeight;
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

- (void)authenticateUser
{
    if ([self.collection objectForKey:@"lftoken"] == nil) {
        return;
    }
    
    [self.adminClient authenticateUserWithToken:[self.collection objectForKey:@"lftoken"]
                                           site:[self.collection objectForKey:@"siteId"]
                                        article:[self.collection objectForKey:@"articleId"]
                                      onSuccess:^(NSOperation *operation, id responseObject)
     {
         self.user = [[LFSUser alloc] initWithObject:responseObject];
     }
                                      onFailure:^(NSOperation *operation, NSError *error)
     {
         NSLog(@"Could not authenticate user against collection");
     }];
}

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
                          withAuthors:[headDocument objectForKey:@"authors"]
                         visualInsert:NO];
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
        NSNumber *eventId = _content.lastEventId;
        [self.streamClient setCollectionId:self.collectionId];
        [self.streamClient startStreamWithEventId:eventId];
    }
}

-(void)addTopLevelContent:(NSArray*)content withAuthors:(NSDictionary*)authors visualInsert:(BOOL)visual
{
    // This callback is responsible for both adding content from Bootstrap and
    // for streaming new updates.
    [_content addAuthorsCollection:authors];
    
    [_content addObjectsFromArray:content];
    
    /*
    // TODO: only perform animated insertion of cells when the top of the
    // viewport is the same as the top of the first cell
    if (visual && [content count] == 1u) {
        // animate insertion
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:
                                                [NSIndexPath indexPathForRow:0 inSection:0]]
                              withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
    }
     */

    [self.tableView reloadData];
}

#pragma mark - UITableViewControllerDelegate

-(NSIndexPath*)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LFSContent *content = [_content objectAtIndex:indexPath.row];
    LFSContentVisibility visibility = content.visibility;
    return (visibility == LFSContentVisibilityEveryone
            ? indexPath
            : nil);
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LFSContent *content = [_content objectAtIndex:indexPath.row];
    LFSContentVisibility visibility = content.visibility;
    if (visibility == LFSContentVisibilityEveryone)
    {
        // TODO: no need to get cell from index and back if we are not using segues
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        [self performSegueWithIdentifier:kCellSelectSegue sender:cell];
    }
}

// disable this method to get static height = better performance
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellHeightValue;
    LFSContent *content = [_content objectAtIndex:indexPath.row];
    CGFloat leftOffset = (CGFloat)([content.datePath count] - 1) * kGenerationOffset;
    LFSContentVisibility visibility = content.visibility;
    if (visibility == LFSContentVisibilityEveryone)
    {
        NSNumber *cellHeight = objc_getAssociatedObject(content, &kAtttributedTextHeightKey);
        if (cellHeight == nil)
        {
            NSMutableAttributedString *attributedString =
            [LFSAttributedTextCell attributedStringFromHTMLString:(content.contentBodyHtml ?: @"")];
            
            objc_setAssociatedObject(content, &kAttributedTextValueKey,
                                     attributedString,
                                     OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            
            cellHeightValue = [LFSAttributedTextCell
                               cellHeightForAttributedString:attributedString
                               width:tableView.bounds.size.width
                               leftOffset:leftOffset];

            objc_setAssociatedObject(content, &kAtttributedTextHeightKey,
                                     [NSNumber numberWithFloat:cellHeightValue],
                                     OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
        else
        {
            cellHeightValue = [cellHeight floatValue];
        }
    }
    else
    {
        cellHeightValue = [LFSDeletedCell cellHeightForBoundsWidth:tableView.bounds.size.width
                                                    withLeftOffset:leftOffset];
    }
    return cellHeightValue;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_content count];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO: find out which content was created by current user
    // and only return "YES" for cells displaying that content
    NSString *userToken = [self.collection objectForKey:@"lftoken"];
    LFSContent *content = [_content objectAtIndex:indexPath.row];
    LFSContentVisibility visibility = content.visibility;
    return (userToken  != nil &&
            visibility == LFSContentVisibilityEveryone);
}

// Overriding this will enable "swipe to delete" gesture
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* const kFailureDeleteTitle = @"Failed to delete content";
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSString *userToken = [self.collection objectForKey:@"lftoken"];
        if (userToken != nil) {
            NSUInteger row = indexPath.row;
            LFSContent *content = [_content objectAtIndex:row];
            
            // cache current visibility state in case we need to revert
            LFSContentVisibility visibility = content.visibility;
            NSString *contentId = content.idString;
            
            [self.writeClient postMessage:LFSMessageDelete
                               forContent:content.idString
                             inCollection:self.collectionId
                                userToken:userToken
                               parameters:nil
                                onSuccess:^(NSOperation *operation, id responseObject)
             {
                 NSAssert([[responseObject objectForKey:@"comment_id"] isEqualToString:contentId],
                          @"Wrong content Id received");
                 LFSContent *newContent = [_content objectForKey:contentId];
                 if (newContent != nil)
                 {
                     NSIndexPath *newIndexPath = [NSIndexPath
                                                  indexPathForRow:[_content indexOfObject:newContent]
                                                  inSection:0];
                     
                     // no need to set visibility of newConent here as that is the
                     // function of LFSContentCollection
                     UITableView *tableView = self.tableView;
                     [tableView beginUpdates];
                     [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:newIndexPath, nil]
                                      withRowAnimation:UITableViewRowAnimationFade];
                     [tableView endUpdates];
                 }
             }
                                onFailure:^(NSOperation *operation, NSError *error)
             {
                 // show an error message
                 [[[UIAlertView alloc]
                   initWithTitle:kFailureDeleteTitle
                   message:[error localizedDescription]
                   delegate:nil
                   cancelButtonTitle:@"OK"
                   otherButtonTitles:nil] show];
                 
                 // check if an object with the cached id still exists in the model
                 // and if so, revert to its previous visibility state. This check is necessary
                 // because it is conceivable that the streaming client has already deleted
                 // the content object
                 LFSContent *newContent = [_content objectForKey:contentId];
                 if (newContent != nil)
                 {
                     // obtain new index path since it could have changed during the time
                     // it toook for the error response to come back
                     NSIndexPath *newIndexPath = [NSIndexPath
                                                  indexPathForRow:[_content indexOfObject:newContent]
                                                  inSection:0];
                     
                     [newContent setVisibility:visibility];
                     
                     UITableView *tableView = self.tableView;
                     [tableView beginUpdates];
                     [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:newIndexPath, nil]
                                      withRowAnimation:UITableViewRowAnimationFade];
                     [tableView endUpdates];
                 }
             }];
            
            // the block below will result in the standard content cell being replaced by a
            // "this comment has been removed" cell.
            [content setVisibility:LFSContentVisibilityPendingDelete];
            
            UITableView *tableView = self.tableView;
            [tableView beginUpdates];
            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil]
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView endUpdates];
        }
        else {
            // userToken is nil -- show an error message
            //
            // Note: Normally we never reach this block because we do not
            // allow editing for cells if our user token is nil
            [[[UIAlertView alloc]
              initWithTitle:kFailureDeleteTitle
              message:@"You do not have permission to delete comments in this collection"
              delegate:nil
              cancelButtonTitle:@"OK"
              otherButtonTitles:nil] show];
        }
    }
}

/*
-(void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Optionally kill the image request operation here as the image is no longer needed
}
*/

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LFSContent *content = [_content objectAtIndex:indexPath.row];
    LFSContentVisibility visibility = content.visibility;
    id returnedCell;
    
    if (visibility == LFSContentVisibilityEveryone)
    {
        LFSAttributedTextCell *cell = (LFSAttributedTextCell*)[tableView dequeueReusableCellWithIdentifier:kAttributedCellReuseIdentifier];
        
        if (!cell) {
            cell = [[LFSAttributedTextCell alloc]
                    initWithReuseIdentifier:kAttributedCellReuseIdentifier];
        }
        [self configureAttributedCell:cell forContent:content];
        returnedCell = cell;
    }
    else
    {
        LFSDeletedCell *cell = (LFSDeletedCell *)[tableView dequeueReusableCellWithIdentifier:
                                                  kDeletedCellReuseIdentifier];
        if (!cell) {
            cell = [[LFSDeletedCell alloc]
                    initWithReuseIdentifier:kDeletedCellReuseIdentifier];
            [cell.imageView setBackgroundColor:[UIColor colorWithRed:(217.f/255.f)
                                                               green:(217.f/255.f)
                                                                blue:(217.f/255.f)
                                                               alpha:1.f]];
            [cell.imageView setImage:[UIImage imageNamed:@"Trash"]];
            [cell.imageView setContentMode:UIViewContentModeCenter];
            [cell.textLabel setFont:[UIFont italicSystemFontOfSize:12.f]];
            [cell.textLabel setTextColor:[UIColor lightGrayColor]];
        }
        [self configureDeletedCell:cell forContent:content];
        returnedCell = cell;
    }
    
    return returnedCell;
}

#pragma mark - Table and cell helpers

-(void)configureDeletedCell:(LFSDeletedCell*)cell forContent:(LFSContent*)content
{
    LFSContentVisibility visibility = content.visibility;
    [cell setLeftOffset:((CGFloat)([content.datePath count] - 1) * kGenerationOffset)];
    
    NSString *bodyText = (visibility == LFSContentVisibilityPendingDelete
                          ? @"This comment is being removed…"
                          : @"This comment has been removed");
    [cell.textLabel setText:bodyText];
}

// called every time a cell is configured
- (void)configureAttributedCell:(LFSAttributedTextCell*)cell forContent:(LFSContent*)content
{
    // load image first
    [self loadImageForCell:cell withContent:content];
    
    // configure the rest of the cell
    [cell setContentDate:content.contentCreatedAt];
    [cell setIndicatorIcon:content.contentSourceIconSmall];
    
    [cell setLeftOffset:((CGFloat)([content.datePath count] - 1) * kGenerationOffset)];
    
    NSMutableAttributedString *attributedString = objc_getAssociatedObject(content, &kAttributedTextValueKey);
    [cell setAttributedString:attributedString];
    
    NSNumber *cellHeight = objc_getAssociatedObject(content, &kAtttributedTextHeightKey);
    [cell setRequiredBodyHeight:[cellHeight floatValue]];
    
    // always set an object
    LFSAuthorProfile *author = content.author;
    [cell setProfileLocal:[[LFSHeader alloc]
                           initWithDetailString:(author.twitterHandle ? [@"@" stringByAppendingString:author.twitterHandle] : @"")
                           attributeString:(content.authorIsModerator ? @"Moderator" : @"")
                           mainString:(author.displayName ?: @"")
                           iconImage:nil]];
}

-(void)loadImageForCell:(UITableViewCell*)cell withContent:(LFSContent*)content
{
    LFSAuthorProfile *author = content.author;
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
        [cell.imageView setImage:self.placeholderImage];
        NSURL *avatarUrl = [NSURL URLWithString:author.avatarUrlString75];
        // avatarUrl will be nil if URL string is nil or invalid
        if (avatarUrl != nil) {
            NSURLRequest *request = [NSURLRequest requestWithURL:avatarUrl];
            
            // set up the NSOperation here
            AFImageRequestOperation* operation =
            [AFImageRequestOperation
             imageRequestOperationWithRequest:request
             imageProcessingBlock:^UIImage *(UIImage *image)
             {
                 // scale down image
                 CGRect targetRect;
                 targetRect.origin = CGPointZero;
                 targetRect.size = kCellImageViewSize;
                 
                 // don't call UIGraphicsBeginImageContext when supporting Retina,
                 // instead call UIGraphicsBeginImageContextWithOptions with zero
                 // for scale
                 UIGraphicsBeginImageContextWithOptions(kCellImageViewSize, YES, 0.f);
                 [image drawInRect:targetRect];
                 UIImage *processedImage = UIGraphicsGetImageFromCurrentImageContext();
                 UIGraphicsEndImageContext();
#ifdef CACHE_SCALED_IMAGES
                 [_imageCache setObject:processedImage forKey:authorId];
#endif
                 return processedImage;
             }
             success:^(NSURLRequest *request,
                       NSHTTPURLResponse *response,
                       UIImage *image)
             {
                 // we are on the main thead here -- display the image
                 NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[_content indexOfObject:content]
                                                             inSection:0];
                 UITableViewCell *cell = (UITableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
                 if (cell) {
                     [cell.imageView setImage:image];
                     [cell setNeedsLayout];
                 }
             }
             failure:^(NSURLRequest *request,
                       NSHTTPURLResponse *response,
                       NSError *error)
             {
#ifdef CACHE_SCALED_IMAGES
                 // cache placeholder image instead so we don't repeatedly
                 // hit the server looking for stuff that doesn't exist
                 if (self.placeholderImage) {
                     [_imageCache setObject:self.placeholderImage
                                     forKey:authorId];
                 }
#endif
             }];
            
            // add operation to queue
            [self.operationQueue addOperation:operation];
        }
#ifdef CACHE_SCALED_IMAGES
    }
#endif
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
#ifdef CACHE_SCALED_IMAGES
                UIImage *avatarPreview = ([_imageCache objectForKey:contentItem.author.idString]
                                          ?: self.placeholderImage);
#else
                UIImage *avatarPreview = self.placeholderImage;
#endif
                [vc setContentItem:contentItem];
                [vc setAvatarImage:avatarPreview];
                [vc setCollection:self.collection];
                [vc setCollectionId:self.collectionId];
                [vc setHideStatusBar:self.prefersStatusBarHidden];
                [vc setUser:self.user];
                [vc setDelegate:self];
            }
        }
    }
}

#pragma mark - Events

-(IBAction)createComment:(id)sender
{
    // configure destination controller
    [self.postViewController setCollection:self.collection];
    [self.postViewController setCollectionId:self.collectionId];
    [self.postViewController setAvatarImage:self.placeholderImage];
    [self.postViewController setUser:self.user];
    
    [self.navigationController presentViewController:self.postViewController
                                            animated:YES
                                          completion:nil];
}

#pragma mark - LFSPostViewControllerDelegate
-(id<LFSPostViewControllerDelegate>)collectionViewController
{
    // forward collection view controller here to insert messagesinto
    // the content view as soon as the server gets back to us with 200 OK
    return self;
}


-(void)didSendPostRequestWithReplyTo:(NSString *)replyTo
{
    // this is triggered before we receive 200 OK from server
    
    // decide whether to scroll to the top row or to whichever row we are
    // replying to
    NSUInteger row = (replyTo != nil) ? [_content indexOfKey:replyTo] : 0;
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]
                          atScrollPosition:UITableViewScrollPositionTop
                                  animated:NO];
}

-(void)didPostContentWithOperation:(NSOperation*)operation response:(id)responseObject
{
    // 200 OK received, post was successful
    [self addTopLevelContent:[responseObject objectForKey:@"messages"]
                 withAuthors:[responseObject objectForKey:@"authors"]
                visualInsert:YES];
}

@end
