//
//  LFAttributedTextCell.m
//  CommentStream
//
//  Created by Eugene Scherba on 8/14/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import "LFSAttributedTextCell.h"

static const NSInteger kLeftColumnWidth = 55;
static const NSInteger kBottomInset = 5;
static const NSInteger kHeaderHeight = 30;
static const NSInteger kNoteWidth = 80;
static const CGRect avatarFrame = { {15, 8}, {25, 25} }; // origin: x=15, y=8; size: 25x25


@implementation LFSAttributedTextCell {
    UILabel *_titleView;
    UILabel *_noteView;
}

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
                                      self.contentView.bounds.size.width - kLeftColumnWidth - kNoteWidth,
                                      kHeaderHeight);
        _noteView.frame = CGRectMake(self.contentView.bounds.size.width - kNoteWidth,
                                     0,
                                     kNoteWidth,
                                     kHeaderHeight);
        self.imageView.frame = avatarFrame;
	}
}

- (DTAttributedTextContentView *)attributedTextContextView
{
    // adjust insets to x=0, y=0
	DTAttributedTextContentView *_attributedTextContextView = [super attributedTextContextView];
    _attributedTextContextView.edgeInsets = UIEdgeInsetsMake(0, 0, 5, 5);
    return _attributedTextContextView;
}

- (UILabel *)titleView
{
	if (!_titleView) {
		_titleView = [[UILabel alloc] initWithFrame:self.contentView.bounds];
        _titleView.font = [UIFont fontWithName:@"AvenirNextCondensed-DemiBold" size:16.0f];
		[self.contentView addSubview:_titleView];
	}
	return _titleView;
}

- (UILabel *)noteView
{
	if (!_noteView) {
		_noteView = [[UILabel alloc] initWithFrame:self.contentView.bounds];
        _noteView.font = [UIFont fontWithName:@"Futura-MediumItalic" size:12.0f];
        _noteView.textColor = [UIColor grayColor];
		[self.contentView addSubview:_noteView];
	}
	return _noteView;
}

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

@end
