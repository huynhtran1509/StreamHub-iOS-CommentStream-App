//
//  LFSDetailView.h
//  CommentStream
//
//  Created by Eugene Scherba on 9/26/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "LFSTriple.h"
#import "LFSHeader.h"

@protocol LFSDetailViewDelegate;

@interface LFSDetailView : UIView

@property (weak, nonatomic) id<LFSDetailViewDelegate>delegate;
@property (assign, nonatomic) BOOL isLikedByUser;

@property (strong, nonatomic) LFSHeader* profileLocal;
@property (strong, nonatomic) LFSTriple* profileRemote;
@property (strong, nonatomic) LFSTriple* contentRemote;

@property (copy, nonatomic) NSString* contentBodyHtml;
@property (copy, nonatomic) NSString* contentDetail;

@end

// thanks to this protocol, LFSDetailView does not need
// to know anything about the structure of the model object
@protocol LFSDetailViewDelegate <NSObject>

// actions
- (void)didSelectLike:(id)sender;
- (void)didSelectReply:(id)sender;

@end
