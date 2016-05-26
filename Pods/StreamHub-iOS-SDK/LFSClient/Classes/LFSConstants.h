//
//  LFSConstants.h
//  LivefyreClient
//
//  Created by zjj on 1/9/13.
//
//  Copyright (c) 2013 Livefyre
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.

#ifndef LFSClient_types_h
#define LFSClient_types_h

#import <AFNetworking/AFHTTPRequestOperation.h>

typedef void (^LFSSuccessBlock) (NSOperation *operation, id responseObject);
typedef void (^LFSFailureBlock) (NSOperation *operation, NSError *error);
typedef void (^LFHandleBlock) (id responseObject);
typedef void (^AFSuccessBlock) (AFHTTPRequestOperation *operation, id responseObject);
typedef void (^AFFailureBlock) (AFHTTPRequestOperation *operation, NSError *error);

#define LFS_SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define LFS_SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define LFS_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define LFS_SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define LFS_SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#endif

// {{{
// https://github.com/Livefyre/lfdj/blob/production/lfwrite/lfwrite/api/v3_0/urls.py#L75
#define LFS_OPINE_ENDPOINTS_LENGTH 14u
extern const NSString *const LFSMessageEndpoints[LFS_OPINE_ENDPOINTS_LENGTH];
/**
@since Available since 0.2.0 and later
*/
typedef NS_ENUM(NSUInteger, LFSMessageAction) {
    /*! Edit content endpoint */
    LFSMessageEdit = 0u,    // 0
    /*! Approve content */
    LFSMessageApprove,      // 1
    /*! Unapprove content */
    LFSMessageUnapprove,    // 2
    /*! Hide content */
    LFSMessageHide,         // 3
    /*! Delete content */
    LFSMessageDelete,       // 4
    /*! Delete content */
    LFSMessageBozo,         // 5
    /*! Bozo content (bozo-ed comments are visible only to their respective authors) */
    LFSMessageIgnoreFlags,  // 6
    /*! Ignore content flags */
    LFSMessageAddNote,      // 7
    /*! Attach additional information to content */
    LFSMessageLike,         // 8
    /*! Unlike content */
    LFSMessageUnlike,       // 9
    /*! Flag content */
    LFSMessageFlag,         // 10
    /*! Mention content */
    LFSMessageMention,      // 11
    /*! Share content on an outside network */
    LFSMessageShare,        // 12
    /*! Vote on LiveReview */
    LFSMessageVote          // 13
};
// }}}

// {{{
// https://github.com/Livefyre/lfdj/blob/production/lfwrite/lfwrite/api/v3_0/urls.py#L87
#define LFS_CONTENT_FLAGS_LENGTH 4u
extern const NSString *const LFSContentFlags[LFS_CONTENT_FLAGS_LENGTH];
/**
 @since Available since 0.2.0 and later
 */
typedef NS_ENUM(NSUInteger, LFSContentFlag) {
    /*! Unsolicited advertising (flagging will delete content when performed by moderator) */
    LFSFlagSpam = 0u,           // 0
    /*! Offensive language */
    LFSFlagOffensive,           // 1
    /*! Mark disagreement  */
    LFSFlagDisagree,            // 2
    /*! Comment is offtopic */
    LFSFlagOfftopic             // 3
};
// }}}

// {{{ types of content that can be posted
// https://github.com/Livefyre/lfdj/blob/production/lfwrite/lfwrite/api/v3_0/urls.py#L68
#define LFS_POST_TYPE_LENGTH 4u
extern const NSString *const LFSPostTypes[LFS_POST_TYPE_LENGTH];
/**
 @since Available since 0.2.0 and later
 */
typedef NS_ENUM(NSUInteger, LFSPostType) {
    /*! Post a comment (default) */
    LFSPostTypeDefault = 0u,    // 0
    /*! Post a tweet */
    LFSPostTypeTweet,           // 1
    /*! Post a live review (collection must be a LiveReview collection) */
    LFSPostTypeReview,          // 2
    /*! Post a rating (colleciton must be a Ratings collection) */
    LFSPostTypeRating,          // 3
};
// }}}


// {{{ types of content that can be posted
// https://github.com/Livefyre/lfdj/blob/production/lfwrite/lfwrite/api/v3_0/urls.py#L68
#define LFS_USER_ACTIONS_LENGTH 4u
extern const NSString *const LFSAuthorActions[LFS_POST_TYPE_LENGTH];
/**
 @since Available since 0.3.5 and later
 */
typedef NS_ENUM(NSUInteger, LFSAuthorAction) {
    /*! ban user (bozoes all content) */
    LFSAuthorActionBan = 0u,     // 0
    /*! unban user */
    LFSAuthorActionUnban,        // 1
    /*! add user to a whitelist */
    LFSAuthorActionWhitelist,    // 2
    /*! remvoe user from whitelist */
    LFSAuthorActionUnwhitelist,  // 3
};
// }}}


// https://github.com/Livefyre/lfdj/blob/production/lfcore/lfcore/v2/publishing/models.proto#L74
/**
 @since Available since 0.2.0 and later
 */
typedef NS_ENUM(NSUInteger, LFSContentType) {
    /*! A message posted by a user in reply to an article or another comment */
    LFSContentTypeMessage = 0u, // 0
    /*! An opinion from a user indicating that they like a comment or an embed */
    LFSContentTypeOpine,        // 1
    /*! Share type */
    LFSContentTypeShare,        // 2
    /*! An embedded image which is part of a comment */
    LFSContentTypeOEmbed,       // 3
    /*! A primitive structure which the engine treats as an opaque object. */
    LFSContentTypeStruct        // 4
};

