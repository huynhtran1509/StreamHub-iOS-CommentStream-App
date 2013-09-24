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
@synthesize profileUrlString = _profileUrlString;
@synthesize avatarUrlString = _avatarUrlString;
@synthesize avatarUrlString75 = _avatarUrlString75;
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


-(NSString*)profileUrlString
{
    const static NSString* const key = @"profileUrl";
    if (_profileUrlString == nil) {
        _profileUrlString = [_object objectForKey:key];
    }
    return _profileUrlString;
}

-(NSString*)avatarUrlString
{
    const static NSString* const key = @"avatar";
    if (_avatarUrlString == nil) {
        _avatarUrlString = [_object objectForKey:key];
    }
    return _avatarUrlString;
}

-(NSString*)avatarUrlString75
{
    // create 75px avatar url
    static NSRegularExpression *regex1 = nil;
    static NSRegularExpression *regex2 = nil;
    static NSString* const regexTemplate1 = @"$1s=75$2";
    static NSString* const regexTemplate2 = @"/75.$1";
    if (_avatarUrlString75 == nil)
    {
        // We will handle two types of avatar URLs:
        // http://gravatar.com/avatar/c228ecbc43be06cc999c08cf020f9fde/?s=50&d=http://avatars-staging.fyre.co/a/anon/50.jpg
        // http://avatars.fyre.co/a/26/6dbce19ef7452f69164e857d55d173ae/50.jpg?v=1375324889"
        //
        if (regex1 == nil) {
            NSError *regexError1 = nil;
            regex1 = [NSRegularExpression
                      regularExpressionWithPattern:@"([?&])s=50(&?)"
                      options:NSRegularExpressionCaseInsensitive
                      error:&regexError1];
            NSAssert(regexError1 == nil,
                     @"Error creating regex: %@",
                     regexError1.localizedDescription);
        }
        
        if (regex2 == nil) {
            NSError *regexError2 = nil;
            regex2 = [NSRegularExpression
                      regularExpressionWithPattern:@"/50.([a-zA-Z]+)\\b"
                      options:NSRegularExpressionCaseInsensitive
                      error:&regexError2];
            NSAssert(regexError2 == nil,
                     @"Error creating regex: %@",
                     regexError2.localizedDescription);
        }
        
        NSString *avatarUrlString1 = [regex1 stringByReplacingMatchesInString:self.avatarUrlString
                                                                      options:0
                                                                        range:NSMakeRange(0, [self.avatarUrlString length])
                                                                 withTemplate:regexTemplate1];
        _avatarUrlString75 = [regex2 stringByReplacingMatchesInString:avatarUrlString1
                                                              options:0
                                                                range:NSMakeRange(0, [avatarUrlString1 length])
                                                         withTemplate:regexTemplate2];
    }
    return _avatarUrlString75;
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

-(NSString*)twitterHandle
{
    static NSString* const twitterHost = @"twitter.com";
    NSURL *url = [NSURL URLWithString:self.profileUrlString];
    if ([[url host] isEqualToString:twitterHost]) {
        NSString *handle = [[url pathComponents] lastObject];
        return handle;
    } else {
        return nil;
    }
}

#pragma mark - Lifecycle
-(id)initWithObject:(id)object
{
    self = [super init];
    if (self ) {
        // initialization stuff here
        _object = object;
        _displayName = nil;
        _profileUrlString = nil;
        _avatarUrlString = nil;
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
    _profileUrlString = nil;
    _avatarUrlString = nil;
    _userTags = nil;
    _userType = nil;
    _userId = nil;
    _twitterHandle = nil;
    _object = nil;
}


@end
