//
//  LFSDetailView.m
//  CommentStream
//
//  Created by Eugene Scherba on 9/26/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import <math.h>
#import <QuartzCore/QuartzCore.h>

#import "LFSDetailView.h"
#import "LFSContentToolbar.h"
#import "LFSBasicHTMLLabel.h"
#import "UILabel+VerticalAlign.h"

@implementation LFSTriple
@synthesize detailString = _detailString;
@synthesize iconImage = _iconImage;
@synthesize mainString = _mainString;

-(id)initWithDetailString:(NSString*)detailString
               mainString:(NSString*)mainString
                iconImage:(UIImage*)iconImage;
{
    self = [super init];
    if (self) {
        _detailString = detailString;
        _iconImage = iconImage;
        _mainString = mainString;
    }
    return self;
}

-(id)init
{
    self = [self initWithDetailString:nil mainString:nil iconImage:nil];
    return self;
}

@end

static const CGFloat kPaddingLeft = 20.0f;
static const CGFloat kPaddingTop = 20.0f;
static const CGFloat kPaddingRight = 20.0f;
static const CGFloat kPaddingBottom = 27.0f;

static const CGFloat kContentPaddingRight = 12.0f;
static const CGFloat kContentLineSpacing = 8.0f;
static const CGFloat kHeaderHeight = 38.0f;
static const CGFloat kAvatarMarginRight = 8.0f;
static const CGFloat kDetailRowHeight = 21.0f;

static const CGFloat kRemoteButtonWidth = 20.0f;
static const CGFloat kRemoteButtonHeight = 20.0f;

static const CGFloat kAuthorAttributeHeight = 10.0f;
static const CGFloat kAuthorNameHeight = 18.0f;
static const CGFloat kAuthorDetailHeight = 10.0f;

static const CGFloat kToolbarHeight = 44.0f;

static const CGFloat kMinorVerticalSeparator = 12.0f;
static const CGFloat kMajorVerticalSeparator = 20.0f;

@implementation LFSHeader

@synthesize attributeString = _attributeString;
@synthesize detailString = _detailString;
@synthesize iconImage = _iconImage;
@synthesize mainString = _mainString;

-(id)initWithDetailString:(NSString*)detailString
          attributeString:(NSString*)attributeString
               mainString:(NSString*)mainString
                iconImage:(UIImage*)iconImage;
{
    self = [super init];
    if (self) {
        _detailString = detailString;
        _attributeString = attributeString;
        _iconImage = iconImage;
        _mainString = mainString;
    }
    return self;
}

-(id)init
{
    self = [self initWithDetailString:nil attributeString:nil mainString:nil iconImage:nil];
    return self;
}
@end

#pragma mark -
@interface LFSDetailView ()

// UIView-specific
@property (strong, nonatomic) LFSContentToolbar *contentToolbar;
@property (strong, nonatomic) LFSBasicHTMLLabel *contentBodyLabel;
@property (strong, nonatomic) LFSBasicHTMLLabel *remoteUrlLabel;
@property (strong, nonatomic) UIButton *authorProfileButton;
@property (strong, nonatomic) UIImageView *avatarView;
@property (strong, nonatomic) UILabel *dateLabel;
@property (strong, nonatomic) UIButton *likeButton;
@property (strong, nonatomic) UIButton *replyButton;

@property (strong, nonatomic) UILabel *authorAttributeLabel;
@property (strong, nonatomic) UILabel *authorNameLabel;
@property (strong, nonatomic) UILabel *authorDetailLabel;

@end

@implementation LFSDetailView {
    NSURL *_profileRemoteURL;
}

#pragma mark - Properties

// UIView-specific
@synthesize contentBodyLabel = _contentBodyLabel;
@synthesize avatarView = _avatarView;
@synthesize dateLabel = _dateLabel;
@synthesize remoteUrlLabel = _remoteUrlLabel;
@synthesize contentToolbar = _contentToolbar;
@synthesize authorProfileButton = _authorProfileButton;
@synthesize likeButton = _likeButton;
@synthesize replyButton = _replyButton;