// https://github.com/Livefyre/lfdj/blob/production/lfcore/lfcore/v2/fulfillment/bootstrap/models.proto#L106
/**
 @since Available since 0.2.0 and later
 */
typedef NS_ENUM(NSUInteger, LFSContentVisibility) {
    /*! content is visible to no one, usually due to being deleted */
    LFSContentVisibilityNone = 0u,                      // 0
    /*! content is visible to everyone */
    LFSContentVisibilityEveryone,                       // 1
    /*! content is visible to only the author due to bozoing */
    LFSContentVisibilityOwner,                          // 2
    /*! content is visible to the author and any moderators for the collection, usually meaning that it's waiting for approval */
    LFSContentVisibilityGroup,                          // 3
    /*! SDK-only addition to facilitate certain app features */
    LFSContentVisibilityPendingDelete = NSUIntegerMax   // 4
};

// https://github.com/Livefyre/lfdj/blob/production/lfcore/lfcore/v2/publishing/models.proto#L179
/**
 @since Available since 0.1.0 and later
 */
typedef NS_ENUM(NSUInteger, LFSPermission) {
    /*! no access */
    LFSPermissionNone = 0u,     // 0
    /*! whitelisted  */
    LFSPermissionWhitelist,     // 1
    /*! blacklisted  */
    LFSPermissionBlacklist,     // 2
    /*! gray-listed */
    LFSPermissionGraylist,      // 3
    /*! user is a moderator */
    LFSPermissionModerator      // 4
};

// https://github.com/Livefyre/lfdj/blob/production/lfcore/lfcore/v2/util/models.proto#L21
/**
 @since Available since 0.1.0 and later
 */
typedef NS_ENUM(NSUInteger, LFSPermissionScope) {
    /*! global permission scope */
    LFSPermissionScopeGlobal = 0u,     // 0
    /*! network permission scope */
    LFSPermissionScopeNetwork,         // 1
    /*! site permission scope */
    LFSPermissionScopeSite,            // 2
    /*! collection permission scope */
    LFSPermissionScopeCollection,      // 3
    /*! collection rule scope */
    LFSPermissionScopeCollectionRule   // 4
};


// For detailed info, see
// https://github.com/Livefyre/lfdj/blob/production/lfcore/lfcore/v2/publishing/models.proto
typedef NS_ENUM(NSUInteger, LFSContentSourceClass) {
    LFSContentSourceDefault = 0u,   // 0
    LFSContentSourceTwitter,        // 1
    LFSContentSourceFacebook,       // 2
    LFSContentSourceGooglePlus,     // 3
    LFSContentSourceFlickr,         // 4
    LFSContentSourceYouTube,        // 5
    LFSContentSourceRSS,            // 6
    LFSContentSourceInstagram       // 7
};

#define CONTENT_SOURCE_DECODE_LENGTH 20u
extern const LFSContentSourceClass LFSContentSourceClasses[CONTENT_SOURCE_DECODE_LENGTH];

@interface LFSConstants : NSObject

extern NSString* const LFSSystemVersion70;

extern NSString *const LFSScheme;
extern NSString *const LFSErrorDomain;

// Various constants to help with parsing JSON files
extern NSString *const LFSCollectionSettings;
extern NSString *const LFSHeadDocument;
extern NSString *const LFSNetworkSettings;
extern NSString *const LFSSiteSettings;

// {{{ Collection stream types
// https://github.com/Livefyre/lfdj/blob/production/lfcore/lfcore/v2/network/steps.py#L538

extern NSString *const LFSStreamTypeThreaded;
extern NSString *const LFSStreamTypeLiveComments;
extern NSString *const LFSStreamTypeLiveChat;
extern NSString *const LFSStreamTypeLiveBlog;
extern NSString *const LFSStreamTypeReviews;
extern NSString *const LFSStreamTypeLiveReviews;
extern NSString *const LFSStreamTypeRatings;
extern NSString *const LFSStreamTypeStory;
extern NSString *const LFSStreamTypeCounting;
// }}}


// {{{ Collection meta keys
// https://github.com/Livefyre/lfdj/blob/production/lfcore/lfcore/v2/network/steps.py#L478
extern NSString *const LFSCollectionMetaArticleIdKey;
extern NSString *const LFSCollectionMetaURLKey;
extern NSString *const LFSCollectionMetaTitleKey;
extern NSString *const LFSCollectionMetaTagsKey;
extern NSString *const LFSCollectionMetaTypeKey;
// }}}

// {{{ Comment and Review content post requests
// https://github.com/Livefyre/lfdj/blob/production/lfwrite/lfwrite/api/v3_0/col/post.py
extern NSString *const LFSCollectionPostBodyKey;
extern NSString *const LFSCollectionPostTitleKey;
extern NSString *const LFSCollectionPostRatingKey;
extern NSString *const LFSCollectionPostParentIdKey;
extern NSString *const LFSCollectionPostMIMETypeKey;
extern NSString *const LFSCollectionPostShareTypesKey;
extern NSString *const LFSCollectionPostAttachmentsKey;
extern NSString *const LFSCollectionPostMediaKey;
extern NSString *const LFSCollectionPostUserTokenKey;
extern NSString *const LFSCollectionPostCollectionIdKey;

extern NSString *const LFSPostNetworkKey;
extern NSString *const LFSPostSitesKey;
extern NSString *const LFSPostRetroactiveKey;
// }}}

@end
