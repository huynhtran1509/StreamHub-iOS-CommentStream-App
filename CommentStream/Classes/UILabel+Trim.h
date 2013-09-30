//
//  UILabel+Trim.h
//  CommentStream
//
//  Created by Eugene Scherba on 9/27/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (Trim)

// vertically center text, rescale to expected
// size, and trim off right margin
- (void)resizeVerticalCenterRightTrim;

@end
