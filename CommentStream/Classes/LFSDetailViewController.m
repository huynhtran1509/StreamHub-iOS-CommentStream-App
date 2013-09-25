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
#import "LFSNewCommentViewController.h"

@interface LFSDetailViewController ()

// render iOS7 status bar methods as writable properties
@property (nonatomic, assign) BOOL prefersStatusBarHidden;
@property (nonatomic, assign) UIStatusBarAnimation preferredStatusBarUpdateAnimation;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet LFSBasicHTMLLabel *basicHTMLLabel;
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet LFSBasicHTMLLabel *remoteUrlLabel;
@property (weak, nonatomic) IBOutlet UIButton *sourceButton;
@property (weak, nonatomic) IBOutlet UIToolbar *contentToolbar;
- (IBAction)didSelectSource:(id)sender;

@end

static const CGFloat kAvatarCornerRadius = 4;

static NSString* const kReplySegue = @"replyTo";

@implementation LFSDetailViewController {
    UIImage *_avatarImage;
}

#pragma mark - Class methods
static UIFont *titleFont = nil;
static UIFont *bodyFont = nil;
static UIFont *dateFont = nil;
static UIColor *dateColor = nil;

+ (void)initialize {
    if(self == [LFSDetailViewController class]) {
        titleFont = [UIFont boldSystemFontOfSize:16.f];
        bodyFont = [UIFont fontWithName:@"Georgia" size:17.0f];
        dateFont = [UIFont systemFontOfSize:13.f];
        dateColor = [UIColor lightGrayColor];
    }
}

#pragma mark - Properties

@synthesize basicHTMLLabel = _basicHTMLLabel;

@synthesize avatarView = _avatarView;
@synthesize authorLabel = _authorLabel;
@synthesize dateLabel = _dateLabel;
@synthesize remoteUrlLabel = _remoteUrlLabel;

// render iOS7 status bar methods as writable properties
@synthesize prefersStatusBarHidden = _prefersStatusBarHidden;
@synthesize preferredStatusBarUpdateAnimation = _preferredStatusBarUpdateAnimation;

-(void)setAvatarImage:(UIImage*)image
{
    _avatarImage = image;
}

#pragma mark - UIViewController

// Hide Status Bar
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // set main content label
    [self.basicHTMLLabel setDelegate:self];
    [self.basicHTMLLabel setFont:bodyFont];
    [self.basicHTMLLabel setLineSpacing:8.5f];
    
    [self.basicHTMLLabel setHTMLString:[self.contentItem contentBodyHtml]];
    CGRect oldContentFrame = self.basicHTMLLabel.frame;
    CGSize maxSize = oldContentFrame.size;
    maxSize.height = 1000.f;
    CGSize neededSize = [self.basicHTMLLabel sizeThatFits:maxSize];
    CGFloat bottom = neededSize.height + oldContentFrame.origin.y;
    [self.basicHTMLLabel setFrame:CGRectMake(oldContentFrame.origin.x,
                                             oldContentFrame.origin.y,
                                             neededSize.width,
                                             neededSize.height)];
    
    // set source icon
    if (self.contentItem.author.twitterHandle) {
        UIImage *sourceImage = [UIImage imageNamed:@"SourceTwitter"];

        CGRect iconFrame = self.sourceButton.frame;
        iconFrame.origin = CGPointMake(self.view.frame.size.width - 40.f, self.view.frame.origin.y + 20.f);
        [self.sourceButton setFrame:iconFrame];
        [self.sourceButton setImage:sourceImage forState:UIControlStateNormal];
    }
    else {
        [self.sourceButton setImage:nil forState:UIControlStateNormal];
    }
    
    // format author name label
    [_authorLabel setFont:titleFont];
    
    // format date label
    [_dateLabel setFont:dateFont];
    [_dateLabel setTextColor:dateColor];
    CGRect dateFrame = _dateLabel.frame;
    dateFrame.origin = CGPointMake(dateFrame.origin.x, bottom + 12.f);
    [_dateLabel setFrame:dateFrame];

    // format url link
    CGRect profileFrame = _remoteUrlLabel.frame;
    profileFrame.origin = CGPointMake(profileFrame.origin.x, bottom + 12.f);
    [_remoteUrlLabel setFrame:profileFrame];
    [_remoteUrlLabel setTextAlignment:NSTextAlignmentRight];
    
    // set toolbar frame
    CGRect toolbarFrame = self.contentToolbar.frame;
    toolbarFrame.origin.y = dateFrame.origin.y + dateFrame.size.height + 12.f;
    self.contentToolbar.frame = toolbarFrame;
    
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
    
    // set profile link
    NSString *twitterURLString = [self.contentItem contentTwitterUrlString];
    if (twitterURLString != nil) {
        [_remoteUrlLabel setHTMLString:
         [NSString stringWithFormat:@"<a href=\"%@\">View on Twitter ></a>",
          twitterURLString]];
    }
    
    // set avatar image
    _avatarView.image = _avatarImage;
    
    // calculate content size
    CGFloat contentHeight = _dateLabel.frame.origin.y + _dateLabel.frame.size.height + 20.f;
    CGSize contentSize = CGSizeMake(self.scrollView.frame.size.width, contentHeight);
    [self.scrollView setContentSize:contentSize];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //[self setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
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
        if ([segue.destinationViewController isKindOfClass:[LFSNewCommentViewController class]])
        {
            // as there is only one piece of content in Detail View,
            // no need to check sender type here
            LFSNewCommentViewController *vc = segue.destinationViewController;
            [vc setCollection:self.collection];
            [vc setCollectionId:self.collectionId];
            [vc setReplyToContent:self.contentItem];
        }
    }
}

#pragma mark - Events
- (IBAction)didSelectSource:(id)sender
{
    NSString *urlString = self.contentItem.author.profileUrlStringNoHashBang;
    if (urlString != nil) {
        NSURL *url = [NSURL URLWithString:self.contentItem.author.profileUrlStringNoHashBang];
        [[UIApplication sharedApplication] openURL:url];
    }
}

@end
