//
//  LFAttributedTextCell.m
//  CommentStream
//
//  Created by Eugene Scherba on 8/14/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import <StreamHub-iOS-SDK/LFSConstants.h>
#import "LFSBasicHTMLParser.h"
#import "LFSAttributedTextCell.h"

// TODO: turn some of these consts into properties for easier customization
static const CGFloat kLeftColumnWidth = 60;
static const CGFloat kBottomInset = 5;
static const CGFloat kHeaderHeight = 30;
static const CGFloat kRightColumnWidth = 80;
static const CGFloat kAvatarCornerRadius = 4;
static const CGFloat kNoteRightInset = 12;

@interface LFSAttributedTextCell ()

@end

@implementation LFSAttributedTextCell {
    UILabel *_titleView;
    UILabel *_noteView;
	NSUInteger _htmlHash; // preserved hash to avoid relayouting for same HTML
}

#pragma mark - Properties
@synthesize textContentView = _textContentView;

- (void)setHTMLString:(NSString *)html
{
	// we don't preserve the html but compare it's hash
	NSUInteger newHash = [html hash];

	if (newHash == _htmlHash)
	{
		return;
	}
	
	_htmlHash = newHash;
	
    // Example 1: parse HTML in attributed string
	//NSData *data = [html dataUsingEncoding:NSUTF8StringEncoding];
	//NSAttributedString *string = [[NSAttributedString alloc] initWithHTMLData:data documentAttributes:NULL];
	[self.textContentView setHTMLString:html];
	
	[self setNeedsLayout];
}

- (UIImage*)avatarImage
{
    return self.imageView.image;
}

- (void)setAvatarImage:(UIImage*)image
{
    // scale down image if we are not on a Retina device
    UIScreen *screen = [UIScreen mainScreen];
    if ([screen respondsToSelector:@selector(scale)] && [screen scale] == 2) {
        // we are on a Retina device
        self.imageView.image = image;
        [self setNeedsLayout];
    }
    else {
        // we are on a non-Retina device
        CGSize size = self.imageView.frame.size;
        dispatch_queue_t queue =
        dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
            
            // scale image on a background thread
            // Note: this will not preserve aspect ratio
            UIGraphicsBeginImageContext(size);
            [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
            UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            // display image on the main thread
            dispatch_sync(dispatch_get_main_queue(), ^{
                self.imageView.image = scaledImage;
                [self setNeedsLayout];
            });
        });
    }
}

#pragma mark - Class methods

static UIFont *titleFont = nil;
static UIFont *noteFont = nil;
static UIColor *noteColor = nil;

+ (void)initialize {
    if(self == [LFSAttributedTextCell class]) {
        titleFont = [UIFont fontWithName:@"AvenirNextCondensed-DemiBold" size:16.0f];
        noteFont = [UIFont fontWithName:@"Futura-MediumItalic" size:12.0f];
        noteColor = [UIColor grayColor];
    }
}

#pragma mark - Properties

-(LFSBasicHTMLLabel*)textContentView
{
	if (!_textContentView) {
        // after the first call here the content view size is correct
        CGRect frame = CGRectMake(kLeftColumnWidth,
                                  kHeaderHeight,
                                  self.contentView.bounds.size.width - kLeftColumnWidth,
                                  self.contentView.bounds.size.height - kHeaderHeight);
        
		_textContentView = [[LFSBasicHTMLLabel alloc] initWithFrame:frame];
        //[_textContentView setFont:titleFont];
        [_textContentView setDelegate:self];
		[self.contentView addSubview:_textContentView];
	}
	return _textContentView;
}

- (UILabel *)titleView
{
	if (!_titleView) {
		_titleView = [[UILabel alloc] init];
        [_titleView setFont:titleFont];
		[self.contentView addSubview:_titleView];
	}
	return _titleView;
}

- (UILabel *)noteView
{
	if (!_noteView) {
		_noteView = [[UILabel alloc] init];
        [_noteView setFont:noteFont];
        [_noteView setTextColor:noteColor];
        [_noteView setTextAlignment:NSTextAlignmentRight];
		[self.contentView addSubview:_noteView];
	}
	return _noteView;
}

#pragma mark - Lifecycle
-(id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self)
    {
        _noteView = nil;
        _titleView = nil;
        
        [self setAccessoryType:UITableViewCellAccessoryNone];
        [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
        //[self setHasFixedRowHeight:NO];
        self.textContentView.delegate = self;
        //self.textContentView.edgeInsets = UIEdgeInsetsMake(0, 0, 5, 5);
        
        if (LFS_SYSTEM_VERSION_LESS_THAN(LFSSystemVersion70)) {
            // iOS7-like selected background color
            [self setSelectionStyle:UITableViewCellSelectionStyleGray];
            UIView *selectionColor = [[UIView alloc] init];
            selectionColor.backgroundColor = [UIColor colorWithRed:(217/255.0)
                                                             green:(217/255.0)
                                                              blue:(217/255.0)
                                                             alpha:1];
            //selectionColor.backgroundColor = [UIColor blackColor]; // for testing translucency
            self.selectedBackgroundView = selectionColor;
        }
        self.imageView.layer.cornerRadius = kAvatarCornerRadius;
        self.imageView.layer.masksToBounds = YES;
    }
    return self;
}

-(void)dealloc{
    _textContentView.delegate = nil;
    //self.textContentView.attributedString = nil;
    _titleView = nil;
    _noteView = nil;
}

#pragma mark - Private methods

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	if (!self.superview)
	{
		return;
	}
    
    CGFloat neededContentHeight = [self requiredRowHeight];
    
    // after the first call here the content view size is correct
    CGRect frame = CGRectMake(kLeftColumnWidth,
                              kHeaderHeight,
                              self.contentView.bounds.size.width - kLeftColumnWidth,
                              neededContentHeight - kHeaderHeight);
    self.textContentView.frame = frame;
    
    _titleView.frame = CGRectMake(kLeftColumnWidth,
                                  0,
                                  self.contentView.bounds.size.width - kLeftColumnWidth - kRightColumnWidth,
                                  kHeaderHeight);
    _noteView.frame = CGRectMake(self.contentView.bounds.size.width - kRightColumnWidth,
                                 0,
                                 kRightColumnWidth - kNoteRightInset,
                                 kHeaderHeight);
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
        ([UIScreen mainScreen].scale == 2.0f))
    {
        // Retina display, okay to use half-points
        self.imageView.frame = CGRectMake( 12.f, 7.f, 37.5f, 37.5f );
    }
    else
    {
        // non-Retina display
        self.imageView.frame = CGRectMake( 12.f, 7.f, 37.f, 37.f );
    }
    
}

#pragma mark - Public methods
- (CGFloat)requiredRowHeight
{
    CGSize maxSize = self.textContentView.frame.size;
    maxSize.height = 1000.f;
    CGSize neededSize = [self.textContentView sizeThatFits:maxSize];

	// note: non-integer row heights caused trouble < iOS 5.0
	return MAX(neededSize.height + kHeaderHeight,
               self.imageView.frame.size.height + self.imageView.frame.origin.y)
    + kBottomInset;
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
