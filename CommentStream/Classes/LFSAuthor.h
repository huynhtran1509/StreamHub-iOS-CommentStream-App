//
//  LFSAuthor.h
//  CommentStream
//
//  Created by Eugene Scherba on 9/23/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LFSAuthor : NSMutableDictionary

/*
 * Sample JSON object:
 {
 displayName: "The Latest News",
 tags: [ ],
 profileUrl: "https://twitter.com/#!/all_latestnews",
 avatar: "http://a0.twimg.com/profile_images/3719913420/ecabbb041e3195e10ce87102c91b56aa_normal.jpeg",
 type: 3,
 id: "1463096012@twitter.com"
 }
 
 */
-(id)initWithObject:(id)object;

// Note: use lazy instantiation here
@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) NSString *profileUrlString;
@property (nonatomic, strong) NSString *avatarUrlString;
@property (nonatomic, strong) NSString *avatarUrlString75;
@property (nonatomic, strong) NSArray *userTags;
@property (nonatomic, strong) NSNumber *userType;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, readonly) NSString *twitterHandle;

@end