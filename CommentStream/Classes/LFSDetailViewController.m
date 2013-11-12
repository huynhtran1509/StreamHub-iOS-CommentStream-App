//
//  LFSDetailViewController.m
//  CommentStream
//
//  Created by Eugene Scherba on 9/13/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <StreamHub-iOS-SDK/LFSWriteClient.h>
#import <StreamHub-iOS-SDK/NSDateFormatter+RelativeTo.h>

#import "UIImage+LFSColor.h"
#import "LFSDetailViewController.h"
#import "LFSContentToolbar.h"

#import "LFSAppDelegate.h"

#import "LFSOembed.h"
#import "LFSAttributedLabelDelegate.h"

typedef NS_ENUM(NSUInteger, LFSActionType) {
    kLFSActionTypeFlag = 0u,
    kLFSActionTypeDelete
};

@interface LFSDetailViewController () {
    LFSActionType _actionType;
}

@property (nonatomic, readonly) LFSWriteClient *writeClient;

@property (strong, nonatomic) LFSPostViewController *postViewController;

// render iOS7 status bar methods as writable properties
@property (nonatomic, assign) BOOL prefersStatusBarHidden;
@property (nonatomic, assign) UIStatusBarAnimation preferredStatusBarUpdateAnimation;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet LFSDetailView *detailView;

@end

// hardcode author id for now
static NSString* const kCurrentUserId = @"_up19433660@livefyre.com";

@implementation LFSDetailViewController

#pragma mark - Properties

@synthesize delegate = _delegate;

// render iOS7 status bar methods as writable properties
@synthesize prefersStatusBarHidden = _prefersStatusBarHidden;
@synthesize preferredStatusBarUpdateAnimation = _preferredStatusBarUpdateAnimation;

@synthesize attributedLabelDelegate = _attributedLabelDelegate;
@synthesize postViewController = _postViewController;
@synthesize user = _user;

@synthesize hideStatusBar = _hideStatusBar;
@synthesize scrollView = _scrollView;
@synthesize detailView = _detailView;

@synthesize collection = _collection;
@synthesize collectionId = _collectionId;
@synthesize contentItem = _contentItem;
@synthesize avatarImage = _avatarImage;

@synthesize writeClient = _writeClient;
- (LFSWriteClient*)writeClient
{
    if (_writeClient == nil) {
        NSString *network = [self.collection objectForKey:@"network"];
        NSString *environment = [self.collection objectForKey:@"environment"];
        _writeClient = [LFSWriteClient
                        clientWithNetwork:network
                        environment:environment];
    }
    return _writeClient;
}

-(LFSPostViewController*)postViewController
{
    // lazy-instantiate LFSPostViewController
    static NSString* const kLFSPostCommentViewControllerId = @"postComment";
    
    if (_postViewController == nil) {
        _postViewController =
        (LFSPostViewController*)[[AppDelegate mainStoryboard]
                                 instantiateViewControllerWithIdentifier:kLFSPostCommentViewControllerId];
        [_postViewController setDelegate:self];
    }
    return _postViewController;
}

