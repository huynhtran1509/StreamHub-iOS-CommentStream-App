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

// TODO: turn some of these consts into properties for easier customization
//static const CGFloat kLeftColumnWidth = 50.f;

static const CGFloat kPaddingTop = 7.f;
static const CGFloat kPaddingRight = 12.f;
static const CGFloat kPaddingBottom = 18.f;
static const CGFloat kPaddingLeft = 15.f;

static const CGFloat kContentPaddingRight = 7.f;

// content font settings
static NSString* const kContentFontName = @"Georgia";
static const CGFloat kContentFontSize = 13.f;
static const CGFloat kContentLineSpacing = 6.5f;

// note (date) font settings
static const CGFloat kNoteFontSize = 11.f;

// title font settings
static const CGFloat kAuthorNameFontSize = 12.f;
static const CGFloat kAuthorDetailFontSize = 11.f; // not used yet
static const CGFloat kAuthorAttributeFontSize = 10.f; // not used yet

// TODO: use autoscaling for noteView label
static const CGFloat kNoteViewWidth = 68.f;

static const CGSize  kAvatarViewSize = { .width=25.f, .height=25.f };
static const CGFloat kAvatarCornerRadius = 4.f;
static const CGFloat kAvatarMarginRight = 8.0f;

static const CGFloat kMinorVerticalSeparator = 5.0f;
static const CGFloat kMajorVerticalSeparator = 7.0f;

static const CGFloat kAuthorAttributeHeight = 10.0f;
static const CGFloat kAuthorNameHeight = 18.0f;
static const CGFloat kAuthorDetailHeight = 10.0f;

@interface LFSAttributedTextCell ()
// store hash to avoid relayout of same HTML
@property (nonatomic, assign) NSUInteger htmlHash;
@end

@implementation LFSAttributedTextCell

#pragma mark - Properties
@synthesize contentBodyView = _contentBodyView;
@synthesize contentImage = _contentImage;

@synthesize contentAccessoryRightView = _contentAccessoryRightView;
@synthesize contentTitleView = _contentTitleView;

@synthesize htmlHash = _htmlHash;

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

