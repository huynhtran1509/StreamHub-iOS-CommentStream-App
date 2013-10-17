//
//  LFSUser.h
//  CommentStream
//
//  Created by Eugene Scherba on 10/16/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LFSAuthorProfile.h"

@interface LFSUser : NSObject

/*
{
    "auth_token" =     {
        ttl = 13034548;
        value = "<access token>";
    };
    isModAnywhere = 1;
    permissions =     {
        authors =         (
                           {
                               id = "commenter_0@labs.fyre.co";
                               key = 81b163f3d37446b1352d3c87b8660ae579ebedbb;
                           }
                           );
    };
    profile =     {
        avatar = "http://avatars.fyre.co/a/anon/50.jpg";
        displayName = "Commenter 0";
        id = "commenter_0@labs.fyre.co";
        profileUrl = "<null>";
        settingsUrl = "<null>";
    };
    token =     {
        ttl = 2592000;
        value = "<access token>";
    };
    version = "__VERSION__";
}
*/


-(id)initWithObject:(id)object;

@property (nonatomic, strong) id object;
@property (nonatomic, copy) NSString *idString;

@property (nonatomic, strong) NSDictionary *authToken;
@property (nonatomic, assign) BOOL isModAnywhere;
@property (nonatomic, strong) NSDictionary *permissions;
@property (nonatomic, strong) LFSAuthorProfile *profile;
@property (nonatomic, strong) NSDictionary *token;
@property (nonatomic, strong) NSString *version;

@end
