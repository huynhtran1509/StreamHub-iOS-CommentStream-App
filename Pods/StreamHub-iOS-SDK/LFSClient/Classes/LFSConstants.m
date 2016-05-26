//
//  LFSConstants.m
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

#import "LFSConstants.h"

@implementation LFSConstants

NSString* const LFSSystemVersion70 = @"7.0";

NSString *const LFSScheme = @"http";
NSString *const LFSErrorDomain = @"LFSErrorDomain";

// Various constants to help with parsing JSON files
NSString *const LFSCollectionSettings = @"collectionSettings";
NSString *const LFSHeadDocument = @"headDocument";
NSString *const LFSNetworkSettings = @"networkSettings";
NSString *const LFSSiteSettings = @"siteSettings";

const LFSContentSourceClass LFSContentSourceClasses[CONTENT_SOURCE_DECODE_LENGTH] =
{
    LFSContentSourceDefault,    //  0
    LFSContentSourceTwitter,    //  1
    LFSContentSourceTwitter,    //  2
    LFSContentSourceFacebook,   //  3
    LFSContentSourceDefault,    //  4
    LFSContentSourceDefault,    //  5
    LFSContentSourceFacebook,   //  6
    LFSContentSourceTwitter,    //  7
    LFSContentSourceDefault,    //  8
    LFSContentSourceDefault,    //  9
    LFSContentSourceGooglePlus, // 10
    LFSContentSourceFlickr,     // 11
    LFSContentSourceYouTube,    // 12
    LFSContentSourceRSS,        // 13
    LFSContentSourceFacebook,   // 14
    LFSContentSourceTwitter,    // 15
    LFSContentSourceYouTube,    // 16
    LFSContentSourceDefault,    // 17
    LFSContentSourceDefault,    // 18
    LFSContentSourceInstagram,  // 19
};

// (for internal use):
// https://github.com/Livefyre/lfdj/blob/production/lfwrite/lfwrite/api/v3_0/urls.py#L75
const NSString* const LFSMessageEndpoints[LFS_OPINE_ENDPOINTS_LENGTH] =
{
    @"edit",            // 0
    @"approve",         // 1
    @"unapprove",       // 2
    @"hide",            // 3
    @"delete",          // 4
    @"bozo",            // 5
    @"ignore-flags",    // 6
    @"add-note",        // 7
    
    @"like",            // 8
    @"unlike",          // 9
    @"flag",            // 10
    @"mention",         // 11
    @"share",           // 12
    @"vote"             // 13
};

// (for internal use):
// https://github.com/Livefyre/lfdj/blob/production/lfwrite/lfwrite/api/v3_0/urls.py#L87
const NSString* const LFSContentFlags[LFS_CONTENT_FLAGS_LENGTH] =
{
    @"spam",            // 0
    @"offensive",       // 1
    @"disagree",        // 2
    @"off-topic"        // 3
};

// Actions that can be used on /user/ path
const NSString* const LFSAuthorActions[LFS_USER_ACTIONS_LENGTH] =
{
    @"ban",             // 0
    @"unban",           // 1
    @"whitelist",       // 2
    @"unwhitelist"      // 3
};


// {{{ types of content that can be posted
// https://github.com/Livefyre/lfdj/blob/production/lfwrite/lfwrite/api/v3_0/urls.py#L68
const NSString *const LFSPostTypes[LFS_POST_TYPE_LENGTH] =
{
    @"",                // 0
    @"tweet",           // 1
    @"review",          // 2
    @"rating"           // 3
};

// {{{ Collection stream types
// https://github.com/Livefyre/lfdj/blob/production/lfcore/lfcore/v2/network/steps.py#L538
NSString *const LFSStreamTypeThreaded = @"threaded";
NSString *const LFSStreamTypeLiveComments = @"livecomments";
NSString *const LFSStreamTypeLiveChat = @"livechat";
NSString *const LFSStreamTypeLiveBlog = @"liveblog";
NSString *const LFSStreamTypeReviews = @"reviews";
NSString *const LFSStreamTypeLiveReviews = @"livereviews";
NSString *const LFSStreamTypeRatings = @"ratings";
NSString *const LFSStreamTypeStory = @"story";
NSString *const LFSStreamTypeCounting = @"counting";
// }}}

// {{{ Collection meta keys
// https://github.com/Livefyre/lfdj/blob/production/lfcore/lfcore/v2/network/steps.py#L478
NSString *const LFSCollectionMetaArticleIdKey = @"articleId";
NSString *const LFSCollectionMetaURLKey = @"url";
NSString *const LFSCollectionMetaTitleKey = @"title";
NSString *const LFSCollectionMetaTagsKey = @"tags";
NSString *const LFSCollectionMetaTypeKey = @"type";
// }}}

// {{{ Comment and Review content post requests
// https://github.com/Livefyre/lfdj/blob/production/lfwrite/lfwrite/api/v3_0/col/post.py#L181
NSString *const LFSCollectionPostBodyKey = @"body";
NSString *const LFSCollectionPostTitleKey = @"title";
NSString *const LFSCollectionPostRatingKey = @"rating";
NSString *const LFSCollectionPostParentIdKey = @"parent_id";
NSString *const LFSCollectionPostMIMETypeKey = @"mimetype";
NSString *const LFSCollectionPostShareTypesKey= @"share_types";
NSString *const LFSCollectionPostAttachmentsKey = @"attachments";
NSString *const LFSCollectionPostMediaKey = @"media";
NSString *const LFSCollectionPostUserTokenKey = @"lftoken";
NSString *const LFSCollectionPostCollectionIdKey = @"collection_id";

NSString *const LFSPostNetworkKey = @"network";
NSString *const LFSPostSitesKey = @"sites";
NSString *const LFSPostRetroactiveKey = @"retroactive";

// }}}


@end