#pragma mark - Private methods
-(void)updateLikeButton
{
    UIButton *likeButton = self.detailView.button1;
    NSUInteger numberOfLikes = [self.contentItem.likes count];
    if (numberOfLikes > 0u) {
        if ([self.contentItem.likes containsObject:kCurrentUserId]) {
            [likeButton setImage:[UIImage imageNamed:@"StateLiked"]
                        forState:UIControlStateNormal];
            [likeButton setTitle:[NSString stringWithFormat:@"%zd", numberOfLikes]
                        forState:UIControlStateNormal];
            [likeButton setTitleColor:[UIColor colorWithRed:241.f/255.f green:92.f/255.f blue:56.f/255.f alpha:1.f]
                             forState:UIControlStateNormal];
            [likeButton setTitleColor:[UIColor colorWithRed:128.f/255.f green:49.f/255.f blue:29.f/255.f alpha:1.f]
                             forState:UIControlStateHighlighted];
        }
        else {
            [likeButton setImage:[UIImage imageNamed:@"StateNotLiked"]
                        forState:UIControlStateNormal];
            [likeButton setTitle:[NSString stringWithFormat:@"%zd", numberOfLikes]
                        forState:UIControlStateNormal];
            [likeButton setTitleColor:[UIColor colorWithRed:162.f/255.f green:165.f/255.f blue:170.f/255.f alpha:1.f]
                             forState:UIControlStateNormal];
            [likeButton setTitleColor:[UIColor colorWithRed:86.f/255.f green:88.f/255.f blue:90.f/255.f alpha:1.f]
                             forState:UIControlStateHighlighted];
        }
    }
    else {
        [likeButton setImage:[UIImage imageNamed:@"StateNotLiked"]
                    forState:UIControlStateNormal];
        [likeButton setTitle:@"Like"
                    forState:UIControlStateNormal];
        [likeButton setTitleColor:[UIColor colorWithRed:162.f/255.f green:165.f/255.f blue:170.f/255.f alpha:1.f]
                         forState:UIControlStateNormal];
        [likeButton setTitleColor:[UIColor colorWithRed:86.f/255.f green:88.f/255.f blue:90.f/255.f alpha:1.f]
                         forState:UIControlStateHighlighted];
    }
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self updateScrollViewContentSize];
}

- (void)updateScrollViewContentSize
{
    UIScrollView *scrollView = self.scrollView;
    LFSDetailView *detailView = self.detailView;
    LFSOembed* oembed = self.contentItem.firstOembed;
    
    if (oembed != nil) {
        [UIView animateWithDuration:0.5f animations:^{
            CGRect attachmentFrame = detailView.attachmentView.frame;
            attachmentFrame.size = oembed.size;
            [detailView.attachmentView setFrame:attachmentFrame];
        }];
    }
    
    CGSize scrollViewSize = scrollView.bounds.size;
    CGSize detailViewSize = [detailView sizeThatFits:CGSizeMake(scrollViewSize.width, CGFLOAT_MAX)];
    detailViewSize.width = scrollViewSize.width;
    [scrollView setContentSize:detailViewSize];
    
    // set height of detailView to calculated height
    // (otherwise the toolbar stops responding to tap events...)
    CGRect detailViewFrame = detailView.frame;
    detailViewFrame.size = detailViewSize;
    [detailView setFrame:detailViewFrame];
    
}

#pragma mark - Lifecycle

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _hideStatusBar = NO;
        _writeClient = nil;
        _postViewController = nil;
    }
    return self;
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _hideStatusBar = NO;
        _writeClient = nil;
        _postViewController = nil;
    }
    return self;
}

- (void)dealloc
{
    [_detailView setDelegate:nil];
    [_postViewController setDelegate:nil];
    _postViewController = nil;
}

#pragma mark - Public methods

