//
//  UILabel+VerticalAlign.m
//  CommentStream
//
//  Created by Eugene Scherba on 9/27/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import <math.h>
#import "UILabel+VerticalAlign.h"

@implementation UILabel (VerticalAlign)

- (void)setTextVerticalAlignmentCenter
{
    CGSize textSize = [self.text sizeWithFont:self.font
                            constrainedToSize:self.bounds.size
                                lineBreakMode:self.lineBreakMode];
    
    CGRect textRect = CGRectMake(self.frame.origin.x,
                                 self.frame.origin.y + floorf((self.bounds.size.height - textSize.height) / 2.f),
                                 self.bounds.size.width,
                                 textSize.height);
    [self setFrame:textRect];
    [self setNeedsDisplay];
}

@end
