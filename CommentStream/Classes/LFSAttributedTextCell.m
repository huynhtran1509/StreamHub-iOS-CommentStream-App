//
//  LFAttributedTextCell.m
//  CommentStream
//
//  Created by Eugene Scherba on 8/14/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import <StreamHub-iOS-SDK/LFSConstants.h>
#import <DTCoreText/DTImageTextAttachment.h>
#import <DTCoreText/DTLinkButton.h>

#import "LFSAttributedTextCell.h"

// TODO: turn some of these consts into properties for easier customization
static const CGFloat kLeftColumnWidth = 60;
static const CGFloat kBottomInset = 5;
static const CGFloat kHeaderHeight = 30;
static const CGFloat kRightColumnWidth = 80;
static const CGFloat avatarCornerRadius = 4;
static const CGFloat kNoteRightInset = 12;

@interface LFSAttributedTextCell ()

@end

@implementation LFSAttributedTextCell {
    UILabel *_titleView;
    UILabel *_noteView;
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
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self)
    {
        _noteView = nil;
        _titleView = nil;
        
        [self setAccessoryType:UITableViewCellAccessoryNone];
        [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [self setHasFixedRowHeight:NO];
        self.attributedTextContextView.delegate = self;
        self.attributedTextContextView.edgeInsets = UIEdgeInsetsMake(0, 0, 5, 5);
        
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
        self.imageView.layer.cornerRadius = avatarCornerRadius;
        self.imageView.layer.masksToBounds = YES;
    }
    return self;
}

-(void)dealloc{
    self.attributedTextContextView.delegate = nil;
    self.attributedTextContextView.attributedString = nil;
    _titleView = nil;
    _noteView = nil;
}

#pragma mark - Private ethods
- (void)layoutSubviews
{
	[super layoutSubviews];
	
	if (!self.superview)
	{
		return;
	}
    
	if (self.hasFixedRowHeight)
	{
		self.attributedTextContextView.frame = self.contentView.bounds;
	}
	else
	{
        SEL _containingTableView = NSSelectorFromString(@"_containingTableView");
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        UITableView *parentTable = [self performSelector:_containingTableView];
#pragma clang diagnostic pop
		CGFloat neededContentHeight = [self requiredRowHeightInTableView:parentTable];
        
		// after the first call here the content view size is correct
		CGRect frame = CGRectMake(kLeftColumnWidth,
                                  kHeaderHeight,
                                  self.contentView.bounds.size.width - kLeftColumnWidth,
                                  neededContentHeight - kHeaderHeight);
		self.attributedTextContextView.frame = frame;
        
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
            self.imageView.frame = CGRectMake( 12.f, 8.f, 37.5f, 37.5f );
        }
        else
        {
            // non-Retina display
            self.imageView.frame = CGRectMake( 12.f, 8.f, 37.f, 37.f );
        }
	}
}

#pragma mark - Public methods


- (void)assignImage:(UIImage*)image
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

// @Override DTAttributedTextCell method
- (CGFloat)requiredRowHeightInTableView:(UITableView *)tableView
{
	if (self.hasFixedRowHeight)
	{
		NSLog(@"Warning: you are calling %s even though the cell is configured with fixed row height",
              (const char *)__PRETTY_FUNCTION__);
	}
	
	CGFloat contentWidth = tableView.frame.size.width - kLeftColumnWidth;
	
	// reduce width for accessories
	switch (self.accessoryType)
	{
		case UITableViewCellAccessoryDisclosureIndicator:
		case UITableViewCellAccessoryCheckmark:
			contentWidth -= 20.0f;
			break;
		case UITableViewCellAccessoryDetailDisclosureButton:
			contentWidth -= 33.0f;
			break;
		case UITableViewCellAccessoryNone:
			break;
		default:
			NSLog(@"Warning: Sizing for UITableViewCellAccessoryDetailButton not implemented on %@",
                  NSStringFromClass([self class]));
			break;
	}
	
	// reduce width for grouped table views
	if (tableView.style == UITableViewStyleGrouped)
	{
		// left and right 10 px margins on grouped table views
		contentWidth -= 20;
	}
	
	CGSize neededSize = [self.attributedTextContextView
                         suggestedFrameSizeToFitEntireStringConstraintedToWidth:contentWidth];
	
	// note: non-integer row heights caused trouble < iOS 5.0
	return MAX(neededSize.height + kHeaderHeight,
               self.imageView.frame.size.height + self.imageView.frame.origin.y)
    + kBottomInset;
}

#pragma mark - DTAttributedTextContentViewDelegate
-(UIView*)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView
                        viewForLink:(NSURL *)url
                         identifier:(NSString *)identifier
                              frame:(CGRect)frame
{
    DTLinkButton *btn = [[DTLinkButton alloc] initWithFrame:frame];
    btn.URL = url;
    [btn addTarget:self action:@selector(openURL:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

-(UIView*)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView
                  viewForAttachment:(DTTextAttachment *)attachment frame:(CGRect)frame
{
    if ([attachment isKindOfClass:[DTImageTextAttachment class]]) {
        
        DTLazyImageView *imageView = [[DTLazyImageView alloc] initWithFrame:frame];
        imageView.textContentView = attributedTextContentView;
        imageView.delegate = self;
        
        // defer loading of image under given URL
        imageView.url = attachment.contentURL;
        return imageView;
    }
    return nil;
}

// allow display of images embedded in rich-text content
-(void)lazyImageView:(DTLazyImageView *)lazyImageView didChangeImageSize:(CGSize)size
{
    DTAttributedTextContentView *cv = lazyImageView.textContentView;
    NSURL *url = lazyImageView.url;
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"contentURL == %@", url];
    // update all attachments that match this URL (possibly multiple images with same size)
    for (DTTextAttachment *attachment in [cv.layoutFrame textAttachmentsWithPredicate:pred])
    {
        /*
         attachment.originalSize = imageSize;
         if (!CGSizeEqualToSize(imageSize, attachment.displaySize)) {
         attachment.displaySize = imageSize;
         }*/
        attachment.originalSize = size;
        lazyImageView.bounds = CGRectMake(0, 0,
                                          attachment.displaySize.width,
                                          attachment.displaySize.height);
    }
    
    // need to reset the layouter because otherwise we get the old framesetter or cached
    // layout frames. See https://github.com/Cocoanetics/DTCoreText/issues/307
    cv.layouter = nil;
    
    // laying out the entire string,
    // might be more efficient to only layout the paragraphs that contain these attachments
    [cv relayoutText];
}

/*
 -(UIView*)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView
 viewForAttributedString:(NSAttributedString *)string frame:(CGRect)frame
 {
 // initialize and return your view here
 }
 */

#pragma mark - Events

- (IBAction)openURL:(DTLinkButton*)sender
{
    [[UIApplication sharedApplication] openURL:sender.URL];
}

@end