- (void)detailView:(LFSDetailView*)detailView setOembed:(LFSOembed*)oembed
{
    // currently supporting image and video oembeds
    if (oembed != nil) {
        if (oembed.oembedType == LFSOembedTypePhoto) {
            // set attachment view frame size
            UIView *attachmentView = [[UIImageView alloc] init];
            [self.detailView setAttachmentView:attachmentView];
            CGRect attachmentFrame = attachmentView.frame;
            attachmentFrame.size = oembed.size;
            [attachmentView setFrame:attachmentFrame];
            
            __weak UIImageView* weakAttachmentView = (UIImageView*)attachmentView;
            [(UIImageView*)attachmentView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:oembed.urlSring]]
                                                placeholderImage:nil
                                                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
             {
                 // find out image size here and re-layout view
                 [weakAttachmentView setImage:image];
             }
                                                         failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)
             {
                 // TODO: image failed to download -- ask JS about desired behavior
             }];
            // toggle attachment view visibility
            [attachmentView setHidden:NO];
        }
        else if (oembed.oembedType == LFSOembedTypeVideo || oembed.oembedType == LFSOembedTypeRich) {
            // set attachment view frame size
            UIWebView *attachmentView = [[UIWebView alloc] init];
            [attachmentView setBackgroundColor:[UIColor clearColor]];
            [attachmentView setScalesPageToFit:YES];
            [attachmentView.scrollView setScrollEnabled:NO];
            [attachmentView.scrollView setBounces:NO];
            
            [self.detailView setAttachmentView:attachmentView];
            if (oembed.oembedType == LFSOembedTypeVideo && oembed.embedYouTubeId != nil) {
                NSString *urlString = [@"http://www.youtube.com/embed/"
                                       stringByAppendingString:oembed.embedYouTubeId];
                NSURL *url = [NSURL URLWithString:urlString];
                [attachmentView loadRequest:[NSURLRequest requestWithURL:url]];
            } else {
                [attachmentView loadHTMLString:oembed.html baseURL:nil];
            }
            
            CGRect attachmentFrame = attachmentView.frame;
            attachmentFrame.size = oembed.size;
            [attachmentView setFrame:attachmentFrame];
            
            // toggle attachment view visibility
            [attachmentView setHidden:NO];
        }
        else {
            [detailView.attachmentView setHidden:YES];
        }
    }
    else {
        [detailView.attachmentView setHidden:YES];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _postViewController = nil;
    
    LFSDetailView *detailView = self.detailView;
    LFSContent *contentItem = self.contentItem;
    
    [detailView setDelegate:self];
    [detailView setContentBodyHtml:contentItem.contentBodyHtml];
    [detailView setContentDate:contentItem.contentCreatedAt];
    [detailView.bodyView setDelegate:self.attributedLabelDelegate];
    [self detailView:detailView setOembed:self.contentItem.firstOembed];

    [self updateLikeButton];
    
    [detailView.button2 setTitle:@"Reply" forState:UIControlStateNormal];
    [detailView.button2 setImage:[UIImage imageNamed:@"ActionReply"] forState:UIControlStateNormal];
    
    if ([self.user.profile isEqual:self.contentItem.author]) {
        _actionType = kLFSActionTypeDelete;
        [detailView.button3 setTitle:@"Delete" forState:UIControlStateNormal];
        [detailView.button3 setImage:[UIImage imageNamed:@"ActionTrash"] forState:UIControlStateNormal];
    } else {
        _actionType = kLFSActionTypeFlag;
        [detailView.button3 setTitle:@"Flag" forState:UIControlStateNormal];
        [detailView.button3 setImage:[UIImage imageNamed:@"ActionFlag"] forState:UIControlStateNormal];
    }
    
    // only set an object if we have a remote (Twitter) url
    NSString *twitterUrlString = contentItem.contentTwitterUrlString;
    if (twitterUrlString != nil) {
        [detailView setContentRemote:[[LFSResource alloc]
                                      initWithIdentifier:twitterUrlString
                                      displayString:@"View on Twitter"
                                      icon:nil]];
    }
    
    LFSAuthorProfile *author = contentItem.author;
    [detailView setProfileRemote:[[LFSResource alloc]
                                  initWithIdentifier:author.profileUrlStringNoHashBang
                                  displayString:nil
                                  icon:contentItem.contentSourceIcon]];
    
    LFSResource *headerInfo = [[LFSResource alloc]
                               initWithIdentifier:(author.twitterHandle ? [@"@" stringByAppendingString:author.twitterHandle] : nil)
                               attributeString:(contentItem.authorIsModerator ? @"Moderator" : nil)
                               displayString:author.displayName
                               icon:self.avatarImage];
    [headerInfo setIconURLString:author.avatarUrlString75];
    [detailView setProfileLocal:headerInfo];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setStatusBarHidden:self.hideStatusBar withAnimation:UIStatusBarAnimationNone];
    //[self.navigationController setToolbarHidden:YES animated:animated];
    
    // calculate content size for scrolling
    [self updateScrollViewContentSize];
    
    // KVO attach observer
    if ([self.detailView.attachmentView isKindOfClass:[UIImageView class]]) {
        [self.detailView.attachmentView addObserver:self
                                              forKeyPath:@"image"
                                                 options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                                                 context:NULL];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // KVO detach observer
    if ([self.detailView.attachmentView isKindOfClass:[UIImageView class]]) {
        [self.detailView.attachmentView removeObserver:self
                                                 forKeyPath:@"image"
                                                    context:NULL];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - KVO

-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary *)change
                      context:(void *)context
{
    if (object == self.detailView.attachmentView && [keyPath isEqualToString:@"image"])
    {
        UIImage *newImage = [change objectForKey:NSKeyValueChangeNewKey];
        UIImage *oldImage = [change objectForKey:NSKeyValueChangeOldKey];
        // have to check object type because it could be NSNull and then
        // we would get missing selector exception
        if (newImage != oldImage ||
            (([newImage isKindOfClass:[UIImage class]]) &&
             ([oldImage isKindOfClass:[UIImage class]]) &&
             (newImage.size.width != oldImage.size.width ||
              newImage.size.height != oldImage.size.height)))
        {
            // images differ, update layout
            [self updateScrollViewContentSize];
            [self.detailView setNeedsLayout];
        }
    }
}

#pragma mark - Status bar

-(void)setStatusBarHidden:(BOOL)hidden
            withAnimation:(UIStatusBarAnimation)animation
{
    const static CGFloat kStatusBarHeight = 20.f;
    _prefersStatusBarHidden = hidden;
    _preferredStatusBarUpdateAnimation = animation;
    
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)])
    {
        // iOS7
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
    else
    {
        // iOS6
        [[UIApplication sharedApplication] setStatusBarHidden:hidden
                                                withAnimation:animation];
        if (self.navigationController) {
            UINavigationBar *navigationBar = self.navigationController.navigationBar;
            if (hidden && navigationBar.frame.origin.y > 0.f)
            {
                CGRect frame = navigationBar.frame;
                frame.origin.y = 0.f;
                navigationBar.frame = frame;
            }
            else if (!hidden && navigationBar.frame.origin.y < kStatusBarHeight)
            {
                CGRect frame = navigationBar.frame;
                frame.origin.y = kStatusBarHeight;
                navigationBar.frame = frame;
            }
        }
    }
}

