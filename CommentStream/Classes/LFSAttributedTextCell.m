//
//  LFAttributedTextCell.m
//  CommentStream
//
//  Created by Eugene Scherba on 8/14/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <StreamHub-iOS-SDK/LFSConstants.h>
#import <StreamHub-iOS-SDK/NSDateFormatter+RelativeTo.h>
#import "LFSBasicHTMLParser.h"
#import "LFSAttributedTextCell.h"
#import "UILabel+Trim.h"

static const UIEdgeInsets kPadding = {
    .top=10.f, .left=15.f, .bottom=12.f, .right=12.f
};

static const CGFloat kContentPaddingRight = 7.f;
static const CGFloat kContentLineSpacing = 6.f;

static const CGFloat kHeaderSubtitleFontSize = 11.f;
static const CGFloat kHeaderAttributeTopFontSize = 10.f;
static const CGFloat kHeaderAdjust = 2.f;
static const CGFloat kHeaderAccessoryRightImageAlpha = 0.618f;

static const CGSize  kHeaderAccessoryRightIconSize = { .width=21.f, .height=21.f };

static const CGSize  kImageViewSize = { .width=25.f, .height=25.f };

static const CGFloat kImageCornerRadius = 4.f;
static const CGFloat kImageMarginRight = 8.0f;

static const CGFloat kMinorVerticalSeparator = 12.0f;

// {{{ TODO: remove these?
static const CGFloat kHeaderAcessoryRightHeight = 21.f;

static const CGFloat kMajorVerticalSeparator = 7.0f;

static const CGFloat kHeaderAttributeTopHeight = 10.0f;
static const CGFloat kHeaderTitleHeight = 18.0f;
static const CGFloat kHeaderSubtitleHeight = 10.0f;
// }}}

@interface LFSAttributedTextCell ()
// store hash to avoid relayout of same HTML
@property (nonatomic, assign) NSUInteger htmlHash;
@property (nonatomic, assign) CGFloat requiredBodyHeight;

@property (readonly, nonatomic) UILabel *headerAttributeTopView;
@property (readonly, nonatomic) UILabel *headerTitleView;
@property (readonly, nonatomic) UILabel *headerSubtitleView;

@property (nonatomic, readonly) LFSBasicHTMLLabel *bodyView;
@property (nonatomic, readonly) UILabel *headerAccessoryRightView;

@property (nonatomic, strong) UIImageView *headerAccessoryRightImageView;
@end

@implementation LFSAttributedTextCell

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
@synthesize bodyFont = _bodyFont;
-(UIFont*)bodyFont {
    return self.bodyView.font;
}
-(void)setBodyFont:(UIFont *)contentBodyFont {
    self.bodyView.font = contentBodyFont;
}

#pragma mark -
@synthesize bodyColor = _bodyColor;
-(UIColor*)bodyColor {
    return self.bodyView.textColor;
}
-(void)setBodyColor:(UIColor *)contentBodyColor {
    self.bodyView.textColor = contentBodyColor;
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
@synthesize dateFormatter = _dateFormatter;

@synthesize profileLocal = _profileLocal;
@synthesize profileRemote = _profileRemote;
@synthesize contentRemote = _contentRemote;

#pragma mark -
@synthesize contentDate = _contentDate;
-(void)setContentDate:(NSDate *)contentDate
{
    if (contentDate != _contentDate) {
        NSString *dateTime = [self.dateFormatter relativeStringFromDate:contentDate];
        [self.headerAccessoryRightView setText:dateTime];
        [self setNeedsLayout];
    
        _contentDate = contentDate;
    }
}

#pragma mark -
@synthesize requiredBodyHeight = _requiredBodyHeight;
-(CGFloat)requiredBodyHeight
{
    if (_requiredBodyHeight == CGFLOAT_MAX) {
        // calculate afresh
        CGSize bodySize = CGSizeMake(self.bounds.size.width - kPadding.left - kContentPaddingRight,
                                     CGFLOAT_MAX);
        CGSize requiredBodySize = [self.bodyView sizeThatFits:bodySize];
        _requiredBodyHeight = requiredBodySize.height;
    }
    return _requiredBodyHeight;
}

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
@synthesize bodyView = _bodyView;
-(LFSBasicHTMLLabel*)bodyView
{
	if (_bodyView == nil) {
        const CGFloat kHeaderHeight = kPadding.top + kImageViewSize.height + kMinorVerticalSeparator;
        CGRect frame = CGRectMake(kPadding.left,
                                  kHeaderHeight,
                                  self.bounds.size.width - kPadding.left - kContentPaddingRight,
                                  self.bounds.size.height - kHeaderHeight);
        
        // initialize
        _bodyView = [[LFSBasicHTMLLabel alloc] initWithFrame:frame];
        
        // configure
        [_bodyView setFont:[UIFont fontWithName:@"Georgia" size:13.f]];
        [_bodyView setTextColor:[UIColor blackColor]];
        [_bodyView setBackgroundColor:[UIColor clearColor]]; // for iOS6
        [_bodyView setLineSpacing:kContentLineSpacing];
        
        // add to superview
		[self.contentView addSubview:_bodyView];
	}
	return _bodyView;
}

#pragma mark -
@synthesize headerAttributeTopView = _headerAttributeTopView;
- (UILabel*)headerAttributeTopView
{
    if (_headerAttributeTopView == nil) {
        CGFloat leftColumnWidth = kPadding.left + kImageViewSize.width + kImageMarginRight;
        CGSize labelSize = CGSizeMake(self.bounds.size.width - leftColumnWidth - kPadding.right,
                                      kHeaderAttributeTopHeight);
        CGRect frame;
        frame.size = labelSize;
        frame.origin = CGPointMake(leftColumnWidth,
                                   kPadding.top); // size.y will be changed in layoutSubviews
        // initialize
        _headerAttributeTopView = [[UILabel alloc] initWithFrame:frame];
        
        // configure
        [_headerAttributeTopView
         setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin)];
        [_headerAttributeTopView setFont:[UIFont systemFontOfSize:kHeaderAttributeTopFontSize]];
        [_headerAttributeTopView setTextColor:[UIColor blueColor]];
        
        // add to superview
        [self.contentView addSubview:_headerAttributeTopView];
    }
    return _headerAttributeTopView;
}

