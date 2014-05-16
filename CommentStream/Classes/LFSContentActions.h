//
//  LFSContentActions.h
//  CommentStream
//
//  Created by Eugene Scherba on 5/16/14.
//  Copyright (c) 2014 Livefyre. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LFSContent.h"

typedef NS_ENUM(NSUInteger, LFSContentAction) {
    /*! Unsolicited advertising (flagging will delete content when performed by moderator) */
    LFSContentAction1 = 0u,      // 0
    LFSContentAction2,           // 1
    LFSContentAction3,           // 2
    LFSContentAction4            // 3
};
// }}}


@protocol LFSContentActionsDelegate;

@interface LFSContentActions : NSObject <UIActionSheetDelegate>

@property (nonatomic, assign) id<LFSContentActionsDelegate> delegate;
@property (nonatomic, strong) UIActionSheet *actionSheet;

@end

@protocol LFSContentActionsDelegate <NSObject>

-(void)flagContentWithFlag:(LFSContentFlag)flag;
-(void)performAction:(LFSContentAction)action;

@end
