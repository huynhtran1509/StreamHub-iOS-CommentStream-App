//
//  LFSDetailViewController.m
//  CommentStream
//
//  Created by Eugene Scherba on 9/13/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <StreamHub-iOS-SDK/NSDateFormatter+RelativeTo.h>
#import "LFSDetailViewController.h"
#import "LFSPostViewController.h"
#import "LFSContentToolbar.h"

@interface LFSDetailViewController ()

@property (strong, nonatomic) LFSPostViewController *postCommentViewController;

// render iOS7 status bar methods as writable properties
@property (nonatomic, assign) BOOL prefersStatusBarHidden;
@property (nonatomic, assign) UIStatusBarAnimation preferredStatusBarUpdateAnimation;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet LFSDetailView *detailView;

@property (assign, nonatomic) BOOL contentLikedByUser;

@end

@implementation LFSDetailViewController

#pragma mark - Properties

// render iOS7 status bar methods as writable properties
@synthesize prefersStatusBarHidden = _prefersStatusBarHidden;
@synthesize preferredStatusBarUpdateAnimation = _preferredStatusBarUpdateAnimation;

@synthesize postCommentViewController = _postCommentViewController;

@synthesize hideStatusBar = _hideStatusBar;
@synthesize scrollView = _scrollView;
@synthesize detailView = _detailView;

@synthesize contentLikedByUser = _contentLikedByUser;

@synthesize avatarImage = _avatarImage;


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
                                 instantiateViewControllerWithIdentifier:kLFSPostCommentViewControllerId];
    }
    return _postCommentViewController;
}

-(void)setContentLikedByUser:(BOOL)contentLikedByUser
{
    _contentLikedByUser = contentLikedByUser;
    
    // mirror state to the detail view
    [self.detailView setIsLikedByUser:_contentLikedByUser];
}

#pragma mark - Lifecycle

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _hideStatusBar = NO;
        _contentLikedByUser = NO;
        
        _postCommentViewController = nil;
    }
    return self;
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _hideStatusBar = NO;
        _contentLikedByUser = NO;
        
        _postCommentViewController = nil;
    }
    return self;
}

- (void)dealloc
{
    _postCommentViewController = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    LFSDetailView *detailView = self.detailView;
    LFSContent *contentItem = self.contentItem;
    
    [detailView setDelegate:self];
    
    [detailView setContentBodyHtml:contentItem.contentBodyHtml];
    
    [detailView setContentDetail:[[[NSDateFormatter alloc] init]
                                extendedRelativeStringFromDate:contentItem.contentCreatedAt]];
    
    // only set an object if we have a remote (Twitter) url
    NSString *twitterUrlString = contentItem.contentTwitterUrlString;
    if (twitterUrlString != nil) {
        [detailView setContentRemote:[[LFSTriple alloc]
                                      initWithDetailString:twitterUrlString
                                      mainString:@"View on Twitter >"
                                      iconImage:nil]];
    }
    
    // only set an object if we have a twitter handle
    LFSAuthor *author = contentItem.author;
    if (author.profileUrlStringNoHashBang != nil) {
        [detailView setProfileRemote:[[LFSTriple alloc]
                                      initWithDetailString:author.profileUrlStringNoHashBang
                                      mainString:nil
                                      iconImage:[UIImage imageNamed:@"SourceTwitter"]]];
    }
    
    // always set an object
    NSNumber *moderator = [contentItem.contentAnnotations objectForKey:@"moderator"];
    BOOL hasModerator = (moderator != nil && [moderator boolValue] == YES);
    detailView.profileLocal = [[LFSHeader alloc]
                               initWithDetailString:(author.twitterHandle ? [@"@" stringByAppendingString:author.twitterHandle] : nil)
                               attributeString:(hasModerator ? @"Moderator" : nil)
                               mainString:author.displayName
                               iconImage:self.avatarImage];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setStatusBarHidden:self.hideStatusBar withAnimation:UIStatusBarAnimationNone];
    //[self.navigationController setToolbarHidden:YES animated:animated];
    
    // calculate content size for scrolling
    CGSize detailViewSize = [self.detailView sizeThatFits:
                             CGSizeMake(self.scrollView.bounds.size.width, CGFLOAT_MAX)];
    detailViewSize.width = self.scrollView.bounds.size.width;
    [_scrollView setContentSize:detailViewSize];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

#pragma mark - LFSDetailViewDelegate
- (void)didSelectLike:(id)sender
{
    // toggle liked state
    [self setContentLikedByUser:!self.contentLikedByUser];
}

- (void)didSelectReply:(id)sender
{
    // configure destination controller
    [self.postCommentViewController setCollection:self.collection];
    [self.postCommentViewController setCollectionId:self.collectionId];
    [self.postCommentViewController setReplyToContent:self.contentItem];
    
    [self presentViewController:self.postCommentViewController
                       animated:YES
                     completion:nil];
}

@end