- (void)setContentImage:(UIImage*)image
{
    // store original-size image
    _contentImage = image;
    
    // we are on a non-Retina device
    UIScreen *screen = [UIScreen mainScreen];
    CGSize size;
    if ([screen respondsToSelector:@selector(scale)] && [screen scale] == 2.f)
    {
        // Retina: scale to 2x frame size
        size = CGSizeMake(kAvatarViewSize.width * 2.f,
                          kAvatarViewSize.height * 2.f);
    }
    else
    {
        // non-Retina
        size = kAvatarViewSize;
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

#pragma mark - Class methods

static UIFont *titleFont = nil;
static UIFont *bodyFont = nil;
static UIFont *dateFont = nil;
static UIColor *dateColor = nil;

+ (void)initialize {
    if(self == [LFSAttributedTextCell class]) {
        titleFont = [UIFont boldSystemFontOfSize:kAuthorNameFontSize];
        bodyFont = [UIFont fontWithName:kContentFontName
                                   size:kContentFontSize];
        dateFont = [UIFont systemFontOfSize:kNoteFontSize];
        dateColor = [UIColor lightGrayColor];
    }
}

#pragma mark - Properties

-(LFSBasicHTMLLabel*)contentBodyView
{
	if (_contentBodyView == nil) {
        const CGFloat kHeaderHeight = kPaddingTop + kAvatarViewSize.height + kMinorVerticalSeparator;
        CGRect frame = CGRectMake(kPaddingLeft,
                                  kHeaderHeight,
                                  self.bounds.size.width - kPaddingLeft - kContentPaddingRight,
                                  self.bounds.size.height - kHeaderHeight);
        
        // initialize
		_contentBodyView = [[LFSBasicHTMLLabel alloc] initWithFrame:frame];
        
        // configure
        [_contentBodyView setFont:bodyFont];
        [_contentBodyView setLineSpacing:kContentLineSpacing];
        
        // add to superview
		[self.contentView addSubview:_contentBodyView];
	}
	return _contentBodyView;
}

- (UILabel *)contentTitleView
{
	if (_contentTitleView == nil) {
        CGFloat leftColumnWidth = kPaddingLeft + kAvatarViewSize.width + kAvatarMarginRight;
        CGFloat rightColumnWidth = kNoteViewWidth + kPaddingRight;
        
        CGRect frame;
        frame.size = CGSizeMake(self.bounds.size.width - leftColumnWidth - rightColumnWidth, kAuthorNameHeight);
        frame.origin = CGPointMake(leftColumnWidth, kPaddingTop);
        
        // initialize
		_contentTitleView = [[UILabel alloc] initWithFrame:frame];
        
        // configure
        [_contentTitleView setFont:titleFont];
        
        // add to superview
		[self.contentView addSubview:_contentTitleView];
	}
	return _contentTitleView;
}

- (UILabel *)contentAccessoryRightView
{
	if (_contentAccessoryRightView == nil) {
		_contentAccessoryRightView = [[UILabel alloc] init];
        [_contentAccessoryRightView setFont:dateFont];
        [_contentAccessoryRightView setTextColor:dateColor];
        [_contentAccessoryRightView setTextAlignment:NSTextAlignmentRight];
		[self.contentView addSubview:_contentAccessoryRightView];
	}
	return _contentAccessoryRightView;
}

#pragma mark - Lifecycle
-(id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:reuseIdentifier];
    if (self)
    {
        _contentAccessoryRightView = nil;
        _contentTitleView = nil;
        
        [self setAccessoryType:UITableViewCellAccessoryNone];
        [self.imageView setContentMode:UIViewContentModeScaleToFill];
        
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
        self.imageView.layer.cornerRadius = kAvatarCornerRadius;
        self.imageView.layer.masksToBounds = YES;
    }
    return self;
}

-(void)dealloc{
    _contentBodyView = nil;
    _contentTitleView = nil;
    _contentAccessoryRightView = nil;
    _contentImage = nil;
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
    
    const CGFloat kLeftColumnWidth = kPaddingLeft + kAvatarViewSize.width + kAvatarMarginRight;
    const CGFloat kRightColumnWidth = kNoteViewWidth + kPaddingRight;
    
    // layout title view
    CGRect titleFrame = self.contentTitleView.frame;
    titleFrame.size.width = width - kLeftColumnWidth - kRightColumnWidth;
    [self.contentTitleView setFrame:titleFrame];
    
    // layout note view
    CGRect noteFrame = self.contentAccessoryRightView.frame;
    noteFrame.origin.x = width - kRightColumnWidth;
    [self.contentAccessoryRightView setFrame:noteFrame];
    
    // layout avatar
    CGRect imageViewFrame;
    imageViewFrame.origin = CGPointMake(kPaddingLeft, kPaddingTop);
    imageViewFrame.size = kAvatarViewSize;
    self.imageView.frame = imageViewFrame;
    
    
    // on iOS6, textContentView height sometimes overshoots
    // cell height. The code below remediates this
    //CGRect textContentFrame = self.textContentView.frame;
    //textContentFrame.size.height = self.frame.size.height - kHeaderHeight;
    //[self.textContentView setFrame:textContentFrame];
}

#pragma mark - Public methods
- (CGFloat)requiredRowHeightWithFrameWidth:(CGFloat)width
{
    CGSize neededSize = [self.contentBodyView
                         sizeThatFits:
                         CGSizeMake(width - kPaddingLeft - kContentPaddingRight,
                                    CGFLOAT_MAX)];
    
    CGRect imageViewFrame = self.imageView.frame;
    const CGFloat kHeaderHeight = kPaddingTop + kAvatarViewSize.height + kMinorVerticalSeparator;
	CGFloat result = kPaddingBottom + MAX(neededSize.height + kHeaderHeight,
                              imageViewFrame.size.height +
                              imageViewFrame.origin.y);
    return result;
}

@end
