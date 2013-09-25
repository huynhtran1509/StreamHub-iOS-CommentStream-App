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
    [[UIColor colorWithRed:(200.f/255.f) green:(199.f/255.f) blue:(204.f/255.f) alpha:1.f] setStroke];
    
    // top 1px line
    UIBezierPath *horLineTop = [[UIBezierPath alloc] init];
    [horLineTop moveToPoint:rect.origin];
    [horLineTop addLineToPoint:CGPointMake(rect.origin.x + rect.size.width, rect.origin.y)];
    horLineTop.lineWidth = 1.f;
    [horLineTop stroke];
    
    // bottom 1px line
    UIBezierPath *horLineBottom = [[UIBezierPath alloc] init];
    [horLineBottom moveToPoint:CGPointMake(rect.origin.x,
                                           rect.origin.y + rect.size.height)];
    [horLineBottom addLineToPoint:CGPointMake(rect.origin.x + rect.size.width,
                                              rect.origin.y + rect.size.height)];
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
- (id) init
{
    self = [super init];
    [self applyTranslucentBackground];
    return self;
}

- (id)initWithFrame:(CGRect) frame
{
    self = [super initWithFrame:frame];
    [self applyTranslucentBackground];
    return self;
}

@end
