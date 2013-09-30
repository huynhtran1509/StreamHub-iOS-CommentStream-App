//
//  LFAttributedTextCell.m
//  CommentStream
//
//  Created by Eugene Scherba on 8/14/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <StreamHub-iOS-SDK/LFSConstants.h>
#import "LFSBasicHTMLParser.h"
#import "LFSAttributedTextCell.h"
#import "UILabel+Trim.h"

// TODO: turn some of these consts into properties for easier customization
//static const CGFloat kLeftColumnWidth = 50.f;

static const CGFloat kPaddingTop = 7.f;
static const CGFloat kPaddingRight = 12.f;
static const CGFloat kPaddingBottom = 18.f;
static const CGFloat kPaddingLeft = 15.f;

static const CGFloat kContentPaddingRight = 7.f;
static const CGFloat kContentLineSpacing = 6.5f;

static const CGFloat kHeaderAcessoryRightWidth = 68.f;
static const CGFloat kHeaderAcessoryRightHeight = 21.f;

// title font settings
static const CGFloat kHeaderSubtitleFontSize = 11.f; // not used yet
static const CGFloat kHeaderAttributeTopFontSize = 10.f; // not used yet

static const CGSize  kImageViewSize = { .width=25.f, .height=25.f };
static const CGFloat kImageCornerRadius = 4.f;
static const CGFloat kImageMarginRight = 8.0f;

static const CGFloat kMinorVerticalSeparator = 5.0f;
static const CGFloat kMajorVerticalSeparator = 7.0f;

static const CGFloat kHeaderAttributeTopHeight = 10.0f;
static const CGFloat kHeaderTitleHeight = 18.0f;
static const CGFloat kHeaderSubtitleHeight = 10.0f;

@interface LFSAttributedTextCell ()
// store hash to avoid relayout of same HTML
@property (nonatomic, assign) NSUInteger htmlHash;
@end

@implementation LFSAttributedTextCell {
    BOOL _isInitializing;
}

#pragma mark - UIAppearance properties
@synthesize backgroundCellColor;
-(UIColor*)backgroundCellColor
{
    return self.backgroundColor;
}
-(void)setBackgroundCellColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];
}

#pragma mark -
@synthesize headerTitleFont = _headerTitleFont;
-(UIFont*)headerTitleFont {
    return self.headerTitleView.font;
}
-(void)setHeaderTitleFont:(UIFont *)headerTitleFont {
    self.headerTitleView.font = headerTitleFont;
}

#pragma mark -
@synthesize headerTitleColor = _headerTitleColor;
-(UIColor*)headerTitleColor {
    return self.headerTitleView.textColor;
}
-(void)setHeaderTitleColor:(UIColor *)headerTitlecolor {
    self.headerTitleView.textColor = headerTitlecolor;
}

#pragma mark -
@synthesize contentBodyFont = _contentBodyFont;
-(UIFont*)contentBodyFont {
    return self.contentBodyView.font;
}
-(void)setContentBodyFont:(UIFont *)contentBodyFont {
    self.contentBodyView.font = contentBodyFont;
}

#pragma mark -
@synthesize contentBodyColor = _contentBodyColor;
-(UIColor*)contentBodyColor {
    return self.contentBodyView.textColor;
}
-(void)setContentBodyColor:(UIColor *)contentBodyColor {
    self.contentBodyView.textColor = contentBodyColor;
}

#pragma mark -
@synthesize headerAccessoryRightFont = _headerAccessoryRightFont;
-(UIFont*)headerAccessoryRightFont {
    return self.headerAccessoryRightView.font;
}
-(void)setHeaderAccessoryRightFont:(UIFont *)headerAccessoryRightFont {
    self.headerAccessoryRightView.font = headerAccessoryRightFont;
}

#pragma mark -
@synthesize headerAccessoryRightColor = _headerAccessoryRightColor;
-(UIColor*)headerAccessoryRightColor {
    return self.headerAccessoryRightView.textColor;
}
-(void)setHeaderAccessoryRightColor:(UIColor *)headerAccessoryRightColor {
    self.headerAccessoryRightView.textColor = headerAccessoryRightColor;
}

