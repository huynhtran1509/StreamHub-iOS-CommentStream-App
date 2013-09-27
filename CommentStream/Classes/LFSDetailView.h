//
//  LFSDetailView.h
//  CommentStream
//
//  Created by Eugene Scherba on 9/26/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class LFSTriple;
@class LFSHeader;
@protocol LFSDetailViewDelegate;

@interface LFSDetailView : UIView

@property (weak, nonatomic) id<LFSDetailViewDelegate>delegate;
@property (assign, nonatomic) BOOL contentLikedByUser;

@end

// thanks to this protocol, LFSDetailView does not need
// to know anything about the structure of the model object
@protocol LFSDetailViewDelegate <NSObject>

// composite objects
-(LFSHeader*)profileLocal;
-(LFSTriple*)profileRemote;
-(LFSTriple*)contentRemote;

// primitives
-(NSString*)contentBodyHtml;
-(NSString*)contentDetail;

// actions
- (void)didSelectLike:(id)sender;
- (void)didSelectReply:(id)sender;

@end

// group related info together in this lightweight
// "triple" object
@interface LFSTriple : NSObject

@property (strong, nonatomic) UIImage *iconImage;
@property (strong, nonatomic) NSString *detailString;
@property (strong, nonatomic) NSString *mainString;

-(id)initWithDetailString:(NSString*)urlString
               mainString:(NSString*)displayString
                iconImage:(UIImage*)iconImage;
@end


// group related info together in this lightweight
// "triple" object
@interface LFSHeader : NSObject

@property (strong, nonatomic) UIImage *iconImage;
@property (strong, nonatomic) NSString *attributeString;
@property (strong, nonatomic) NSString *mainString;
@property (strong, nonatomic) NSString *detailString;

-(id)initWithDetailString:(NSString*)detailString
          attributeString:(NSString*)attributeString
               mainString:(NSString*)mainString
                iconImage:(UIImage*)iconImage;
@end