@synthesize authorNameLabel = _authorNameLabel;
@synthesize authorAttributeLabel = _authorAttributeLabel;
@synthesize authorDetailLabel = _authorDetailLabel;

@synthesize contentLikedByUser = _contentLikedByUser;

#pragma mark -
- (UIButton*)likeButton
{
    if (_likeButton == nil) {
        UIImage *img = [self imageForLikedState:self.contentLikedByUser];
        _likeButton = [[UIButton alloc]
                       initWithFrame:CGRectMake(0.f, 0.f, img.size.width, img.size.height)];
        [_likeButton setImage:img forState:UIControlStateNormal];
        [_likeButton addTarget:self action:@selector(didSelectLike:)
              forControlEvents:UIControlEventTouchUpInside];
    }
    return _likeButton;
}

- (UIButton*)replyButton
{
    if (_replyButton == nil) {
        UIImage *img = [UIImage imageNamed:@"ActionReply"];
        _replyButton = [[UIButton alloc]
                        initWithFrame:CGRectMake(0.f, 0.f, img.size.width, img.size.height)];
        [_replyButton setImage:img forState:UIControlStateNormal];
        [_replyButton addTarget:self action:@selector(didSelectReply:)
               forControlEvents:UIControlEventTouchUpInside];
    }
    return _replyButton;
}

- (UIImage*)imageForLikedState:(BOOL)liked
{
    return [UIImage imageNamed:(liked ? @"StateLiked" : @"StateNotLiked")];
}

- (void)setContentLikedByUser:(BOOL)liked
{
    [_likeButton setImage:[self imageForLikedState:liked]
                 forState:UIControlStateNormal];
}

- (LFSBasicHTMLLabel*)contentBodyLabel
{
    if (_contentBodyLabel == nil) {
        // initialize
        CGRect frame = CGRectMake(kPaddingLeft,
                                  kPaddingTop + kHeaderHeight + kMajorVerticalSeparator,
                                  self.bounds.size.width - kPaddingLeft - kContentPaddingRight,
                                  10.f); // this could be anything
        _contentBodyLabel = [[LFSBasicHTMLLabel alloc] initWithFrame:frame];
        [_contentBodyLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [self addSubview:_contentBodyLabel];
        
        // configure
        [_contentBodyLabel setFont:[UIFont fontWithName:@"Georgia" size:16.0f]];
        [_contentBodyLabel setLineSpacing:kContentLineSpacing];
        [_contentBodyLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [_contentBodyLabel setTextAlignment:NSTextAlignmentLeft];
    }
    return _contentBodyLabel;
}

-(UIButton*)authorProfileButton
{
    if (_authorProfileButton == nil) {
        // initialize
        CGSize buttonSize = CGSizeMake(kRemoteButtonWidth, kRemoteButtonHeight);
        CGRect frame;
        frame.size = buttonSize;
        frame.origin = CGPointMake(self.bounds.size.width - kPaddingRight - buttonSize.width,
                                   kPaddingTop);
        _authorProfileButton = [[UIButton alloc] initWithFrame:frame];
        [_authorProfileButton addTarget:self
                                 action:@selector(didSelectProfile:)
                       forControlEvents:UIControlEventTouchUpInside];
        [_authorProfileButton setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin
                                                   | UIViewAutoresizingFlexibleBottomMargin)];
        [self addSubview:_authorProfileButton];
        
        // configure
    }
    return _authorProfileButton;
}

-(UIImageView*)avatarView
{
    static const CGFloat kAvatarCornerRadius = 4.f;
    
    if (_avatarView == nil) {
        // initialize
        CGSize avatarViewSize;
        if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)]
            && ([UIScreen mainScreen].scale == 2.0f))
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
        frame.origin = CGPointMake(kPaddingLeft, kPaddingTop);
        frame.size = avatarViewSize;
        
        _avatarView = [[UIImageView alloc] initWithFrame:frame];
        [_avatarView setAutoresizingMask:(UIViewAutoresizingFlexibleRightMargin
                                          | UIViewAutoresizingFlexibleBottomMargin)];
        [self addSubview:_avatarView];
        
        // configure
        _avatarView.layer.cornerRadius = kAvatarCornerRadius;
        _avatarView.layer.masksToBounds = YES;
    }
    return _avatarView;
}

