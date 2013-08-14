//
//  LFAttributedTextCell.m
//  CommentStream
//
//  Created by Eugene Scherba on 8/14/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import "LFAttributedTextCell.h"

static const NSInteger kLeftColumnWidth = 50;
static const NSInteger kBottomPadding = 8;

@implementation LFAttributedTextCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (UITableView *)_containingTableView
{
    // copy-and-paste from DTCoreText -- since the original DTAttributedTextCell
    // class does not expose this method for public access
	UIView *tableView = self.superview;
	
	while (tableView)
	{
		if ([tableView isKindOfClass:[UITableView class]])
		{
			return (UITableView *)tableView;
		}
		
		tableView = tableView.superview;
	}
	
	return nil;
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
		CGFloat neededContentHeight = [self requiredRowHeightInTableView:[self _containingTableView]];
        
		// after the first call here the content view size is correct
		CGRect frame = CGRectMake(kLeftColumnWidth, 0, self.contentView.bounds.size.width - kLeftColumnWidth, neededContentHeight);
		self.attributedTextContextView.frame = frame;
        
        CGRect imageFrame = self.imageView.frame;
        self.imageView.frame = CGRectMake(imageFrame.origin.x, self.attributedTextContextView.layoutFrame.frame.origin.y, imageFrame.size.width,  imageFrame.size.height);
	}
}

- (CGFloat)requiredRowHeightInTableView:(UITableView *)tableView
{
    return MAX([super requiredRowHeightInTableView:tableView], self.imageView.frame.size.height + self.imageView.frame.origin.y) + kBottomPadding;
}

@end
