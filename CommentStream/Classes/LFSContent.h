//
//  LFSContent.h
//  CommentStream
//
//  Created by Eugene Scherba on 9/24/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <StreamHub-iOS-SDK/LFSConstants.h>

#import "LFSAuthorCollection.h"
#import "LFSContentCollection.h"

@class LFSContent;

typedef void (^LFSContentChildVisitor) (LFSContent *obj);

@interface LFSContent : NSObject

/* Sample content:
 {
 childContent: [ ],
 vis: 1,
 content: {
 parentId: "",
 bodyHtml: "Can anyone tell me what Vila Velha in Brazil is like? <a href="https://twitter.com/#!/search/realtime/%23WorldCup" class="fyre-hashtag" hashtag="WorldCup" rel="tag" target="_blank">#WorldCup</a> <a href="https://twitter.com/#!/search/realtime/%23carnival" class="fyre-hashtag" hashtag="carnival" rel="tag" target="_blank">#carnival</a>",
 annotations: { },
 authorId: "391303630@twitter.com",
 updatedAt: 1374902038,
 id: "tweet-360991428312186880@twitter.com",
 createdAt: 1374902038
 },
 source: 1,
 type: 0,
 event: 1374902038279948
 }
 */

-(id)initWithObject:(id)object;

@property (nonatomic, strong) id object;

// convenience properties
@property (nonatomic, readonly) BOOL authorIsModerator;

@property (nonatomic, readonly) UIImage *contentSourceIconSmall;
@property (nonatomic, readonly) UIImage *contentSourceIcon;
@property (nonatomic, readonly) NSString *contentTwitterId;
@property (nonatomic, readonly) NSString *contentTwitterUrlString;

@property (nonatomic, strong) LFSAuthor *author;
@property (nonatomic, strong) LFSContent *parent;

@property (nonatomic, strong) id childContent;
@property (nonatomic, assign) NSInteger nodeCount;
-(void)enumerateVisiblePathsUsingBlock:(LFSContentChildVisitor)block;

@property (nonatomic, copy) NSDictionary *content;
@property (nonatomic, copy) NSString *idString;
@property (nonatomic, copy) NSString *targetId;

@property (nonatomic, copy) NSString *contentParentId;
@property (nonatomic, copy) NSString *contentBodyHtml;
@property (nonatomic, copy) NSDictionary *contentAnnotations;
@property (nonatomic, copy) NSString *contentAuthorId;

@property (nonatomic, strong) NSDate *contentUpdatedAt;
@property (nonatomic, strong) NSDate *contentCreatedAt;
@property (nonatomic, strong) NSNumber *eventId;

@property (nonatomic, assign) LFSContentVisibility lastVis;
@property (nonatomic, assign) LFSContentVisibility visibility;
@property (nonatomic, assign) LFSContentType contentType;
@property (nonatomic, assign) NSUInteger contentSource;

@property (nonatomic, strong) NSMutableSet *likes;
@property (nonatomic, copy) NSMutableArray *datePath;

-(void)setAuthorWithCollection:(LFSAuthorCollection*)authorCollection;
-(NSComparisonResult)compare:(LFSContent*)content;

@end
