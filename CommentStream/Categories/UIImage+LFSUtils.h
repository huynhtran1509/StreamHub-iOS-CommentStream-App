//
//  UIImage+LFSUtils.h
//  CommentStream
//
//  Created by Eugene Scherba on 10/6/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIImage (LFSUtils)

+ (UIImage *)imageWithColor:(UIColor *)color;
- (UIImage*)simpleResizedImageWithContentMode:(UIViewContentMode)contentMode bounds:(CGSize) bounds interpolationQuality:(CGInterpolationQuality)quality;

@end
