//
//  LFSDetailView.h
//  CommentStream
//
//  Created by Eugene Scherba on 9/26/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "LFSResource.h"

@protocol LFSDetailViewDelegate;

@interface LFSDetailView : UIView

@property (nonatomic, weak) id<LFSDetailViewDelegate>delegate;

@property (nonatomic, strong) LFSResource* profileLocal;
@property (nonatomic, strong) LFSResource* profileRemote;
@property (nonatomic, strong) LFSResource* contentRemote;

@property (nonatomic, copy) NSString* contentBodyHtml;

@property (nonatomic, strong) NSDate* contentDate;

@property (readonly, nonatomic) UIButton *button1;
@property (readonly, nonatomic) UIButton *button2;

@end

// thanks to this protocol, LFSDetailView does not need
// to know anything about the structure of the model object
@protocol LFSDetailViewDelegate <NSObject>

// actions
- (void)didSelectLike:(id)sender;
- (void)didSelectReply:(id)sender;

@end