-(UILabel*)dateLabel
{
    if (_dateLabel == nil) {
        // initialize
        CGSize labelSize = CGSizeMake(floorf((self.bounds.size.width - kPaddingLeft - kPaddingRight) / 2.f),
                                      kDetailRowHeight);
        CGRect frame;
        frame.size = labelSize;
        frame.origin = CGPointMake(kPaddingLeft,
                                   76.f); // `y' could be anything
        _dateLabel = [[UILabel alloc] initWithFrame:frame];
        [_dateLabel setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
        [self addSubview:_dateLabel];
        
        // configure
        [_dateLabel setFont:[UIFont systemFontOfSize:13.f]];
        [_dateLabel setTextColor:[UIColor lightGrayColor]];
    }
    return _dateLabel;
}

- (LFSBasicHTMLLabel*)remoteUrlLabel
{
    if (_remoteUrlLabel == nil) {
        // initialize
        CGSize labelSize = CGSizeMake(floorf((self.bounds.size.width - kPaddingLeft - kPaddingRight) / 2.f), kDetailRowHeight);
        CGRect frame;
        frame.size = labelSize;
        frame.origin = CGPointMake(self.bounds.size.width - kPaddingRight - labelSize.width,
                                   76.f); // `y' could be anything
        
        _remoteUrlLabel = [[LFSBasicHTMLLabel alloc] initWithFrame:frame];
        [_remoteUrlLabel setAutoresizingMask:(UIViewAutoresizingFlexibleWidth
                                              | UIViewAutoresizingFlexibleLeftMargin)];
        [self addSubview:_remoteUrlLabel];
        
        // configure
        [_remoteUrlLabel setCenterVertically:YES]; // necessary for iOS6
        [_remoteUrlLabel setFont:[UIFont systemFontOfSize:13.f]];
        [_remoteUrlLabel setTextAlignment:NSTextAlignmentRight];
        [_remoteUrlLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [_remoteUrlLabel setTextAlignment:NSTextAlignmentRight];
    }
    return _remoteUrlLabel;
}

- (UILabel*)authorAttributeLabel
{
    if (_authorAttributeLabel == nil) {
        // initialize
        CGFloat leftColumnWidth = kPaddingLeft + kHeaderHeight + kAvatarMarginRight;
        CGFloat rightColumnWidth = kRemoteButtonWidth + kPaddingRight;
        CGSize labelSize = CGSizeMake(self.bounds.size.width - leftColumnWidth - rightColumnWidth, kAuthorAttributeHeight);
        CGRect frame;
        frame.size = labelSize;
        frame.origin = CGPointMake(leftColumnWidth,
                                   kPaddingTop); // `y' not important here
        
        _authorAttributeLabel = [[UILabel alloc] initWithFrame:frame];
        _authorAttributeLabel.autoresizingMask = (UIViewAutoresizingFlexibleWidth
                                                  | UIViewAutoresizingFlexibleBottomMargin);
        [self addSubview:_authorAttributeLabel];
        
        // configure
        [_authorAttributeLabel setFont:[UIFont systemFontOfSize:11.f]];
        [_authorAttributeLabel setTextColor:[UIColor blueColor]];
    }
    return _authorAttributeLabel;
}

- (UILabel*)authorNameLabel
{
    if (_authorNameLabel == nil) {
        // initialize
        CGFloat leftColumnWidth = kPaddingLeft + kHeaderHeight + kAvatarMarginRight;
        CGFloat rightColumnWidth = kRemoteButtonWidth + kPaddingRight;
        CGSize labelSize = CGSizeMake(self.bounds.size.width - leftColumnWidth - rightColumnWidth, kAuthorNameHeight);
        CGRect frame;
        frame.size = labelSize;
        frame.origin = CGPointMake(leftColumnWidth,
                                   kPaddingTop + kAuthorAttributeHeight); // `y' not important here
        
        _authorNameLabel = [[UILabel alloc] initWithFrame:frame];
        _authorNameLabel.autoresizingMask = (UIViewAutoresizingFlexibleWidth
                                         | UIViewAutoresizingFlexibleBottomMargin);
        [self addSubview:_authorNameLabel];
        
        // configure
        [_authorNameLabel setFont:[UIFont boldSystemFontOfSize:15.f]];
    }
    return _authorNameLabel;
}

- (UILabel*)authorDetailLabel
{
    if (_authorDetailLabel == nil) {
        // initialize
        CGFloat leftColumnWidth = kPaddingLeft + kHeaderHeight + kAvatarMarginRight;
        CGFloat rightColumnWidth = kRemoteButtonWidth + kPaddingRight;
        CGSize labelSize = CGSizeMake(self.bounds.size.width - leftColumnWidth - rightColumnWidth, kAuthorDetailHeight);
        CGRect frame;
        frame.size = labelSize;
        frame.origin = CGPointMake(leftColumnWidth,
                                   kPaddingTop + kAuthorAttributeHeight + kAuthorNameHeight); // `y' not important here
        
        _authorDetailLabel = [[UILabel alloc] initWithFrame:frame];
        _authorDetailLabel.autoresizingMask = (UIViewAutoresizingFlexibleWidth
                                         | UIViewAutoresizingFlexibleBottomMargin);
        [self addSubview:_authorDetailLabel];
        
        // configure
        [_authorDetailLabel setFont:[UIFont systemFontOfSize:12.f]];
        [_authorDetailLabel setTextColor:[UIColor grayColor]];
    }
    return _authorDetailLabel;
}

-(LFSContentToolbar*)contentToolbar
{
    if (_contentToolbar == nil) {
        // initialize
        CGRect frame = CGRectZero;
        frame.size = CGSizeMake(self.bounds.size.width, kToolbarHeight);
        _contentToolbar = [[LFSContentToolbar alloc] initWithFrame:frame];
        [_contentToolbar setItems:
         @[
           [[UIBarButtonItem alloc]
            initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil],
           
           [[UIBarButtonItem alloc]
            initWithCustomView:self.likeButton],
           
           [[UIBarButtonItem alloc]
            initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil],
           
           [[UIBarButtonItem alloc]
            initWithCustomView:self.replyButton],
           
           [[UIBarButtonItem alloc]
            initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil]
           ]
         ];
        _contentToolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:_contentToolbar];
        
        // configure
    }
    return _contentToolbar;
}

#pragma mark - Private overrides
-(void)layoutSubviews
{
    // layout main content label
    CGRect basicHTMLLabelFrame = self.contentBodyLabel.frame;
    CGFloat contentWidth = self.bounds.size.width - kPaddingLeft - kContentPaddingRight;
    basicHTMLLabelFrame.size = [self contentSizeThatFits:
                                CGSizeMake(contentWidth, CGFLOAT_MAX)];
    [self.contentBodyLabel setFrame:basicHTMLLabelFrame];
    
    CGFloat bottom = basicHTMLLabelFrame.size.height + basicHTMLLabelFrame.origin.y;
    
    // layout url link
    LFSTriple *contentRemote = [self.delegate contentRemote];
    if (contentRemote != nil) {
        [self.remoteUrlLabel setHTMLString:
         [NSString stringWithFormat:@"<a href=\"%@\">%@</a>",
          [contentRemote detailString],
          [contentRemote mainString]]];
        CGRect remoteUrlFrame = self.remoteUrlLabel.frame;
        remoteUrlFrame.origin.y = bottom + kMinorVerticalSeparator;
        [self.remoteUrlLabel setFrame:remoteUrlFrame];
    }
    
    // layout source icon
    LFSTriple *profileRemote = [self.delegate profileRemote];
    if (profileRemote != nil) {
        [self.authorProfileButton setImage:[profileRemote iconImage]
                                  forState:UIControlStateNormal];
        _profileRemoteURL = [NSURL URLWithString:[profileRemote detailString]];
    }
    
    // layout author name label
    //
    // Note: preciese layout depends on whether we have detail field
    // (i.e. twitter handle)
    
    LFSHeader *profileLocal = [self.delegate profileLocal];
    NSString *authorDisplayName = profileLocal.mainString;
    NSString *authorDetail = profileLocal.detailString;
    NSString *authorAttribute = profileLocal.attributeString;
    
    if (authorDisplayName && !authorDetail && !authorAttribute)
    {
        // display one string
        [self.authorNameLabel setText:authorDisplayName];
        [self.authorNameLabel setTextVerticalAlignmentCenter];
    }
    else if (authorDisplayName && authorDetail && !authorAttribute)
    {
        // full name + twitter handle
        
        CGRect authorLabelFrame = self.authorNameLabel.frame;
        CGRect authorDetailLabelFrame = self.authorDetailLabel.frame;
        
        CGFloat separator = floorf((kHeaderHeight
                             - authorLabelFrame.size.height
                             - authorDetailLabelFrame.size.height) / 3.f);
        
        authorLabelFrame.origin.y = kPaddingTop + separator;
        authorDetailLabelFrame.origin.y = (kPaddingTop
                                           + separator
                                           + authorLabelFrame.size.height
                                           + separator);
        
        [self.authorNameLabel setFrame:authorLabelFrame];
        [self.authorNameLabel setText:authorDisplayName];
        [self.authorNameLabel setTextVerticalAlignmentCenter];
        
        [self.authorDetailLabel setFrame:authorDetailLabelFrame];
        [self.authorDetailLabel setText:authorDetail];
        [self.authorDetailLabel setTextVerticalAlignmentCenter];
    }
    else if (authorDisplayName && !authorDetail && authorAttribute)
    {
        // attribute + full name
        
        CGRect authorAttributeLabelFrame = self.authorAttributeLabel.frame;
        CGRect authorLabelFrame = self.authorNameLabel.frame;
        
        CGFloat separator = floorf((kHeaderHeight
                                    - authorLabelFrame.size.height
                                    - authorAttributeLabelFrame.size.height) / 3.f);
        

        authorAttributeLabelFrame.origin.y = (kPaddingTop + separator);
        authorLabelFrame.origin.y = (kPaddingTop
                                     + separator
                                     + authorAttributeLabelFrame.size.height
                                     + separator);
        
        [self.authorAttributeLabel setFrame:authorAttributeLabelFrame];
        [self.authorAttributeLabel setText:authorAttribute];
        [self.authorAttributeLabel setTextVerticalAlignmentCenter];
        
        [self.authorNameLabel setFrame:authorLabelFrame];
        [self.authorNameLabel setText:authorDisplayName];
        [self.authorNameLabel setTextVerticalAlignmentCenter];
    }
    else if (authorDisplayName && authorDetail && authorAttribute)
    {
        // attribute + full name + twitter handle
        
        CGRect authorAttributeLabelFrame = self.authorAttributeLabel.frame;
        CGRect authorLabelFrame = self.authorNameLabel.frame;
        CGRect authorDetailLabelFrame = self.authorDetailLabel.frame;
        
        CGFloat separator = floorf((kHeaderHeight
                                    - authorLabelFrame.size.height
                                    - authorAttributeLabelFrame.size.height
                                    - authorDetailLabelFrame.size.height) / 4.f);
        
        
        authorAttributeLabelFrame.origin.y = (kPaddingTop + separator);
        authorLabelFrame.origin.y = (kPaddingTop
                                     + separator
                                     + authorAttributeLabelFrame.size.height
                                     + separator);
        
        authorDetailLabelFrame.origin.y = (kPaddingTop
                                           + separator
                                           + authorAttributeLabelFrame.size.height
                                           + separator
                                           + authorLabelFrame.size.height
                                           + separator);
        
        [self.authorAttributeLabel setFrame:authorAttributeLabelFrame];
        [self.authorAttributeLabel setText:authorAttribute];
        [self.authorAttributeLabel setTextVerticalAlignmentCenter];
        
        [self.authorNameLabel setFrame:authorLabelFrame];
        [self.authorNameLabel setText:authorDisplayName];
        [self.authorNameLabel setTextVerticalAlignmentCenter];
        
        [self.authorDetailLabel setFrame:authorDetailLabelFrame];
        [self.authorDetailLabel setText:authorDetail];
        [self.authorDetailLabel setTextVerticalAlignmentCenter];
    }
    else {
        // no author label
    }
    
    // layout date label
    CGRect dateFrame = self.dateLabel.frame;
    dateFrame.origin.y = bottom + kMinorVerticalSeparator;
    [self.dateLabel setFrame:dateFrame];
    [self.dateLabel setText:[self.delegate contentDetail]];
    
    // layout avatar view
    [self.avatarView setImage:profileLocal.iconImage];
    
    // layout toolbar frame
    CGRect toolbarFrame = self.contentToolbar.frame;
    toolbarFrame.origin = CGPointMake(0.f,
                                      dateFrame.origin.y +
                                      dateFrame.size.height +
                                      kMinorVerticalSeparator);
    [self.contentToolbar setFrame:toolbarFrame];
}

-(CGSize)sizeThatFits:(CGSize)size
{
    CGFloat totalWidthInset = kPaddingLeft + kContentPaddingRight;
    CGFloat totalHeightInset = (kPaddingBottom
                                + kToolbarHeight
                                + kMinorVerticalSeparator
                                + kDetailRowHeight
                                + kMinorVerticalSeparator
                                
                                + kMajorVerticalSeparator
                                + kHeaderHeight
                                + kPaddingTop);
    CGSize contentSize = [self contentSizeThatFits:
                          CGSizeMake(size.width - totalWidthInset,
                                     CGFLOAT_MAX)];
    contentSize.width += totalWidthInset;
    contentSize.height += totalHeightInset;
    return contentSize;
}

#pragma mark - Private methods
-(CGSize)contentSizeThatFits:(CGSize)size
{
    [self.contentBodyLabel setHTMLString:[self.delegate contentBodyHtml]];
    return [self.contentBodyLabel sizeThatFits:size];
}

#pragma mark - Lifecycle

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _likeButton = nil;
        _replyButton = nil;
        _contentBodyLabel = nil;
        _remoteUrlLabel = nil;
        _authorProfileButton = nil;
        _avatarView = nil;
        _dateLabel = nil;
        _authorNameLabel = nil;
        
        _profileRemoteURL = nil;
        
        _contentLikedByUser = NO;
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
        _contentBodyLabel = nil;
        _remoteUrlLabel = nil;
        _authorProfileButton = nil;
        _avatarView = nil;
        _dateLabel = nil;
        _authorNameLabel = nil;
        
        _profileRemoteURL = nil;
        
        _contentLikedByUser = NO;
    }
    return self;
}

- (void)dealloc
{
    _likeButton = nil;
    _replyButton = nil;
    _contentBodyLabel = nil;
    _remoteUrlLabel = nil;
    _authorProfileButton = nil;
    _avatarView = nil;
    _dateLabel = nil;
    _authorNameLabel = nil;
    
    _profileRemoteURL = nil;
}

#pragma mark - Actions
- (IBAction)didSelectLike:(id)sender
{
    [self.delegate didSelectLike:sender];
}

- (IBAction)didSelectReply:(id)sender
{
    [self.delegate didSelectReply:sender];
}

- (IBAction)didSelectProfile:(id)sender
{
    if (_profileRemoteURL != nil) {
        [[UIApplication sharedApplication] openURL:_profileRemoteURL];
    }
}

@end