#pragma mark -
@synthesize headerTitleView = _headerTitleView;
- (UILabel *)headerTitleView
{
	if (_headerTitleView == nil) {
        CGFloat leftColumnWidth = kPadding.left + kImageViewSize.width + kImageMarginRight;
        CGRect frame = CGRectMake(leftColumnWidth,
                                  kPadding.top - kHeaderAdjust,
                                  self.bounds.size.width - leftColumnWidth - kPadding.right,
                                  kImageViewSize.height + kHeaderAdjust * 2.f);

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
@synthesize headerSubtitleView = _headerSubtitleView;
- (UILabel*)headerSubtitleView
{
    if (_headerSubtitleView == nil) {
        CGFloat leftColumnWidth = kPadding.left + kImageViewSize.width + kImageMarginRight;
        CGRect frame = CGRectMake(leftColumnWidth,
                                  kPadding.top - kHeaderAdjust,
                                  self.bounds.size.width - leftColumnWidth - kPadding.right,
                                  kImageViewSize.height + kHeaderAdjust * 2.f);
        // initialize
        _headerSubtitleView = [[UILabel alloc] initWithFrame:frame];
        
        // configure
        [_headerSubtitleView
         setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin)];
        [_headerSubtitleView setFont:[UIFont systemFontOfSize:kHeaderSubtitleFontSize]];
        [_headerSubtitleView setTextColor:[UIColor grayColor]];
        
        // add to superview
        [self.contentView addSubview:_headerSubtitleView];
    }
    return _headerSubtitleView;
}

#pragma mark -
@synthesize headerAccessoryRightView = _headerAccessoryRightView;
- (UILabel *)headerAccessoryRightView
{
	if (_headerAccessoryRightView == nil) {
        CGFloat leftColumnWidth = kPadding.left + kImageViewSize.width + kImageMarginRight;
        CGRect frame = CGRectMake(leftColumnWidth,
                                  kPadding.top,
                                  self.bounds.size.width - leftColumnWidth - kPadding.right,
                                  kImageViewSize.height);

        // initialize
        _headerAccessoryRightView = [[UILabel alloc] initWithFrame:frame];
        
        // configure
        [_headerAccessoryRightView setFont:[UIFont systemFontOfSize:11.f]];
        [_headerAccessoryRightView setTextColor:[UIColor lightGrayColor]];
        //[_headerAccessoryRightView setTextAlignment:NSTextAlignmentRight];
        
        // add to superview
		[self.contentView addSubview:_headerAccessoryRightView];
	}
	return _headerAccessoryRightView;
}

#pragma mark -
@synthesize headerAccessoryRightImageView = _headerAccessoryRightImageView;
- (UIImageView *)headerAccessoryRightImageView
{
	if (_headerAccessoryRightImageView == nil) {
        // initialize
        UIImage *icon = self.indicatorIcon;
        _headerAccessoryRightImageView = [[UIImageView alloc] initWithImage:icon];
        // configure
        [_headerAccessoryRightImageView setAlpha:kHeaderAccessoryRightImageAlpha];
        
        // add to superview
		[self.contentView addSubview:_headerAccessoryRightImageView];
	}
	return _headerAccessoryRightImageView;
}

#pragma mark - Overrides

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	if (!self.superview) {
		return;
	}
    
    CGRect bounds = self.bounds;
    [self layoutHeaderWithBounds:bounds];
    [self layoutBodyWithBounds:bounds];
}

