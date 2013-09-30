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

@property (nonatomic, readonly) UILabel *headerTitleView;
@property (nonatomic, readonly) UILabel *headerAccessoryRightView;
@property (nonatomic, strong) UIImage *headerImage;
@property (nonatomic, strong) LFSBasicHTMLLabel *contentBodyView;

#pragma mark - basics
- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;
- (CGFloat)requiredRowHeightWithFrameWidth:(CGFloat)width;
- (void)setHTMLString:(NSString *)html;

@end
