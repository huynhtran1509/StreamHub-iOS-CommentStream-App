//
//  LFSDetailView.m
//  CommentStream
//
//  Created by Eugene Scherba on 9/26/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <StreamHub-iOS-SDK/NSDateFormatter+RelativeTo.h>

#import "LFSDetailView.h"
#import "LFSContentToolbar.h"
#import "LFSBasicHTMLLabel.h"

@implementation LFSRemote
@synthesize urlString = _urlString;
@synthesize iconImage = _iconImage;
@synthesize displayString = _displayString;

-(id)initWithURLString:(NSString*)urlString
         displayString:(NSString*)displayString
             iconImage:(UIImage*)iconImage
{
    self = [super init];
    if (self) {
        _urlString = urlString;
        _iconImage = iconImage;
        _displayString = displayString;
    }
    return self;
}

-(id)init
{
    self = [self initWithURLString:nil displayString:nil iconImage:nil];
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
@property (strong, nonatomic) UILabel *authorLabel;
@property (strong, nonatomic) UILabel *dateLabel;
@property (strong, nonatomic) UIButton *likeButton;
@property (strong, nonatomic) UIButton *replyButton;

@end

@implementation LFSDetailView {
    NSURL *_profileRemoteURL;
}

#pragma mark - Properties

// UIView-specific
@synthesize contentBodyLabel = _contentBodyLabel;
@synthesize avatarView = _avatarView;
@synthesize authorLabel = _authorLabel;
@synthesize dateLabel = _dateLabel;
@synthesize remoteUrlLabel = _remoteUrlLabel;
@synthesize contentToolbar = _contentToolbar;
@synthesize authorProfileButton = _authorProfileButton;
@synthesize likeButton = _likeButton;
@synthesize replyButton = _replyButton;

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
        CGRect frame = CGRectMake(20.f,
                                  66.f,
                                  self.bounds.size.width - 40.f,
                                  10.f); // this one can vary
        _contentBodyLabel = [[LFSBasicHTMLLabel alloc] initWithFrame:frame];
        [_contentBodyLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [self addSubview:_contentBodyLabel];
        
        // configure
        [_contentBodyLabel setFont:[UIFont fontWithName:@"Georgia" size:17.0f]];
        [_contentBodyLabel setLineSpacing:8.5f];
        [_contentBodyLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [_contentBodyLabel setTextAlignment:NSTextAlignmentLeft];
    }
    return _contentBodyLabel;
}

- (LFSBasicHTMLLabel*)remoteUrlLabel
{
    if (_remoteUrlLabel == nil) {
        // initialize
        CGRect frame = CGRectMake(self.bounds.size.width / 2.f,
                                  76.f, // this one can vary
                                  (self.bounds.size.width - 40.f) / 2.f,
                                  21);
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

-(UIButton*)authorProfileButton
{
    if (_authorProfileButton == nil) {
        // initialize
        CGRect frame = CGRectMake(self.bounds.size.width - 40.f, 20.f, 20.f, 20.f);
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
    static const CGFloat kAvatarCornerRadius = 4;
    
    if (_avatarView == nil) {
        // initialize
        CGRect frame;
        if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)]
            && ([UIScreen mainScreen].scale == 2.0f))
        {
            // Retina display, okay to use half-points
            frame = CGRectMake(20.f, 20.f, 37.5f, 37.5f);
        }
        else
        {
            // non-Retina display, do not use half-points
            frame = CGRectMake(20.f, 20.f, 37.f, 37.f);
        }
        _avatarView = [[UIImageView alloc] initWithFrame:frame];
        [_avatarView setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
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
        CGRect frame = CGRectMake(21.f,
                                  0.f, // this could vary
                                  (self.bounds.size.width - 40.f) / 2.f,
                                  21.f);
        _dateLabel = [[UILabel alloc] initWithFrame:frame];
        [_dateLabel setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
        [self addSubview:_dateLabel];
        
        // configure
        [_dateLabel setFont:[UIFont systemFontOfSize:13.f]];
        [_dateLabel setTextColor:[UIColor lightGrayColor]];
    }
    return _dateLabel;
}

- (UILabel*)authorLabel
{
    if (_authorLabel == nil) {
        // initialize
        CGFloat leftColumn = 66.f;
        CGRect frame = CGRectMake(leftColumn,
                                  20.f,
                                  self.bounds.size.width - leftColumn - 20.f,
                                  38.f);
        _authorLabel = [[UILabel alloc] initWithFrame:frame];
        _authorLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:_authorLabel];
        
        // configure
        [_authorLabel setFont:[UIFont boldSystemFontOfSize:16.f]];
    }
    return _authorLabel;
}

-(LFSContentToolbar*)contentToolbar
{
    if (_contentToolbar == nil) {
        // initialize
        CGRect frame = CGRectZero;
        frame.size = CGSizeMake(self.bounds.size.width, 44.f);
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
    // TODO: move setting HTML content in a different method and
    // follow it by [self setNeedsLayout];
    //
    // set and format main content label
    [self.contentBodyLabel setHTMLString:[self.delegate contentBodyHtml]];
    CGRect basicHTMLLabelFrame = self.contentBodyLabel.frame;
    CGFloat contentWidth = self.bounds.size.width - 40.f;
    basicHTMLLabelFrame.size = [self.contentBodyLabel
                                sizeThatFits:CGSizeMake(contentWidth, 10000.f)];
    [self.contentBodyLabel setFrame:basicHTMLLabelFrame];
    
    CGFloat bottom = basicHTMLLabelFrame.size.height + basicHTMLLabelFrame.origin.y;
    
    // set and format url link
    LFSRemote *contentRemote = [self.delegate contentRemote];
    if (contentRemote != nil) {
        [self.remoteUrlLabel setHTMLString:
         [NSString stringWithFormat:@"<a href=\"%@\">%@ ></a>",
          [contentRemote urlString],
          [contentRemote displayString]]];
        CGRect remoteUrlFrame = self.remoteUrlLabel.frame;
        remoteUrlFrame.origin.y = bottom + 12.f;
        [self.remoteUrlLabel setFrame:remoteUrlFrame];
    }
    
    // set source icon
    LFSRemote *profileRemote = [self.delegate profileRemote];
    if (profileRemote != nil) {
        [self.authorProfileButton setImage:[profileRemote iconImage]
                                  forState:UIControlStateNormal];
        _profileRemoteURL = [NSURL URLWithString:[profileRemote urlString]];
    }
    
    // format author name label
    NSString *authorDisplayName = [self.delegate authorDisplayName];
    if (authorDisplayName) {
        [self.authorLabel setText:authorDisplayName];
    }
    
    // format date label
    CGRect dateFrame = self.dateLabel.frame;
    dateFrame.origin.y = bottom + 12.f;
    [self.dateLabel setFrame:dateFrame];
    [self.dateLabel setText:[[[NSDateFormatter alloc] init]
                             extendedRelativeStringFromDate:
                             [self.delegate contentCreationDate]]];
    
    // set avatar view
    [self.avatarView setImage:[self.delegate avatarImage]];
    
    // set toolbar frame
    CGRect toolbarFrame = self.contentToolbar.frame;
    toolbarFrame.origin = CGPointMake(0.f, dateFrame.origin.y + dateFrame.size.height + 12.f);
    [self.contentToolbar setFrame:toolbarFrame];
    
    // calculate total view frame size
    CGRect frame = CGRectZero;
    frame.size = CGSizeMake(self.frame.size.width,
                            toolbarFrame.origin.y + toolbarFrame.size.height + 20.f);
    [self setFrame:frame];
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
        _authorLabel = nil;
        
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
        _authorLabel = nil;
        
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
    _authorLabel = nil;
    
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
