//
//  LFSTextField.m
//  CommentStream
//
//  Created by Eugene Scherba on 9/17/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import <StreamHub-iOS-SDK/LFSConstants.h>
#import "LFSTextField.h"

@interface LFSTextField ()
@property (nonatomic, strong) CAShapeLayer *shadowLayer;
@property (nonatomic, strong) CAShapeLayer *maskLayer;
@end

@implementation LFSTextField

#pragma mark - Properties
@synthesize shadowLayer = _shadowLayer;
@synthesize textEdgeInsets = _textEdgeInsets;
@synthesize maskLayer = _maskLayer;

#pragma mark - Lifecycle
-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setFont:[UIFont systemFontOfSize:13.0f]];
        [self setAutoresizingMask:
         (UIViewAutoresizingFlexibleHeight |
          UIViewAutoresizingFlexibleWidth)];
        
        if (LFS_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(LFSSystemVersion70))
        {
            // iOS7
            [self setTextEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
            
            [self.layer setMasksToBounds:YES];
            [self.layer setCornerRadius:6.0f];
            [self.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
            [self.layer setBorderWidth:0.5f];
        } else {
            // call drawRect when orientation changes
            [self setContentMode:UIViewContentModeRedraw];
            
            _shadowLayer = [CAShapeLayer layer];
            _maskLayer = [CAShapeLayer layer];
            
            [_shadowLayer setShadowColor:[[UIColor blackColor] CGColor]];
            [_shadowLayer setShadowOffset:CGSizeMake(0.5f, 0.5f)];
            [_shadowLayer setShadowOpacity:1.0f];
            [_shadowLayer setShadowRadius:2.0f];
            [_shadowLayer setFillRule:kCAFillRuleEvenOdd];
            [_shadowLayer setMask:_maskLayer];
            [self.layer addSublayer:_shadowLayer];
        }
        [self.layer setBackgroundColor:
         [[UIColor whiteColor] CGColor]];
    }
    return self;
}

-(void)dealloc
{
    _shadowLayer = nil;
    _maskLayer = nil;
}

#pragma mark - Overrides
- (void)drawRect:(CGRect)rect {
    if (LFS_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(LFSSystemVersion70)) {
        [super drawRect:rect];
    } else {
        [self drawRoundedWithRect:rect];
    }
}

- (CGRect)textRectForBounds:(CGRect)bounds {
	return UIEdgeInsetsInsetRect([super textRectForBounds:bounds], _textEdgeInsets);
}

#pragma mark - Private methods
-(void)drawRoundedWithRect:(CGRect)rect
{
    // For iOS6 or earlier only
    CGFloat radius = rect.size.height / 2.0f;
    self.layer.cornerRadius = radius;
    [_shadowLayer setFrame:rect];
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectInset(rect, -42, -42));
    CGPathRef innerPath =
    [[UIBezierPath bezierPathWithRoundedRect:rect
                                cornerRadius:radius] CGPath];
    CGPathAddPath(path, NULL, innerPath);
    CGPathCloseSubpath(path);
    [_shadowLayer setPath:path];
    CGPathRelease(path);
    [_maskLayer setPath:innerPath];
    
    [self setTextEdgeInsets:UIEdgeInsetsMake(radius - 9.0f, 8.0f, 0.0f, 0.0f)];
    
}

@end