#pragma mark - LFSDetailViewDelegate

- (void)didSelectButton1:(id)sender
{
    // Like button selected
    static NSString* const kFailureModifyTitle = @"Action Failed";
    NSString *userToken = [self.collection objectForKey:@"lftoken"];
    if (userToken != nil) {
        LFSMessageAction action;
        if ([self.contentItem.likes containsObject:kCurrentUserId]) {
            [self.contentItem.likes removeObject:kCurrentUserId];
            action = LFSMessageUnlike;
        } else {
            [self.contentItem.likes addObject:kCurrentUserId];
            action = LFSMessageLike;
        }
        [self updateLikeButton];
        
        
        [self.writeClient postMessage:action
                           forContent:self.contentItem.idString
                         inCollection:self.collectionId
                            userToken:userToken
                           parameters:nil
                            onSuccess:^(NSOperation *operation, id responseObject)
         {
             //NSLog(@"success posting opine %d", action);
         }
                            onFailure:^(NSOperation *operation, NSError *error)
         {
             //NSLog(@"failed posting opine %d", action);
         }];
    } else {
        // userToken is nil -- show an error message
        [[[UIAlertView alloc]
          initWithTitle:kFailureModifyTitle
          message:@"You do not have permission to like comments in this collection"
          delegate:nil
          cancelButtonTitle:@"OK"
          otherButtonTitles:nil] show];
    }
}

