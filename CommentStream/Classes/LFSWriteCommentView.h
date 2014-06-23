//
//  LFSWriteCommentView.h
//  CommentStream
//
//  Created by Eugene Scherba on 10/16/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LFSResource.h"

@protocol LFSWriteCommentViewDelegate;

@interface LFSWriteCommentView : UIView <UITextViewDelegate>

@property (nonatomic, strong) LFSResource* profileLocal;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, assign) id<LFSWriteCommentViewDelegate>delegate;

@property (readonly, nonatomic) UIImageView *attachmentImageView;
@end


@protocol LFSWriteCommentViewDelegate <NSObject>

-(void)didClickAddPhotoButton;

@end
