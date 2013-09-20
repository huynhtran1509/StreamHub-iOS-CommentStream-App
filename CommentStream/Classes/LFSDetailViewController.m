//
//  LFSDetailViewController.m
//  CommentStream
//
//  Created by Eugene Scherba on 9/13/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import <StreamHub-iOS-SDK/NSDateFormatter+RelativeTo.h>
#import "LFSDetailViewController.h"

@interface LFSDetailViewController ()

// render iOS7 status bar methods as writable properties
@property (nonatomic, assign) BOOL prefersStatusBarHidden;
@property (nonatomic, assign) UIStatusBarAnimation preferredStatusBarUpdateAnimation;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet LFSBasicHTMLLabel *basicHTMLLabel;
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@end

static const CGFloat kAvatarCornerRadius = 4;

@implementation LFSDetailViewController {
    UIImage *_avatarImage;
}

#pragma mark - Class methods
static UIFont *titleFont = nil;
static UIFont *noteFont = nil;
static UIColor *noteColor = nil;
static UIFont *bodyFont = nil;

+ (void)initialize {
    if(self == [LFSDetailViewController class]) {
        titleFont = [UIFont fontWithName:@"AvenirNextCondensed-DemiBold" size:16.0f];
        bodyFont = [UIFont fontWithName:@"Georgia" size:16.0f];
        noteFont = [UIFont fontWithName:@"Futura-MediumItalic" size:12.0f];
        noteColor = [UIColor grayColor];
    }
}

#pragma mark - Properties

@synthesize basicHTMLLabel = _basicHTMLLabel;

@synthesize avatarView = _avatarView;
@synthesize authorLabel = _authorLabel;
@synthesize dateLabel = _dateLabel;

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
    [self.basicHTMLLabel setHTMLString:[self.contentItem objectForKey:@"bodyHtml"]];
    CGRect oldContentFrame = self.basicHTMLLabel.frame;
    CGSize maxSize = oldContentFrame.size;
    maxSize.height = 1000.f;
    CGSize neededSize = [self.basicHTMLLabel sizeThatFits:maxSize];
    CGFloat offset = neededSize.height - oldContentFrame.size.height;
    [self.basicHTMLLabel setFrame:CGRectMake(oldContentFrame.origin.x,
                                             oldContentFrame.origin.y,
                                             neededSize.width,
                                             neededSize.height)];
    
    
    // format author name label
    [_authorLabel setFont:titleFont];
    
    // format date label
    [_dateLabel setFont:noteFont];
    [_dateLabel setTextColor:noteColor];
    CGPoint newDateCenter = _dateLabel.center;
    newDateCenter.y += offset;
    [_dateLabel setCenter:newDateCenter];
    
    // format avatar image view
    _avatarView.layer.cornerRadius = kAvatarCornerRadius;
    _avatarView.layer.masksToBounds = YES;
    
    // set author name
    NSString *authorName = [self.authorItem objectForKey:@"displayName"];
    [_authorLabel setText:authorName];
    
    // set date
    NSTimeInterval timeStamp = [[self.contentItem objectForKey:@"createdAt"] doubleValue];
    NSString *dateTime = [[[NSDateFormatter alloc] init]
                          extendedRelativeStringFromDate:
                          [NSDate dateWithTimeIntervalSince1970:timeStamp]];
    [_dateLabel setText:dateTime];
    
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
    return [UIColor blueColor];
}

@end
