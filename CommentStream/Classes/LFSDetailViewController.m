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

// render iOS7 status bar methods as writable properties
@property (nonatomic, assign) BOOL prefersStatusBarHidden;
@property (nonatomic, assign) UIStatusBarAnimation preferredStatusBarUpdateAnimation;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) LFSBasicHTMLLabel *basicHTMLLabel;
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet LFSBasicHTMLLabel *remoteUrlLabel;
@property (weak, nonatomic) IBOutlet UIButton *sourceButton;

@property (strong, nonatomic) LFSContentToolbar *contentToolbar;
@property (strong, nonatomic) LFSPostViewController *postCommentViewController;

- (IBAction)didSelectSource:(id)sender;
- (IBAction)didSelectReply:(id)sender;
- (IBAction)didSelectLike:(id)sender;

@property (strong, nonatomic) UIButton *likeButton;
@property (strong, nonatomic) UIButton *replyButton;

@property (assign, nonatomic) BOOL liked;
@end

static const CGFloat kAvatarCornerRadius = 4;

static NSString* const kReplySegue = @"replyTo";

@implementation LFSDetailViewController {
    UIImage *_avatarImage;
}

#pragma mark - Class methods
static UIFont *titleFont = nil;

static UIFont *dateFont = nil;
static UIColor *dateColor = nil;

+ (void)initialize {
    if(self == [LFSDetailViewController class]) {
        titleFont = [UIFont boldSystemFontOfSize:16.f];
        dateFont = [UIFont systemFontOfSize:13.f];
        dateColor = [UIColor lightGrayColor];
    }
}

#pragma mark - Properties

@synthesize scrollView = _scrollView;

@synthesize basicHTMLLabel = _basicHTMLLabel;

@synthesize avatarView = _avatarView;
@synthesize authorLabel = _authorLabel;
@synthesize dateLabel = _dateLabel;
@synthesize remoteUrlLabel = _remoteUrlLabel;
@synthesize contentToolbar = _contentToolbar;
@synthesize sourceButton = _sourceButton;

@synthesize hideStatusBar = _hideStatusBar;

@synthesize likeButton = _likeButton;
@synthesize replyButton = _replyButton;

@synthesize liked = _liked;

// render iOS7 status bar methods as writable properties
@synthesize prefersStatusBarHidden = _prefersStatusBarHidden;
@synthesize preferredStatusBarUpdateAnimation = _preferredStatusBarUpdateAnimation;

@synthesize postCommentViewController = _postCommentViewController;

-(void)setAvatarImage:(UIImage*)image
{
    _avatarImage = image;
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
                                 instantiateViewControllerWithIdentifier:kLFSPostCommentViewControllerId];
    }
    return _postCommentViewController;
}

