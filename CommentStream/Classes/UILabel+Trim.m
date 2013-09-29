//
//  UILabel+Trim.m
//  CommentStream
//
//  Created by Eugene Scherba on 9/27/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import <math.h>
#import "UILabel+Trim.h"

@implementation UILabel (Trim)

- (void)resizeVerticalCenterRightTrim
{
    CGSize textSize = [self.text sizeWithFont:self.font
                            constrainedToSize:self.bounds.size
                                lineBreakMode:self.lineBreakMode];
    
    CGRect textRect = CGRectMake(self.frame.origin.x,
                                 self.frame.origin.y + floorf((self.bounds.size.height - textSize.height) / 2.f),
                                 textSize.width,
                                 textSize.height);
    [self setFrame:textRect];
    [self setNeedsDisplay];
}

@end
