//
//  LFAttributedTextCell.h
//  CommentStream
//
//  Created by Eugene Scherba on 8/14/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "LFSBasicHTMLLabel.h"

@interface LFSAttributedTextCell : UITableViewCell

@property (nonatomic, readonly) UILabel *titleView;
@property (nonatomic, readonly) UILabel *noteView;
@property (nonatomic, strong) LFSBasicHTMLLabel *textContentView;
@property (nonatomic, strong) UIImage *avatarImage;

#pragma mark - basics
- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;
- (CGFloat)requiredRowHeightWithFrameWidth:(CGFloat)width;
- (void)setHTMLString:(NSString *)html;

@end