#pragma mark - Other properties
@synthesize htmlHash = _htmlHash;

#pragma mark -
@synthesize headerImage = _headerImage;
- (void)setHeaderImage:(UIImage*)image
{
    // store original-size image
    _headerImage = image;
    
    // we are on a non-Retina device
    UIScreen *screen = [UIScreen mainScreen];
    CGSize size;
    if ([screen respondsToSelector:@selector(scale)] && [screen scale] == 2.f)
    {
        // Retina: scale to 2x frame size
        size = CGSizeMake(kImageViewSize.width * 2.f,
                          kImageViewSize.height * 2.f);
    }
    else
    {
        // non-Retina
        size = kImageViewSize;
    }
    CGRect targetRect = CGRectMake(0.f, 0.f, size.width, size.height);
    dispatch_queue_t queue =
    dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0.f);
    dispatch_async(queue, ^{
        
        // scale image on a background thread
        // Note: this will not preserve aspect ratio
        UIGraphicsBeginImageContext(size);
        [image drawInRect:targetRect];
        UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        // display image on the main thread
        dispatch_sync(dispatch_get_main_queue(), ^{
            self.imageView.image = scaledImage;
            [self setNeedsLayout];
        });
    });
}

#pragma mark -
@synthesize contentBodyView = _contentBodyView;
-(LFSBasicHTMLLabel*)contentBodyView
{
	if (_contentBodyView == nil) {
        const CGFloat kHeaderHeight = kPaddingTop + kImageViewSize.height + kMinorVerticalSeparator;
        CGRect frame = CGRectMake(kPaddingLeft,
                                  kHeaderHeight,
                                  self.bounds.size.width - kPaddingLeft - kContentPaddingRight,
                                  self.bounds.size.height - kHeaderHeight);
        
        // initialize
		_contentBodyView = [[LFSBasicHTMLLabel alloc] initWithFrame:frame];
        
        // configure
        [_contentBodyView setFont:[UIFont fontWithName:@"Georgia" size:13.f]];
        [_contentBodyView setTextColor:[UIColor blackColor]];
        [_contentBodyView setBackgroundColor:[UIColor clearColor]]; // for iOS6
        [_contentBodyView setLineSpacing:kContentLineSpacing];
        
        // add to superview
		[self.contentView addSubview:_contentBodyView];
	}
	return _contentBodyView;
}

#pragma mark -
@synthesize headerTitleView = _headerTitleView;
- (UILabel *)headerTitleView
{
	if (_headerTitleView == nil) {
        CGFloat leftColumnWidth = kPaddingLeft + kImageViewSize.width + kImageMarginRight;
        CGFloat rightColumnWidth = kHeaderAcessoryRightWidth + kPaddingRight;
        
        CGRect frame;
        frame.size = CGSizeMake(self.bounds.size.width - leftColumnWidth - rightColumnWidth, kHeaderTitleHeight);
        frame.origin = CGPointMake(leftColumnWidth, kPaddingTop);
        
        // initialize
		_headerTitleView = [[UILabel alloc] initWithFrame:frame];
        
        // configure
        [_headerTitleView setFont:[UIFont boldSystemFontOfSize:12.f]];
        [_headerTitleView setTextColor:[UIColor blackColor]];
        [_headerTitleView setBackgroundColor:[UIColor clearColor]]; // for iOS6
        
        // add to superview
		[self.contentView addSubview:_headerTitleView];
	}
	return _headerTitleView;
}

#pragma mark -
@synthesize headerAccessoryRightView = _headerAccessoryRightView;
- (UILabel *)headerAccessoryRightView
{
	if (_headerAccessoryRightView == nil) {
        CGRect frame;
        frame.size = CGSizeMake(kHeaderAcessoryRightWidth, kHeaderAcessoryRightHeight);
        frame.origin = CGPointMake(self.bounds.size.width - kHeaderAcessoryRightWidth - kPaddingRight, kPaddingTop);
        
        // initialize
		_headerAccessoryRightView = [[UILabel alloc] initWithFrame:frame];
        
        // configure
        [_headerAccessoryRightView setFont:[UIFont systemFontOfSize:11.f]];
        [_headerAccessoryRightView setTextColor:[UIColor lightGrayColor]];
        [_headerAccessoryRightView setTextAlignment:NSTextAlignmentRight];
        
        // add to superview
		[self.contentView addSubview:_headerAccessoryRightView];
	}
	return _headerAccessoryRightView;
}