- (UIButton*)likeButton
{
    if (_likeButton == nil) {
        UIImage *img = [self imageForLikedState:self.liked];
        _likeButton = [[UIButton alloc] initWithFrame:CGRectMake(0.f, 0.f, img.size.width, img.size.height)];
        [_likeButton setImage:img forState:UIControlStateNormal];
        [_likeButton addTarget:self action:@selector(didSelectLike:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _likeButton;
}

- (UIButton*)replyButton
{
    if (_replyButton == nil) {
        UIImage *img = [UIImage imageNamed:@"ActionReply"];
        _replyButton = [[UIButton alloc] initWithFrame:CGRectMake(0.f, 0.f, img.size.width, img.size.height)];
        [_replyButton setImage:img forState:UIControlStateNormal];
        [_replyButton addTarget:self action:@selector(didSelectReply:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _replyButton;
}

- (UIImage*)imageForLikedState:(BOOL)liked
{
    return [UIImage imageNamed:(liked ? @"StateLiked" : @"StateNotLiked")];
}

- (void)setLiked:(BOOL)liked
{
    _liked = liked;
    [_likeButton setImage:[self imageForLikedState:self.liked] forState:UIControlStateNormal];
}

- (LFSBasicHTMLLabel*)basicHTMLLabel
{
    static UIFont *bodyFont = nil;
    if (_basicHTMLLabel == nil) {
        // initialize
        CGRect frame = CGRectMake(20.f,
                                  66.f,
                                  self.scrollView.bounds.size.width - 40.f,
                                  10.f);
        _basicHTMLLabel = [[LFSBasicHTMLLabel alloc] initWithFrame:frame];
        [self.scrollView addSubview:_basicHTMLLabel];
        
        // configure
        if (bodyFont == nil) {
            bodyFont = [UIFont fontWithName:@"Georgia" size:17.0f];
        }
        [_basicHTMLLabel setDelegate:self];
        [_basicHTMLLabel setFont:bodyFont];
        [_basicHTMLLabel setLineSpacing:8.5f];
    }
    return _basicHTMLLabel;
}

#pragma mark - Lifecycle

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _hideStatusBar = NO;
        _liked = NO;
        
        _postCommentViewController = nil;
        _likeButton = nil;
        _replyButton = nil;
        _basicHTMLLabel = nil;
    }
    return self;
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _hideStatusBar = NO;
        _liked = NO;
        
        _postCommentViewController = nil;
        _likeButton = nil;
        _replyButton = nil;
        _basicHTMLLabel = nil;
    }
    return self;
}

- (void)dealloc
{
    _postCommentViewController = nil;
    _likeButton = nil;
    _replyButton = nil;
    _basicHTMLLabel = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // set and format main content label
    [self.basicHTMLLabel setHTMLString:[self.contentItem contentBodyHtml]];
    CGRect basicHTMLLabelFrame = self.basicHTMLLabel.frame;
    basicHTMLLabelFrame.size = [self.basicHTMLLabel
                                sizeThatFits:CGSizeMake(basicHTMLLabelFrame.size.width, 1000.f)];
    [self.basicHTMLLabel setFrame:basicHTMLLabelFrame];
    
    CGFloat bottom = basicHTMLLabelFrame.size.height + basicHTMLLabelFrame.origin.y;
    
    // set source icon
    if (self.contentItem.author.twitterHandle) {
        [_sourceButton setImage:[UIImage imageNamed:@"SourceTwitter"]
                       forState:UIControlStateNormal];
    }
    else {
        [_sourceButton setImage:nil
                       forState:UIControlStateNormal];
    }
    
    // format author name label
    [_authorLabel setFont:titleFont];
    
    // format date label
    [_dateLabel setFont:dateFont];
    [_dateLabel setTextColor:dateColor];
    CGRect dateFrame = _dateLabel.frame;
    dateFrame.origin.y = bottom + 12.f;
    [_dateLabel setFrame:dateFrame];

    
    // set and format url link
    [_remoteUrlLabel setTextAlignment:NSTextAlignmentRight];
    [_remoteUrlLabel setCenterVertically:YES]; // necessary for iOS6
    
    NSString *twitterURLString = [self.contentItem contentTwitterUrlString];
    if (twitterURLString != nil) {
        [_remoteUrlLabel setHTMLString:
         [NSString stringWithFormat:@"<a href=\"%@\">View on Twitter ></a>",
          twitterURLString]];
    }
    CGRect profileFrame = _remoteUrlLabel.frame;
    profileFrame.origin.y = bottom + 12.f;
    [_remoteUrlLabel setFrame:profileFrame];
    
    // set toolbar frame
    CGRect toolbarFrame;
    toolbarFrame.size = CGSizeMake(self.scrollView.bounds.size.width, 44.f);
    toolbarFrame.origin = CGPointMake(0.f, dateFrame.origin.y + dateFrame.size.height + 12.f);
    _contentToolbar = [[LFSContentToolbar alloc] initWithFrame:toolbarFrame];
    [_contentToolbar setItems:
     @[
       [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil],
       [[UIBarButtonItem alloc] initWithCustomView:self.likeButton],
       [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil],
       [[UIBarButtonItem alloc] initWithCustomView:self.replyButton],
       [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil]
       ]
     ];
    [self.scrollView addSubview:_contentToolbar];
    
    // format avatar image view
    if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
        ([UIScreen mainScreen].scale == 2.0f))
    {
        // Retina display, okay to use half-points
        CGRect avatarFrame = _avatarView.frame;
        avatarFrame.size = CGSizeMake(37.5f, 37.5f);
        [_avatarView setFrame:avatarFrame];
    }
    else
    {
        // non-Retina display, do not use half-points
        CGRect avatarFrame = _avatarView.frame;
        avatarFrame.size = CGSizeMake(37.f, 37.f);
        [_avatarView setFrame:avatarFrame];
    }
    _avatarView.layer.cornerRadius = kAvatarCornerRadius;
    _avatarView.layer.masksToBounds = YES;
    
    // set author name
    NSString *authorName = self.contentItem.author.displayName;
    [_authorLabel setText:authorName];

    
    // set date
    NSString *dateTime = [[[NSDateFormatter alloc] init]
                          extendedRelativeStringFromDate:
                          [self.contentItem contentCreatedAt]];
    [_dateLabel setText:dateTime];
    
    // set avatar image
    _avatarView.image = _avatarImage;
    
    // calculate content size
    [_scrollView setContentSize:CGSizeMake(_scrollView.frame.size.width,
                                           _contentToolbar.frame.origin.y +
                                           _contentToolbar.frame.size.height + 20.f)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setStatusBarHidden:self.hideStatusBar withAnimation:UIStatusBarAnimationNone];
    //[self.navigationController setToolbarHidden:YES animated:animated];
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

#pragma mark - OHAttributedLabelDelegate
-(BOOL)attributedLabel:(OHAttributedLabel*)attributedLabel
      shouldFollowLink:(NSTextCheckingResult*)linkInfo
{
    return YES;
}

-(UIColor*)attributedLabel:(OHAttributedLabel*)attributedLabel
              colorForLink:(NSTextCheckingResult*)linkInfo
            underlineStyle:(int32_t*)underlineStyle
{
    static NSString* const kTwitterSearchPrefix = @"https://twitter.com/#!/search/realtime/";
    NSString *linkString = [linkInfo.URL absoluteString];
    if ([linkString hasPrefix:kTwitterSearchPrefix])
    {
        // Twitter hashtag
        return [UIColor grayColor];
    }
    else
    {
        // regular link
        return [UIColor blueColor];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:kReplySegue])
    {
        // Get reference to the destination view controller
        if ([segue.destinationViewController isKindOfClass:[LFSPostViewController class]])
        {
            // as there is only one piece of content in Detail View,
            // no need to check sender type here
            LFSPostViewController *vc = segue.destinationViewController;
            [vc setCollection:self.collection];
            [vc setCollectionId:self.collectionId];
            [vc setReplyToContent:self.contentItem];
        }
    }
}

#pragma mark - Events

- (IBAction)didSelectLike:(id)sender
{
    // toggle liked state
    [self setLiked:!self.liked];
}

- (IBAction)didSelectReply:(id)sender
{
    // configure destination controller
    [self.postCommentViewController setCollection:self.collection];
    [self.postCommentViewController setCollectionId:self.collectionId];
    [self.postCommentViewController setReplyToContent:self.contentItem];
    
    [self presentViewController:self.postCommentViewController animated:YES completion:nil];
}

- (IBAction)didSelectSource:(id)sender
{
    NSString *urlString = self.contentItem.author.profileUrlStringNoHashBang;
    if (urlString != nil) {
        NSURL *url = [NSURL URLWithString:self.contentItem.author.profileUrlStringNoHashBang];
        [[UIApplication sharedApplication] openURL:url];
    }
}

@end
