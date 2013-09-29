//
//  LFSContentToolbar.m
//  CommentStream
//
//  Created by Eugene Scherba on 9/25/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import "LFSContentToolbar.h"

@implementation LFSContentToolbar

- (void)drawRect:(CGRect)rect
{
    [[UIColor colorWithRed:(200.f/255.f)
                     green:(199.f/255.f)
                      blue:(204.f/255.f) alpha:1.f] setStroke];
    
    CGPoint origin = rect.origin;
    CGSize size = rect.size;
    
    // top 1px line
    UIBezierPath *horLineTop = [[UIBezierPath alloc] init];
    [horLineTop moveToPoint:origin];
    [horLineTop addLineToPoint:CGPointMake(origin.x + size.width, origin.y)];
    horLineTop.lineWidth = 1.f;
    [horLineTop stroke];
    
    // bottom 1px line
    UIBezierPath *horLineBottom = [[UIBezierPath alloc] init];
    [horLineBottom moveToPoint:CGPointMake(origin.x, origin.y + size.height)];
    [horLineBottom addLineToPoint:CGPointMake(origin.x + size.width,
                                              origin.y + size.height)];
    horLineBottom.lineWidth = 1.f;
    [horLineBottom stroke];
}

#pragma mark - Private methods
- (void)applyTranslucentBackground
{
    self.backgroundColor = [UIColor clearColor];
    self.opaque = NO;
    self.translucent = YES;
}

#pragma mark - Lifecycle
- (id)initWithFrame:(CGRect) frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self applyTranslucentBackground];
    }
    return self;
}

// for loading from storyboard or Xib
-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        [self applyTranslucentBackground];
    }
    return self;
}

@end
