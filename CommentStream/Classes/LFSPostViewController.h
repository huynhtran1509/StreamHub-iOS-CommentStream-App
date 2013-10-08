//
//  LFSNewCommentViewController.h
//  CommentStream
//
//  Created by Eugene Scherba on 9/13/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "LFSContent.h"

@protocol LFSPostNewControllerDelegate;

@interface LFSPostViewController : UIViewController

@property (nonatomic, copy) NSDictionary *collection;
@property (nonatomic, copy) NSString *collectionId;
@property (nonatomic, strong) LFSContent *replyToContent;

@property (nonatomic, assign) id<LFSPostNewControllerDelegate> delegate;

@end


@protocol LFSPostNewControllerDelegate <NSObject>

-(void)didSucceedPostingContentWithResponse:(id)responseObject;

@end
