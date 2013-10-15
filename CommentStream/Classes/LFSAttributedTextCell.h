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
#import "LFSTriple.h"
#import "LFSHeader.h"

extern const CGSize kCellImageViewSize;

@interface LFSAttributedTextCell : UITableViewCell <UIAppearance>

#pragma mark - Properties
@property (nonatomic, strong) LFSHeader* profileLocal;
@property (nonatomic, strong) LFSTriple* profileRemote;
@property (nonatomic, strong) LFSTriple* contentRemote;

@property (nonatomic, strong) NSDate* contentDate;

@property (nonatomic, strong) UIImage *indicatorIcon;

#pragma mark - UIApperance properties
@property (nonatomic, strong) UIFont *headerTitleFont UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *headerTitleColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIFont *bodyFont UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *bodyColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIFont *headerAccessoryRightFont UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *headerAccessoryRightColor UI_APPEARANCE_SELECTOR;

// Under iOS7, we can simply set backgroundColor of table cells via
// UIAppearance protocol, but for iOS6 we need to do this workaround:
@property (nonatomic, weak) UIColor *cellContentViewColor UI_APPEARANCE_SELECTOR;

@property (nonatomic, assign) CGFloat requiredBodyHeight;

@property (nonatomic, assign) CGFloat leftOffset;

#pragma mark - Methods
+ (CGFloat)cellHeightForBoundsWidth:(CGFloat)width withHTMLString:(NSString*)html withLeftOffset:(CGFloat)offset;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;
- (void)setHTMLString:(NSString *)html;

@end
