//
//  LFAttributedTextCell.h
//  CommentStream
//
//  Created by Eugene Scherba on 8/14/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import "DTAttributedTextCell.h"

@interface LFAttributedTextCell : DTAttributedTextCell

@property (nonatomic, readonly) UILabel *titleView;
@property (nonatomic, readonly) UILabel *noteView;

@end
