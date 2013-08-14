//
//  DTLazyImageView+LFLazyImageView.m
//  CommentStream
//
//  Created by Eugene Scherba on 8/13/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#include <objc/runtime.h>
#import "DTLazyImageView+TextContentView.h"

NSString * const kTextContentView  = @"kTextContentView";
NSString * const kImageAccessoryViewKey = @"kImageAccessoryViewKey";

// hack below allows us to add a read-write property onto a category.
// of course an alternative is subclassing.
//
@implementation DTLazyImageView (AccessoryViews)

- (void)setTextContentView:(DTAttributedTextContentView *)contentView
{
	objc_setAssociatedObject(self, &kTextContentView, contentView, OBJC_ASSOCIATION_RETAIN);
}

- (DTAttributedTextContentView*)textContentView
{
	return objc_getAssociatedObject(self, &kTextContentView);
}

@end