#pragma mark - Private methods

-(void)layoutHeaderWithBounds:(CGRect)rect
{
    // layout header title label
    //
    // Note: preciese layout depends on whether we have subtitle field
    // (i.e. twitter handle)
    
    LFSHeader *profileLocal = self.profileLocal;
    NSString *headerTitle = profileLocal.mainString;
    NSString *headerSubtitle = profileLocal.detailString;
    NSString *headerAccessory = profileLocal.attributeString;
    
    // layout avatar
    CGRect imageViewFrame;
    imageViewFrame.origin = CGPointMake(kPadding.left, kPadding.top);
    imageViewFrame.size = kImageViewSize;
    self.imageView.frame = imageViewFrame;
    
    CGFloat leftColumnWidth = kPadding.left + kImageViewSize.width + kImageMarginRight;
    
    if (headerTitle) {
        CGRect titleFrame = self.headerTitleView.frame;
        titleFrame.origin.x = kPadding.left + kImageViewSize.width + kImageMarginRight;
        titleFrame.size.width = rect.size.width - leftColumnWidth - kPadding.right;
        [self.headerTitleView setFrame:titleFrame];
    }
    if (headerTitle && !headerSubtitle && !headerAccessory)
    {
        // display one string
        [self.headerTitleView setText:headerTitle];
        [self.headerTitleView resizeVerticalCenterRightTrim];
    }
    else if (headerTitle && headerSubtitle && !headerAccessory)
    {
        // full name + twitter handle
        [self.headerTitleView setText:headerTitle];
        [self.headerTitleView resizeVerticalTopRightTrim];
        
        [self.headerSubtitleView setText:headerSubtitle];
        [self.headerSubtitleView resizeVerticalBottomRightTrim];
    }
    else if (headerTitle && !headerSubtitle && headerAccessory)
    {
        // attribute + full name
        [self.headerTitleView setText:headerTitle];
        [self.headerTitleView resizeVerticalTopRightTrim];
        CGRect headerTitleFrame = self.headerTitleView.frame;
        
        CGRect headerAttributeTopFrame;
        headerAttributeTopFrame.origin = CGPointMake(headerTitleFrame.origin.x
                                                     + headerTitleFrame.size.width
                                                     + kImageMarginRight,
                                                     headerTitleFrame.origin.y);
        headerAttributeTopFrame.size = CGSizeMake(rect.size.width
                                                  - headerTitleFrame.origin.x
                                                  - headerTitleFrame.size.width,
                                                  headerTitleFrame.size.height);
        
        [self.headerAttributeTopView setFrame:headerAttributeTopFrame];
        [self.headerAttributeTopView setText:headerAccessory];
        [self.headerAttributeTopView resizeVerticalCenterRightTrim];
        
    }
    else if (headerTitle && headerSubtitle && headerAccessory)
    {
        // attribute + full name + twitter handle
        [self.headerTitleView setText:headerTitle];
        [self.headerTitleView resizeVerticalTopRightTrim];
        CGRect headerTitleFrame = self.headerTitleView.frame;
        
        [self.headerSubtitleView setText:headerSubtitle];
        [self.headerSubtitleView resizeVerticalCenterRightTrim];
        [self.headerSubtitleView resizeVerticalBottomRightTrim];
        
        CGRect headerAttributeTopFrame;
        headerAttributeTopFrame.origin = CGPointMake(headerTitleFrame.origin.x
                                                     + headerTitleFrame.size.width
                                                     + kImageMarginRight,
                                                     headerTitleFrame.origin.y);
        headerAttributeTopFrame.size = CGSizeMake(rect.size.width
                                                  - headerTitleFrame.origin.x
                                                  - headerTitleFrame.size.width,
                                                  headerTitleFrame.size.height);
        
        [self.headerAttributeTopView setFrame:headerAttributeTopFrame];
        [self.headerAttributeTopView setText:headerAccessory];
        [self.headerAttributeTopView resizeVerticalCenterRightTrim];
    }
    else {
        // no header
    }
    
    // layout note view
    CGRect accessoryRightFrame = self.headerAccessoryRightView.frame;
    accessoryRightFrame.origin.x = leftColumnWidth;
    accessoryRightFrame.size.width = rect.size.width - leftColumnWidth - kPadding.right;
    [self.headerAccessoryRightView setFrame:accessoryRightFrame];
    [self.headerAccessoryRightView setText:
     [self.dateFormatter relativeStringFromDate:self.contentDate]];
    [self.headerAccessoryRightView resizeVerticalTopLeftTrim];
    
    if (self.indicatorIcon != nil) {
        CGFloat centerY = self.headerAccessoryRightView.center.y;
        [self.headerAccessoryRightImageView setCenter:
         CGPointMake(self.headerAccessoryRightView.frame.origin.x -
                     self.headerAccessoryRightImageView.frame.size.width,
                     centerY)];
    }
    
}

