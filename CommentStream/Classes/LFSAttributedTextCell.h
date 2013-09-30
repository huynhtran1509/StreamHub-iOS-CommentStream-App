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

@interface LFSAttributedTextCell : UITableViewCell <UIAppearance>

#pragma mark - Properties
@property (strong, nonatomic) LFSHeader* profileLocal;
@property (strong, nonatomic) LFSTriple* profileRemote;
@property (strong, nonatomic) LFSTriple* contentRemote;

@property (copy, nonatomic) NSString *headerAccessoryRightText;

@property (nonatomic, strong) UIImage *headerImage;

#pragma mark - UIApperance properties
@property (nonatomic, strong) UIFont *headerTitleFont UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *headerTitleColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIFont *bodyFont UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *bodyColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIFont *headerAccessoryRightFont UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *headerAccessoryRightColor UI_APPEARANCE_SELECTOR;

// Under iOS7, we can simply set backgroundColor of table cells via
// UIAppearance protocol, but for iOS6 we need to do this workaround:
@property (nonatomic, weak) UIColor *backgroundCellColor UI_APPEARANCE_SELECTOR;

#pragma mark - Methods
- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;
- (CGFloat)requiredRowHeightWithFrameWidth:(CGFloat)width;
- (void)setHTMLString:(NSString *)html;

@end
