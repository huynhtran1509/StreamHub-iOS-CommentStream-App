//
//  DTLazyImageView+LFLazyImageView.h
//  CommentStream
//
//  Created by Eugene Scherba on 8/13/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import "DTLazyImageView.h"
#import <DTCoreText/DTAttributedTextContentView.h>

@interface DTLazyImageView (TextContentView)

@property (nonatomic, strong) DTAttributedTextContentView* textContentView;

@end
