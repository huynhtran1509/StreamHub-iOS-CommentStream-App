//
//  LFSDetailView.h
//  CommentStream
//
//  Created by Eugene Scherba on 9/26/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class LFSRemote;
@protocol LFSDetailViewDelegate;

@interface LFSDetailView : UIView

@property (weak, nonatomic) id<LFSDetailViewDelegate>delegate;
@property (assign, nonatomic) BOOL contentLikedByUser;

@end

@protocol LFSDetailViewDelegate <NSObject>

// composite objects
-(LFSRemote*)profileRemote;
-(LFSRemote*)contentRemote;

// primitives
-(NSString*)authorDisplayName;
-(NSString*)contentBodyHtml;
-(UIImage*)avatarImage;
-(NSDate*)contentCreationDate;

// actions
- (void)didSelectLike:(id)sender;
- (void)didSelectReply:(id)sender;

@end

// a little object we use to pass around information about
// remote links
@interface LFSRemote : NSObject
@property (strong, nonatomic) UIImage *iconImage;
@property (strong, nonatomic) NSString *urlString;
@property (strong, nonatomic) NSString *displayString;

-(id)initWithURLString:(NSString*)urlString
         displayString:(NSString*)displayString
             iconImage:(UIImage*)iconImage;
@end