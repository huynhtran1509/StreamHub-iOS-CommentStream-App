//
//  LFSNewCommentViewController.h
//  CommentStream
//
//  Created by Eugene Scherba on 9/13/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <FilepickerSDK/FPPicker.h>

#import "LFSUser.h"
#import "LFSContent.h"
#import "LFSWriteCommentView.h"

@protocol LFSPostViewControllerDelegate;

@interface LFSPostViewController : UIViewController <LFSWriteCommentViewDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, FPPickerDelegate>

@property (nonatomic, copy) NSDictionary *collection;
@property (nonatomic, copy) NSString *collectionId;
@property (nonatomic, strong) LFSContent *replyToContent;

@property (nonatomic, strong) LFSUser *user;
@property (nonatomic, strong) UIImage *avatarImage;

@property (nonatomic, weak) id<LFSPostViewControllerDelegate> delegate;

@property (nonatomic, strong) UIActionSheet *actionSheet;

-(void)clearContent;

@end


@protocol LFSPostViewControllerDelegate <NSObject>

@optional

-(id<LFSPostViewControllerDelegate>)collectionViewController;
-(void)didPostContentWithOperation:(NSOperation*)operation response:(id)responseObject;
-(void)didSendPostRequestWithReplyTo:(NSString*)replyTo;

@end
