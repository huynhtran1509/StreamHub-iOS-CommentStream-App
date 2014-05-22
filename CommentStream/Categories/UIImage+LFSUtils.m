//
//  UIImage+LFSUtils.m
//  CommentStream
//
//  Created by Eugene Scherba on 10/6/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import "UIImage+LFSUtils.h"

@implementation UIImage (LFSUtils)

+ (UIImage *)imageWithColor:(UIColor *)color {
    
    static const CGRect rect = {
        .origin = {0.f, 0.f},
        .size   = {1.f, 1.f}
    };
    
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.f);
    [color setFill];
    UIRectFill(rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage*)simpleResizedImageWithContentMode:(UIViewContentMode)contentMode bounds:(CGSize) bounds interpolationQuality:(CGInterpolationQuality)quality
{
    CGSize size = self.size;
    CGSize targetSize;
    
    switch (contentMode) {
        case UIViewContentModeScaleAspectFill:
            // Some portion of the content may be clipped to fill the view’s bounds.
            if (size.height * bounds.width > bounds.height * size.width) {
                // pick size.width
                targetSize.width = bounds.width;
                targetSize.height = (size.height / size.width) * bounds.width;
            } else {
                // pick size.height
                targetSize.height = bounds.height;
                targetSize.width = (size.width / size.height) * bounds.height;
            }
            break;
            
        case UIViewContentModeScaleAspectFit:
            // Any remaining area of the view’s bounds is transparent.
            if (size.height * bounds.width > bounds.height * size.width) {
                // pick size.height
                targetSize.height = bounds.height;
                targetSize.width = (size.width / size.height) * bounds.height;
            } else {
                // pick size.width
                targetSize.width = bounds.width;
                targetSize.height = (size.height / size.width) * bounds.width;
            }
            break;
            
        case UIViewContentModeScaleToFill:
            // Aspect ratio not preserved
            targetSize = bounds;
            break;
            
        default:
            [NSException raise:NSInvalidArgumentException
                        format:@"Unsupported content mode: %d", contentMode];
    }
    
    CGRect targetRect;
    targetRect.origin = CGPointZero;
    targetRect.size = targetSize;
    
    // don't call UIGraphicsBeginImageContext when supporting Retina,
    // instead call UIGraphicsBeginImageContextWithOptions with zero
    // for scale
    UIGraphicsBeginImageContextWithOptions(bounds, YES, 0.f);
    [self drawInRect:targetRect];
    UIImage *processedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return processedImage;
}

@end
