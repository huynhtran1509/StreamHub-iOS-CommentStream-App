//
//  LFAttributedTextCell.h
//  CommentStream
//
//  Created by Eugene Scherba on 8/14/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <DTCoreText/DTAttributedTextCell.h>

#import "DTLazyImageView+TextContentView.h"

@interface LFSAttributedTextCell : DTAttributedTextCell <DTAttributedTextContentViewDelegate, DTLazyImageViewDelegate>

@property (nonatomic, readonly) UILabel *titleView;
@property (nonatomic, readonly) UILabel *noteView;

- (void)assignImage:(UIImage*)image;

@end
