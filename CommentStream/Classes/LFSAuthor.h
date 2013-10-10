//
//  LFSAuthor.h
//  CommentStream
//
//  Created by Eugene Scherba on 9/23/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LFSAuthor : NSObject

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

@property (nonatomic, strong) id object;

@property (nonatomic, strong) UIImage *avatarImage;

// Note: use lazy instantiation here
@property (nonatomic, copy) NSString *displayName;
@property (nonatomic, copy) NSString *profileUrlString;
@property (nonatomic, copy) NSString *avatarUrlString;
@property (nonatomic, copy) NSString *avatarUrlString75;
@property (nonatomic, copy) NSString *idString;
@property (nonatomic, copy) NSString *twitterHandle;
@property (nonatomic, copy) NSString *profileUrlStringNoHashBang;

@property (nonatomic, copy) NSArray *userTags;

@property (nonatomic, strong) NSNumber *userType;

@end