- (void)didSelectButton2:(id)sender
{
    // Reply selected
    [self.postViewController setCollection:self.collection];
    [self.postViewController setCollectionId:self.collectionId];
    [self.postViewController setReplyToContent:self.contentItem];
    
    [self.postViewController setUser:self.user];
    [self.postViewController setAvatarImage:[UIImage imageWithColor:
                                             [UIColor colorWithRed:232.f / 255.f
                                                             green:236.f / 255.f
                                                              blue:239.f / 255.f
                                                             alpha:1.f]]];
    
    [self.navigationController presentViewController:self.postViewController
                                            animated:YES
                                          completion:nil];
}

- (void)didSelectButton3:(id)sender
{
    // Either "Flag" or "Delete" selected
    if (_actionType == kLFSActionTypeDelete && [self.user.profile isEqual:self.contentItem.author]) {
        [self.delegate deleteContent:self.contentItem];
        [self.navigationController popViewControllerAnimated:NO];
    }
    else if (_actionType == kLFSActionTypeFlag) {
        [self showActionSheet:sender];
    }
}

- (void)didSelectProfile:(id)sender wihtURL:(NSURL*)url
{
    if (url != nil) {
        [self.attributedLabelDelegate followURL:url];
    }
}

- (void)didSelectContentRemote:(id)sender wihtURL:(NSURL*)url
{
    if (url != nil) {
        [self.attributedLabelDelegate followURL:url];
    }
}

#pragma mark - Private methods
-(void)showActionSheet:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"Flag Comment"
                                  delegate:self
                                  cancelButtonTitle:@"Cancel"
                                  destructiveButtonTitle:[LFSContentFlags[LFSFlagSpam] capitalizedString]
                                  otherButtonTitles:
                                  [LFSContentFlags[LFSFlagOffensive] capitalizedString],
                                  [LFSContentFlags[LFSFlagOfftopic] capitalizedString],
                                  [LFSContentFlags[LFSFlagDisagree] capitalizedString],
                                  nil];
    
    [actionSheet showInView:self.view];
}

#pragma mark - UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //Get the name of the current pressed button
    BOOL animatedPop = NO;
    NSString *action = [actionSheet buttonTitleAtIndex:buttonIndex];
    if  ([action isEqualToString:[LFSContentFlags[LFSFlagSpam] capitalizedString]])
    {
        [self.delegate flagContent:self.contentItem withFlag:LFSFlagSpam];
        [self.navigationController popViewControllerAnimated:animatedPop];
    }
    else if ([action isEqualToString:[LFSContentFlags[LFSFlagOffensive] capitalizedString]])
    {
        [self.delegate flagContent:self.contentItem withFlag:LFSFlagOffensive];
        [self.navigationController popViewControllerAnimated:animatedPop];
    }
    else if ([action isEqualToString:[LFSContentFlags[LFSFlagOfftopic] capitalizedString]])
    {
        [self.delegate flagContent:self.contentItem withFlag:LFSFlagOfftopic];
        [self.navigationController popViewControllerAnimated:animatedPop];
    }
    else if ([action isEqualToString:[LFSContentFlags[LFSFlagDisagree] capitalizedString]])
    {
        [self.delegate flagContent:self.contentItem withFlag:LFSFlagDisagree];
        [self.navigationController popViewControllerAnimated:animatedPop];
    }
    else if ([action isEqualToString:@"Cancel"])
    {
        // do nothing
    }
}

#pragma mark - LFSPostViewControllerDelegate
-(id<LFSPostViewControllerDelegate>)collectionViewController
{
    // forward collection view controller here to insert messagesinto
    // the content view as soon as the server gets back to us with 200 OK
    id<LFSPostViewControllerDelegate> collectionViewController = (id<LFSPostViewControllerDelegate>)self.delegate;
    return collectionViewController;
}

-(void)didSendPostRequestWithReplyTo:(NSString*)replyTo
{
    // simply forward to the collection view controller
    id<LFSPostViewControllerDelegate> collectionViewController = (id<LFSPostViewControllerDelegate>)self.delegate;
    [self.navigationController popViewControllerAnimated:NO];
    [collectionViewController didSendPostRequestWithReplyTo:replyTo];
}

@end
