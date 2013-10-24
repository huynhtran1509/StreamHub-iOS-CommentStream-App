//
//  LFSReplyHeaderView.h
//  CommentStream
//
//  Created by Eugene Scherba on 10/16/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LFSResource.h"

@interface LFSReplyHeaderView : UIView <UITextViewDelegate>

@property (nonatomic, strong) LFSResource* profileLocal;
@property (nonatomic, strong) UITextView *textView;

@end
