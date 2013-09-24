//
//  LFSContent.h
//  CommentStream
//
//  Created by Eugene Scherba on 9/24/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StreamHub-iOS-SDK/LFSConstants.h>

#import "LFSAuthorCollection.h"
#import "LFSContentCollection.h"

@class LFSContentCollection;

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

@property (nonatomic, readonly) NSString *contentTwitterId;
@property (nonatomic, readonly) NSString *contentTwitterUrlString;

@property (nonatomic, strong) NSDictionary *content;
@property (nonatomic, strong) LFSContentCollection *childContent;

@property (nonatomic, strong) NSNumber *eventId;
@property (nonatomic, assign) LFSContentVisibility visibility;
@property (nonatomic, assign) LFSContentType contentType;
@property (nonatomic, assign) NSUInteger contentSource;

@property (nonatomic, strong) NSString *contentParentId;
@property (nonatomic, strong) NSString *contentBodyHtml;
@property (nonatomic, strong) NSDictionary *contentAnnotations;
@property (nonatomic, strong) NSString *contentAuthorId;
@property (nonatomic, strong) NSDate *contentUpdatedAt;
@property (nonatomic, strong) NSDate *contentCreatedAt;
@property (nonatomic, strong) NSString *contentId;

@property (nonatomic, strong) LFSAuthor *author;

-(void)setAuthorWithCollection:(LFSAuthorCollection*)authorCollection;

@end