#pragma mark - Lifecycle
-(id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    _isInitializing = YES;
    self = [super initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // initialize subview references
        _contentBodyView = nil;
        _headerAccessoryRightView = nil;
        _headerImage = nil;
        _headerTitleView = nil;
        
        [self setAccessoryType:UITableViewCellAccessoryNone];

        if (LFS_SYSTEM_VERSION_LESS_THAN(LFSSystemVersion70))
        {
            // iOS7-like selected background color
            [self setSelectionStyle:UITableViewCellSelectionStyleGray];
            UIView *selectionColor = [[UIView alloc] init];
            selectionColor.backgroundColor = [UIColor colorWithRed:(217.f/255.f)
                                                             green:(217.f/255.f)
                                                              blue:(217.f/255.f)
                                                             alpha:1.f];
            self.selectedBackgroundView = selectionColor;
        }
        
        [self.imageView setContentMode:UIViewContentModeScaleToFill];
        self.imageView.layer.cornerRadius = kImageCornerRadius;
        self.imageView.layer.masksToBounds = YES;
    }
    _isInitializing = NO;
    return self;
}

-(void)dealloc{
    _contentBodyView = nil;
    _headerTitleView = nil;
    _headerAccessoryRightView = nil;
    _headerImage = nil;
}

#pragma mark - Private methods

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	if (!self.superview) {
		return;
	}
    
    // layout content view
    CGFloat width = self.bounds.size.width;
    CGRect textContentFrame = self.contentBodyView.frame;
    textContentFrame.size = [self.contentBodyView
                             sizeThatFits:
                             CGSizeMake(width - kPaddingLeft - kContentPaddingRight,
                                        CGFLOAT_MAX)];
    [self.contentBodyView setFrame:textContentFrame];
    
    const CGFloat kLeftColumnWidth = kPaddingLeft + kImageViewSize.width + kImageMarginRight;
    const CGFloat kRightColumnWidth = kHeaderAcessoryRightWidth + kPaddingRight;
    
    // layout title view
    CGRect titleFrame = self.headerTitleView.frame;
    titleFrame.size.width = width - kLeftColumnWidth - kRightColumnWidth;
    [self.headerTitleView setFrame:titleFrame];
    
    // layout note view
    CGRect accessoryRightFrame = self.headerAccessoryRightView.frame;
    accessoryRightFrame.origin.x = width - kRightColumnWidth;
    [self.headerAccessoryRightView setFrame:accessoryRightFrame];
    
    // layout avatar
    CGRect imageViewFrame;
    imageViewFrame.origin = CGPointMake(kPaddingLeft, kPaddingTop);
    imageViewFrame.size = kImageViewSize;
    self.imageView.frame = imageViewFrame;
}


#pragma mark - Public methods
- (void)setHTMLString:(NSString *)html
{
	// store hash isntead of HTML source
	NSUInteger newHash = [html hash];
    
	if (newHash == _htmlHash) {
		return;
	}
	
	_htmlHash = newHash;
	[self.contentBodyView setHTMLString:html];
	[self setNeedsLayout];
}

- (CGFloat)requiredRowHeightWithFrameWidth:(CGFloat)width
{
    CGSize neededSize = [self.contentBodyView
                         sizeThatFits:
                         CGSizeMake(width - kPaddingLeft - kContentPaddingRight,
                                    CGFLOAT_MAX)];
    
    CGRect imageViewFrame = self.imageView.frame;
    const CGFloat kHeaderHeight = kPaddingTop + kImageViewSize.height + kMinorVerticalSeparator;
	CGFloat result = kPaddingBottom + MAX(neededSize.height + kHeaderHeight,
                              imageViewFrame.size.height +
                              imageViewFrame.origin.y);
    return result;
}

@end
