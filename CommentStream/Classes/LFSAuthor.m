//
//  LFSAuthor.m
//  CommentStream
//
//  Created by Eugene Scherba on 9/23/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import "LFSAuthor.h"

@implementation LFSAuthor {
    id _object;
}

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

@synthesize displayName = _displayName;
@synthesize profileUrl = _profileUrl;
@synthesize avatarUrl = _avatarUrl;
@synthesize userTags = _userTags;
@synthesize userType = _userType;
@synthesize userId = _userId;
@synthesize twitterHandle = _twitterHandle;


-(NSString*)displayName
{
    const static NSString* const key = @"displayName";
    if (_displayName == nil) {
        _displayName = [_object objectForKey:key];
    }
    return _displayName;
}

-(NSString*)userId
{
    const static NSString* const key = @"id";
    if (_userId == nil) {
        _userId = [_object objectForKey:key];
    }
    return _userId;
}


-(NSString*)profileUrl
{
    const static NSString* const key = @"profileUrl";
    if (_profileUrl == nil) {
        _profileUrl = [_object objectForKey:key];
    }
    return _profileUrl;
}


-(NSString*)avatarUrl
{
    const static NSString* const key = @"avatar";
    if (_avatarUrl == nil) {
        _avatarUrl = [_object objectForKey:key];
    }
    return _avatarUrl;
}


-(NSNumber*)userType
{
    const static NSString* const key = @"type";
    if (_userType == nil) {
        _userType = [_object objectForKey:key];
    }
    return _userType;
}

-(NSArray*)userTags
{
    const static NSString* const key = @"tags";
    if (_userTags == nil) {
        _userTags = [_object objectForKey:key];
    }
    return _userTags;
}


#pragma mark - Lifecycle
-(id)initWithObject:(id)object
{
    self = [super init];
    if (self ) {
        // initialization stuff here
        _object = object;
        _displayName = nil;
        _profileUrl = nil;
        _avatarUrl = nil;
        _userTags = nil;
        _userType = nil;
        _userId = nil;
        _twitterHandle = nil;
    }
    return self;
}

-(void)dealloc
{
    _displayName = nil;
    _profileUrl = nil;
    _avatarUrl = nil;
    _userTags = nil;
    _userType = nil;
    _userId = nil;
    _twitterHandle = nil;
    _object = nil;
}


@end
