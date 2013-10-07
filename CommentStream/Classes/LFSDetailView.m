//
//  LFSDetailView.m
//  CommentStream
//
//  Created by Eugene Scherba on 9/26/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import <math.h>
#import <QuartzCore/QuartzCore.h>
#import <StreamHub-iOS-SDK/NSDateFormatter+RelativeTo.h>

#import "LFSDetailView.h"
#import "LFSContentToolbar.h"
#import "LFSBasicHTMLLabel.h"
#import "UILabel+Trim.h"

static const UIEdgeInsets kDetailPadding = {
    .top=20.0f, .left=20.0f, .bottom=27.0f, .right=20.0f
};

static const CGFloat kDetailContentPaddingRight = 12.0f;

// content font settings
static NSString* const kDetailContentFontName = @"Georgia";
static const CGFloat kDetailContentFontSize = 16.0f;
static const CGFloat kDetailContentLineSpacing = 8.0f;

// header font settings
static const CGFloat kDetailHeaderAttributeTopFontSize = 11.f;
static const CGFloat kDetailHeaderTitleFontSize = 15.f;
static const CGFloat kDetailHeaderSubtitleFontSize = 12.f;

// header label heights
static const CGFloat kDetailHeaderAttributeTopHeight = 10.0f;
static const CGFloat kDetailHeaderTitleHeight = 18.0f;
static const CGFloat kHeaderSubtitleHeight = 10.0f;

// TODO: calculate avatar size based on pixel image size
static const CGSize  kDetailImageViewSize = { .width=38.0f, .height=38.0f };
static const CGFloat kDetailImageCornerRadius = 4.f;
static const CGFloat kDetailImageMarginRight = 8.0f;

static const CGFloat kDetailFooterHeight = 21.0f;

static const CGFloat kDetailRemoteButtonWidth = 20.0f;
static const CGFloat kDetailRemoteButtonHeight = 20.0f;

static const CGFloat kDetailBarButtonHeight = 44.0f;
static const CGFloat kDetailBarButtonWidth = 88.0f;

static const CGFloat kDetailMinorVerticalSeparator = 12.0f;
static const CGFloat kDetailMajorVerticalSeparator = 20.0f;

static const CGFloat kDetailHeaderAccessoryRightAlpha = 0.618f;

#pragma mark -
@interface LFSDetailView ()

// UIView-specific
@property (readonly, nonatomic) LFSContentToolbar *toolbar;
@property (readonly, nonatomic) LFSBasicHTMLLabel *bodyView;

@property (readonly, nonatomic) UIButton *headerAccessoryRightView;
@property (readonly, nonatomic) UIImageView *headerImageView;

@property (readonly, nonatomic) UILabel *footerLeftView;
@property (readonly, nonatomic) LFSBasicHTMLLabel *footerRightView;

@property (readonly, nonatomic) UIButton *likeButton;
@property (readonly, nonatomic) UIButton *replyButton;

@property (readonly, nonatomic) UILabel *headerAttributeTopView;
@property (readonly, nonatomic) UILabel *headerTitleView;
@property (readonly, nonatomic) UILabel *headerSubtitleView;

@end

@implementation LFSDetailView {
    NSURL *_profileRemoteURL;
}

#pragma mark - Class methods
+ (NSDateFormatter*)dateFormatter {
    static NSDateFormatter *_dateFormatter = nil;
    if (_dateFormatter == nil) {
        _dateFormatter = [[NSDateFormatter alloc] init];
    }
    return _dateFormatter;
}

#pragma mark - Properties

@synthesize delegate = _delegate;

#pragma mark -
@synthesize isLikedByUser = _isLikedByUser;
- (void)setIsLikedByUser:(BOOL)liked
{
    [_likeButton setImage:[self imageForLikedState:liked]
                 forState:UIControlStateNormal];
}

#pragma mark -
@synthesize likeButton = _likeButton;
- (UIButton*)likeButton
{
    if (_likeButton == nil) {
        UIImage *img = [self imageForLikedState:self.isLikedByUser];
        CGRect frame = CGRectMake(0.f, 0.f,
                                  kDetailBarButtonWidth,
                                  kDetailBarButtonHeight);
        // initialize
        _likeButton = [[UIButton alloc] initWithFrame:frame];
        
        // configure
        [_likeButton setImage:img forState:UIControlStateNormal];
        [_likeButton addTarget:self action:@selector(didSelectLike:)
              forControlEvents:UIControlEventTouchUpInside];
        
        // do not add to superview...
    }
    return _likeButton;
}

