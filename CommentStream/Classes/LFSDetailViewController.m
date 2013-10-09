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

@synthesize numberOfLikes = _numberOfLikes;

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

-(void)setNumberOfLikes:(NSUInteger)numberOfLikes
{
    LFSDetailView *detailView = self.detailView;
    _numberOfLikes = numberOfLikes;
    
    if (_numberOfLikes == 0) {
        [detailView.button1 setImage:[UIImage imageNamed:@"StateNotLiked"] forState:UIControlStateNormal];
        [detailView.button1 setTitle:@"Like"
                               forState:UIControlStateNormal];
        [detailView.button1 setTitleColor:[UIColor colorWithRed:162.f/255.f green:165.f/255.f blue:170.f/255.f alpha:1.f]  forState:UIControlStateNormal];
        [detailView.button1 setTitleColor:[UIColor colorWithRed:86.f/255.f green:88.f/255.f blue:90.f/255.f alpha:1.f] forState:UIControlStateHighlighted];
    } else {
        [detailView.button1 setImage:[UIImage imageNamed:@"StateLiked"] forState:UIControlStateNormal];
        [detailView.button1 setTitle:[NSString stringWithFormat:@"%d", _numberOfLikes]
                               forState:UIControlStateNormal];
        [detailView.button1 setTitleColor:[UIColor colorWithRed:241.f/255.f green:92.f/255.f blue:56.f/255.f alpha:1.f]
                                    forState:UIControlStateNormal];
        [detailView.button1 setTitleColor:[UIColor colorWithRed:128.f/255.f green:49.f/255.f blue:29.f/255.f alpha:1.f]
                                    forState:UIControlStateHighlighted];
    }
}

#pragma mark - Lifecycle

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _hideStatusBar = NO;
        _numberOfLikes = 0u;
        
        _postCommentViewController = nil;
    }
    return self;
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _hideStatusBar = NO;
        _numberOfLikes = 0u;
        
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
    [detailView setContentDate:contentItem.contentCreatedAt];
    
    [detailView.button1 setTitle:@"Like" forState:UIControlStateNormal];
    [detailView.button2 setTitle:@"Reply" forState:UIControlStateNormal];
    [detailView.button1 setImage:[UIImage imageNamed:(self.numberOfLikes > 0u ? @"StateLiked" : @"StateNotLiked")]
                        forState:UIControlStateNormal];
    [detailView.button2 setImage:[UIImage imageNamed:@"ActionReply"] forState:UIControlStateNormal];
    
    // only set an object if we have a remote (Twitter) url
    NSString *twitterUrlString = contentItem.contentTwitterUrlString;
    if (twitterUrlString != nil) {
        [detailView setContentRemote:[[LFSTriple alloc]
                                      initWithDetailString:twitterUrlString
                                      mainString:@"View on Twitter >"
                                      iconImage:nil]];
    }
    
    LFSAuthor *author = contentItem.author;
    [detailView setProfileRemote:[[LFSTriple alloc]
                                  initWithDetailString:author.profileUrlStringNoHashBang
                                  mainString:nil
                                  iconImage:contentItem.contentSourceIcon]];
    
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
    [self setNumberOfLikes:(self.numberOfLikes > 0 ? 0 : 1)];
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