-(void)layoutBodyWithBounds:(CGRect)rect
{
    // layoutSubviews is always called after requiredRowHeightWithFrameWidth:
    // so we take advantage of that by reusing _requiredBodyHeight
    CGRect textContentFrame;
    textContentFrame.origin = CGPointMake(kPadding.left,
                                          kPadding.top + kImageViewSize.height + kMinorVerticalSeparator);
    textContentFrame.size = CGSizeMake(rect.size.width - kPadding.left - kContentPaddingRight,
                                       self.requiredBodyHeight);
    [self.bodyView setFrame:textContentFrame];
    
    // fix an annoying bug (in OHAttributedLabel?) where y-value of bounds
    // would go in the negative direction if frame origin y-value exceeded
    // 44 pts (due to 44-pt toolbar being present?)
    CGRect bounds = self.bodyView.bounds;
    bounds.origin = CGPointZero;
    [_bodyView setBounds:bounds];
}

#pragma mark - Public methods
- (void)setHTMLString:(NSString *)html
{
	// store hash isntead of HTML source
	NSUInteger newHash = [html hash];
    
	if (newHash == _htmlHash) {
		return;
	}
	
    // reset requiredbodyheight
    [self setRequiredBodyHeight:CGFLOAT_MAX];
    
	_htmlHash = newHash;
	[self.bodyView setHTMLString:html];
	[self setNeedsLayout];
}

- (CGFloat)requiredRowHeightWithFrameWidth:(CGFloat)width
{
    CGSize requiredBodySize = [self.bodyView
                               sizeThatFits:
                               CGSizeMake(width - kPadding.left - kContentPaddingRight,
                                          CGFLOAT_MAX)];
    
    [self setRequiredBodyHeight:requiredBodySize.height];
    return kPadding.bottom + requiredBodySize.height + kPadding.top + kImageViewSize.height + kMinorVerticalSeparator;
}


#pragma mark - Lifecycle
-(id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // initialize subview references
        _bodyView = nil;
        _indicatorIcon = nil;
        _headerAccessoryRightView = nil;
        _headerAccessoryRightImageView = nil;
        _headerImage = nil;
        _headerTitleView = nil;
        
        _contentDate = nil;
        _dateFormatter = nil;
        
        _requiredBodyHeight = CGFLOAT_MAX;
        
        [self setAccessoryType:UITableViewCellAccessoryNone];
        
        if (LFS_SYSTEM_VERSION_LESS_THAN(LFSSystemVersion70))
        {
            // iOS7-like selected background color
            [self setSelectionStyle:UITableViewCellSelectionStyleGray];
            UIView *selectionColor = [[UIView alloc] init];
            [selectionColor setBackgroundColor:[UIColor colorWithRed:(217.f/255.f)
                                                               green:(217.f/255.f)
                                                                blue:(217.f/255.f)
                                                               alpha:1.f]];
            [self setSelectedBackgroundView:selectionColor];
        }
        
        [self.imageView setContentMode:UIViewContentModeScaleToFill];
        [self.imageView.layer setCornerRadius:kImageCornerRadius];
        [self.imageView.layer setMasksToBounds:YES];
    }
    return self;
}

-(void)dealloc
{
    _bodyView = nil;
    _headerTitleView = nil;
    _indicatorIcon = nil;
    _headerAccessoryRightView = nil;
    _headerAccessoryRightImageView = nil;
    _headerImage = nil;
    
    _contentDate = nil;
    _dateFormatter = nil;
}

@end