#pragma mark -
@synthesize replyButton = _replyButton;
- (UIButton*)replyButton
{
    if (_replyButton == nil) {
        UIImage *img = [UIImage imageNamed:@"ActionReply"];
        CGRect frame = CGRectMake(0.f, 0.f,
                                  kDetailBarButtonWidth,
                                  kDetailBarButtonHeight);
        // initialize
        _replyButton = [[UIButton alloc] initWithFrame:frame];
        
        // configure
        [_replyButton setImage:img forState:UIControlStateNormal];
        [_replyButton addTarget:self action:@selector(didSelectReply:)
               forControlEvents:UIControlEventTouchUpInside];
        
        // do not add to superview...
    }
    return _replyButton;
}

#pragma mark -
@synthesize bodyView = _bodyView;
- (LFSBasicHTMLLabel*)bodyView
{
    if (_bodyView == nil) {

        CGRect frame = CGRectMake(kDetailPadding.left,
                                  kDetailPadding.top + kDetailImageViewSize.height + kDetailMajorVerticalSeparator,
                                  self.bounds.size.width - kDetailPadding.left - kDetailContentPaddingRight,
                                  10.f); // this could be anything
        // initialize
        _bodyView = [[LFSBasicHTMLLabel alloc] initWithFrame:frame];
        
        // configure
        [_bodyView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [_bodyView setFont:[UIFont fontWithName:kDetailContentFontName size:kDetailContentFontSize]];
        [_bodyView setLineSpacing:kDetailContentLineSpacing];
        [_bodyView setLineBreakMode:NSLineBreakByWordWrapping];
        [_bodyView setTextAlignment:NSTextAlignmentLeft];
        
        // add to superview
        [self addSubview:_bodyView];
    }
    return _bodyView;
}

#pragma mark -
@synthesize headerAccessoryRightView = _headerAccessoryRightView;
-(UIButton*)headerAccessoryRightView
{
    if (_headerAccessoryRightView == nil) {
        CGSize buttonSize = CGSizeMake(kDetailRemoteButtonWidth, kDetailRemoteButtonHeight);
        CGRect frame;
        frame.size = buttonSize;
        frame.origin = CGPointMake(self.bounds.size.width - kDetailPadding.right - buttonSize.width, kDetailPadding.top);
        // initialize
        _headerAccessoryRightView = [[UIButton alloc] initWithFrame:frame];
        
        // configure
        [_headerAccessoryRightView setAlpha:kDetailHeaderAccessoryRightAlpha];
        [_headerAccessoryRightView setContentMode:UIViewContentModeCenter];
        
        [_headerAccessoryRightView addTarget:self
                                 action:@selector(didSelectProfile:)
                       forControlEvents:UIControlEventTouchUpInside];
        [_headerAccessoryRightView
         setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin)];

        // add to superview
        [self addSubview:_headerAccessoryRightView];
    }
    return _headerAccessoryRightView;
}

#pragma mark -
@synthesize headerImageView = _headerImageView;
-(UIImageView*)headerImageView
{
    if (_headerImageView == nil) {

        CGSize avatarViewSize;
        if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)]
            && ([UIScreen mainScreen].scale == 2.f))
        {
            // Retina display, okay to use half-points
            avatarViewSize = CGSizeMake(37.5f, 37.5f);
        }
        else
        {
            // non-Retina display, do not use half-points
            avatarViewSize = CGSizeMake(37.f, 37.f);
        }
        CGRect frame;
        frame.origin = CGPointMake(kDetailPadding.left, kDetailPadding.top);
        frame.size = avatarViewSize;
        
        // initialize
        _headerImageView = [[UIImageView alloc] initWithFrame:frame];
        
        // configure
        [_headerImageView
         setAutoresizingMask:(UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin)];

        _headerImageView.layer.cornerRadius = kDetailImageCornerRadius;
        _headerImageView.layer.masksToBounds = YES;
        
        // add to superview
        [self addSubview:_headerImageView];
    }
    return _headerImageView;
}

