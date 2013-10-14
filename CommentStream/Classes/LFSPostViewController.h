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

@protocol LFSPostViewControllerDelegate;

@interface LFSPostViewController : UIViewController

@property (nonatomic, copy) NSDictionary *collection;
@property (nonatomic, copy) NSString *collectionId;
@property (nonatomic, strong) LFSContent *replyToContent;

@property (nonatomic, weak) id<LFSPostViewControllerDelegate> delegate;

@end


@protocol LFSPostViewControllerDelegate <NSObject>

@optional
-(id)delegate; // super-delegate (LFSCollectionViewController)
-(void)didPostContentWithOperation:(NSOperation*)operation response:(id)responseObject;
-(void)didSendPostRequestWithReplyTo:(NSString*)replyTo;

@end