#pragma mark -
@synthesize footerLeftView = _footerLeftView;
-(UILabel*)footerLeftView
{
    if (_footerLeftView == nil) {

        CGSize labelSize = CGSizeMake(floorf((self.bounds.size.width - kDetailPadding.left - kDetailPadding.right) / 2.f), kDetailFooterHeight);
        CGRect frame;
        frame.size = labelSize;
        frame.origin = CGPointMake(kDetailPadding.left,
                                   0.f);  // size.y will be changed in layoutSubviews
        // initialize
        _footerLeftView = [[UILabel alloc] initWithFrame:frame];
        
        // configure
        [_footerLeftView setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
        [_footerLeftView setFont:[UIFont systemFontOfSize:13.f]];
        [_footerLeftView setTextColor:[UIColor lightGrayColor]];
        
        // add to superview
        [self addSubview:_footerLeftView];
    }
    return _footerLeftView;
}

#pragma mark -
@synthesize footerRightView = _footerRightView;
- (LFSBasicHTMLLabel*)footerRightView
{
    if (_footerRightView == nil) {
        CGSize labelSize = CGSizeMake(floorf((self.bounds.size.width - kDetailPadding.left - kDetailPadding.right) / 2.f), kDetailFooterHeight);
        CGRect frame;
        frame.size = labelSize;
        frame.origin = CGPointMake(self.bounds.size.width - kDetailPadding.right - labelSize.width,
                                   0.f); // size.y will be changed in layoutSubviews
        
        // initialize
        _footerRightView = [[LFSBasicHTMLLabel alloc] initWithFrame:frame];
        
        // configure
        [_footerRightView
         setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin)];

        [_footerRightView setCenterVertically:YES]; // necessary for iOS6
        [_footerRightView setFont:[UIFont systemFontOfSize:13.f]];
        [_footerRightView setTextAlignment:NSTextAlignmentRight];
        [_footerRightView setLineBreakMode:NSLineBreakByWordWrapping];
        [_footerRightView setTextAlignment:NSTextAlignmentRight];
        
        // add to superview
        [self addSubview:_footerRightView];
    }
    return _footerRightView;
}

#pragma mark -
@synthesize headerAttributeTopView = _headerAttributeTopView;
- (UILabel*)headerAttributeTopView
{
    if (_headerAttributeTopView == nil) {
        CGFloat leftColumnWidth = kDetailPadding.left + kDetailImageViewSize.width + kDetailImageMarginRight;
        CGFloat rightColumnWidth = kDetailRemoteButtonWidth + kDetailPadding.right;
        CGSize labelSize = CGSizeMake(self.bounds.size.width - leftColumnWidth - rightColumnWidth, kDetailHeaderAttributeTopHeight);
        CGRect frame;
        frame.size = labelSize;
        frame.origin = CGPointMake(leftColumnWidth,
                                   kDetailPadding.top); // size.y will be changed in layoutSubviews
        // initialize
        _headerAttributeTopView = [[UILabel alloc] initWithFrame:frame];
        
        // configure
        [_headerAttributeTopView
         setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin)];
        [_headerAttributeTopView setFont:[UIFont systemFontOfSize:kDetailHeaderAttributeTopFontSize]];
        [_headerAttributeTopView setTextColor:[UIColor blueColor]];
        
        // add to superview
        [self addSubview:_headerAttributeTopView];
    }
    return _headerAttributeTopView;
}

#pragma mark -
@synthesize headerTitleView = _headerTitleView;
- (UILabel*)headerTitleView
{
    if (_headerTitleView == nil) {
        CGFloat leftColumnWidth = kDetailPadding.left + kDetailImageViewSize.width + kDetailImageMarginRight;
        CGFloat rightColumnWidth = kDetailRemoteButtonWidth + kDetailPadding.right;
        CGSize labelSize = CGSizeMake(self.bounds.size.width - leftColumnWidth - rightColumnWidth, kDetailHeaderTitleHeight);
        CGRect frame;
        frame.size = labelSize;
        frame.origin = CGPointMake(leftColumnWidth,
                                   kDetailPadding.top); // size.y will be changed in layoutSubviews
        // initialize
        _headerTitleView = [[UILabel alloc] initWithFrame:frame];
        
        // configure
        [_headerTitleView
         setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin)];
        [_headerTitleView setFont:[UIFont boldSystemFontOfSize:kDetailHeaderTitleFontSize]];
        
        // add to superview
        [self addSubview:_headerTitleView];
    }
    return _headerTitleView;
}

#pragma mark -
@synthesize headerSubtitleView = _headerSubtitleView;
- (UILabel*)headerSubtitleView
{
    if (_headerSubtitleView == nil) {
        CGFloat leftColumnWidth = kDetailPadding.left + kDetailImageViewSize.width + kDetailImageMarginRight;
        CGFloat rightColumnWidth = kDetailRemoteButtonWidth + kDetailPadding.right;
        CGSize labelSize = CGSizeMake(self.bounds.size.width - leftColumnWidth - rightColumnWidth, kHeaderSubtitleHeight);
        CGRect frame;
        frame.size = labelSize;
        frame.origin = CGPointMake(leftColumnWidth,
                                   kDetailPadding.top); // size.y will be changed in layoutSubviews
        // initialize
        _headerSubtitleView = [[UILabel alloc] initWithFrame:frame];
        
        // configure
        [_headerSubtitleView
         setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin)];
        [_headerSubtitleView setFont:[UIFont systemFontOfSize:kDetailHeaderSubtitleFontSize]];
        [_headerSubtitleView setTextColor:[UIColor grayColor]];
        
        // add to superview
        [self addSubview:_headerSubtitleView];
    }
    return _headerSubtitleView;
}

#pragma mark -
@synthesize toolbar = _toolbar;
-(LFSContentToolbar*)toolbar
{
    if (_toolbar == nil) {

        CGRect frame = CGRectZero;
        frame.size = CGSizeMake(self.bounds.size.width, kDetailBarButtonHeight);
        
        // initialize
        _toolbar = [[LFSContentToolbar alloc] initWithFrame:frame];
        
        // configure
        [_toolbar setItems:
         @[
           [[UIBarButtonItem alloc]
            initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
            target:self action:nil],
           
           [[UIBarButtonItem alloc]
            initWithCustomView:self.likeButton],
           
           [[UIBarButtonItem alloc]
            initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
            target:self action:nil],
           
           [[UIBarButtonItem alloc]
            initWithCustomView:self.replyButton],
           
           [[UIBarButtonItem alloc]
            initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
            target:self action:nil]
           ]
         ];
        [_toolbar setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        
        // add to superview
        [self addSubview:_toolbar];
    }
    return _toolbar;
}

#pragma mark - Private overrides
-(void)layoutSubviews
{
    // layout main content label
    CGRect basicHTMLLabelFrame = self.bodyView.frame;
    CGFloat contentWidth = self.bounds.size.width - kDetailPadding.left - kDetailContentPaddingRight;
    basicHTMLLabelFrame.size = [self contentSizeThatFits:
                                CGSizeMake(contentWidth, CGFLOAT_MAX)];
    [self.bodyView setFrame:basicHTMLLabelFrame];
    
    CGFloat bottom = basicHTMLLabelFrame.size.height + basicHTMLLabelFrame.origin.y;
    
    // start with the header
    [self layoutHeader];
    
    // layout url link
    LFSTriple *contentRemote = self.contentRemote;
    if (contentRemote != nil) {
        [self.footerRightView setHTMLString:
         [NSString stringWithFormat:@"<a href=\"%@\">%@</a>",
          [contentRemote detailString],
          [contentRemote mainString]]];
        CGRect remoteUrlFrame = self.footerRightView.frame;
        remoteUrlFrame.origin.y = bottom + kDetailMinorVerticalSeparator;
        [self.footerRightView setFrame:remoteUrlFrame];
    }
    
    // layout source icon
    LFSTriple *profileRemote = self.profileRemote;
    if (profileRemote != nil) {
        [self.headerAccessoryRightView setImage:profileRemote.iconImage
                                  forState:UIControlStateNormal];
        _profileRemoteURL = [NSURL URLWithString:profileRemote.detailString];
    }

    // layout date label
    CGRect dateFrame = self.footerLeftView.frame;
    dateFrame.origin.y = bottom + kDetailMinorVerticalSeparator;
    [self.footerLeftView setFrame:dateFrame];
    [self.footerLeftView setText:[[[self class] dateFormatter] extendedRelativeStringFromDate:self.contentDate]];
    
    // layout toolbar frame
    CGRect toolbarFrame = self.toolbar.frame;
    toolbarFrame.origin = CGPointMake(0.f,
                                      dateFrame.origin.y +
                                      dateFrame.size.height +
                                      kDetailMinorVerticalSeparator);
    [self.toolbar setFrame:toolbarFrame];
}

-(CGSize)sizeThatFits:(CGSize)size
{
    CGFloat totalWidthInset = kDetailPadding.left + kDetailContentPaddingRight;
    CGFloat totalHeightInset = (kDetailPadding.bottom
                                + kDetailBarButtonHeight
                                + kDetailMinorVerticalSeparator
                                + kDetailFooterHeight
                                + kDetailMinorVerticalSeparator
                                
                                + kDetailMajorVerticalSeparator
                                + kDetailImageViewSize.height
                                + kDetailPadding.top);
    CGSize contentSize = [self contentSizeThatFits:
                          CGSizeMake(size.width - totalWidthInset,
                                     CGFLOAT_MAX)];
    contentSize.width += totalWidthInset;
    contentSize.height += totalHeightInset;
    return contentSize;
}

#pragma mark - Private methods

- (UIImage*)imageForLikedState:(BOOL)liked
{
    return [UIImage imageNamed:(liked ? @"StateLiked" : @"StateNotLiked")];
}

-(void)layoutHeader
{
    // layout header title label
    //
    // Note: preciese layout depends on whether we have subtitle field
    // (i.e. twitter handle)
    
    LFSHeader *profileLocal = self.profileLocal;
    NSString *headerTitle = profileLocal.mainString;
    NSString *headerSubtitle = profileLocal.detailString;
    NSString *headerAccessory = profileLocal.attributeString;
    
    if (headerTitle && !headerSubtitle && !headerAccessory)
    {
        // display one string
        [self.headerTitleView setText:headerTitle];
        [self.headerTitleView resizeVerticalCenterRightTrim];
    }
    else if (headerTitle && headerSubtitle && !headerAccessory)
    {
        // full name + twitter handle
        
        CGRect headerTitleFrame = self.headerTitleView.frame;
        CGRect headerSubtitleFrame = self.headerSubtitleView.frame;
        
        CGFloat separator = floorf((kDetailImageViewSize.height
                                    - headerTitleFrame.size.height
                                    - headerSubtitleFrame.size.height) / 3.f);
        
        headerTitleFrame.origin.y = kDetailPadding.top + separator;
        headerSubtitleFrame.origin.y = (kDetailPadding.top
                                        + separator
                                        + headerTitleFrame.size.height
                                        + separator);
        
        [self.headerTitleView setFrame:headerTitleFrame];
        [self.headerTitleView setText:headerTitle];
        [self.headerTitleView resizeVerticalCenterRightTrim];
        
        [self.headerSubtitleView setFrame:headerSubtitleFrame];
        [self.headerSubtitleView setText:headerSubtitle];
        [self.headerSubtitleView resizeVerticalCenterRightTrim];
    }
    else if (headerTitle && !headerSubtitle && headerAccessory)
    {
        // attribute + full name
        
        CGRect headerAttributeTopFrame = self.headerAttributeTopView.frame;
        CGRect headerTitleFrame = self.headerTitleView.frame;
        
        CGFloat separator = floorf((kDetailImageViewSize.height
                                    - headerTitleFrame.size.height
                                    - headerAttributeTopFrame.size.height) / 3.f);
        
        
        headerAttributeTopFrame.origin.y = (kDetailPadding.top + separator);
        headerTitleFrame.origin.y = (kDetailPadding.top
                                     + separator
                                     + headerAttributeTopFrame.size.height
                                     + separator);
        
        [self.headerAttributeTopView setFrame:headerAttributeTopFrame];
        [self.headerAttributeTopView setText:headerAccessory];
        [self.headerAttributeTopView resizeVerticalCenterRightTrim];
        
        [self.headerTitleView setFrame:headerTitleFrame];
        [self.headerTitleView setText:headerTitle];
        [self.headerTitleView resizeVerticalCenterRightTrim];
    }
    else if (headerTitle && headerSubtitle && headerAccessory)
    {
        // attribute + full name + twitter handle
        
        CGRect headerAttributeTopFrame = self.headerAttributeTopView.frame;
        CGRect headerTitleFrame = self.headerTitleView.frame;
        CGRect headerSubtitleFrame = self.headerSubtitleView.frame;
        
        CGFloat separator = floorf((kDetailImageViewSize.height
                                    - headerTitleFrame.size.height
                                    - headerAttributeTopFrame.size.height
                                    - headerSubtitleFrame.size.height) / 4.f);
        
        
        headerAttributeTopFrame.origin.y = (kDetailPadding.top + separator);
        headerTitleFrame.origin.y = (kDetailPadding.top
                                     + separator
                                     + headerAttributeTopFrame.size.height
                                     + separator);
        
        headerSubtitleFrame.origin.y = (kDetailPadding.top
                                        + separator
                                        + headerAttributeTopFrame.size.height
                                        + separator
                                        + headerTitleFrame.size.height
                                        + separator);
        
        [self.headerAttributeTopView setFrame:headerAttributeTopFrame];
        [self.headerAttributeTopView setText:headerAccessory];
        [self.headerAttributeTopView resizeVerticalCenterRightTrim];
        
        [self.headerTitleView setFrame:headerTitleFrame];
        [self.headerTitleView setText:headerTitle];
        [self.headerTitleView resizeVerticalCenterRightTrim];
        
        [self.headerSubtitleView setFrame:headerSubtitleFrame];
        [self.headerSubtitleView setText:headerSubtitle];
        [self.headerSubtitleView resizeVerticalCenterRightTrim];
    }
    else {
        // no header
    }

    // layout avatar view
    [self.headerImageView setImage:profileLocal.iconImage];
    
}

-(CGSize)contentSizeThatFits:(CGSize)size
{
    [self.bodyView setHTMLString:self.contentBodyHtml];
    return [self.bodyView sizeThatFits:size];
}

#pragma mark - Lifecycle

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _likeButton = nil;
        _replyButton = nil;
        _bodyView = nil;
        _footerRightView = nil;
        _headerAccessoryRightView = nil;
        _headerImageView = nil;
        _footerLeftView = nil;
        _headerTitleView = nil;
        
        _profileRemoteURL = nil;
        
        _isLikedByUser = NO;
        
        
        _profileLocal = nil;
        _profileRemote = nil;
        _contentRemote = nil;
        _contentBodyHtml = nil;
        
        _contentDate = nil;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _likeButton = nil;
        _replyButton = nil;
        _bodyView = nil;
        _footerRightView = nil;
        _headerAccessoryRightView = nil;
        _headerImageView = nil;
        _footerLeftView = nil;
        _headerTitleView = nil;
        
        _profileRemoteURL = nil;
        
        _isLikedByUser = NO;
        
        _profileLocal = nil;
        _profileRemote = nil;
        _contentRemote = nil;
        _contentBodyHtml = nil;
        
        _contentDate = nil;
    }
    return self;
}

- (void)dealloc
{
    _likeButton = nil;
    _replyButton = nil;
    _bodyView = nil;
    _footerRightView = nil;
    _headerAccessoryRightView = nil;
    _headerImageView = nil;
    _footerLeftView = nil;
    _headerTitleView = nil;
    
    _profileRemoteURL = nil;
    
    _profileLocal = nil;
    _profileRemote = nil;
    _contentRemote = nil;
    _contentBodyHtml = nil;
    
    _contentDate = nil;
}

#pragma mark - Actions
- (IBAction)didSelectLike:(id)sender
{
    // simply pass the action to the delegate
    [self.delegate didSelectLike:sender];
}

- (IBAction)didSelectReply:(id)sender
{
    // simply pass the action to the delegate
    [self.delegate didSelectReply:sender];
}

- (IBAction)didSelectProfile:(id)sender
{
    // this action we handle ourselves
    if (_profileRemoteURL != nil) {
        [[UIApplication sharedApplication] openURL:_profileRemoteURL];
    }
}

@end
