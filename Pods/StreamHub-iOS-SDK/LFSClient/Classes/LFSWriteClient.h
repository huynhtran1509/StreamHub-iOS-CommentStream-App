//
//  LFSWriteClient.h
//  LFSClient
//
//  Created by Eugene Scherba on 8/22/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import "LFSBaseClient.h"

@interface LFSWriteClient : LFSBaseClient

/** @name Content Interaction */

/*!
@abstract Like (or unlike) a comment in a collection.
@discussion Like (or unlike) a comment in a collection. The comment must be in a collection the user is authenticated for and it must have been posted by a different user. Trying to like things other than comments may have odd results.
 @param action       One of the following: LFSOpineLike, LFSOpineUnlike
 @param userToken    JWT-encoded user token
 @param contentId    id of content which is being liked/unliked
 @param collectionId The collection in which the content appears.
 @param parameters   (Optional) A dictionary containing the following parameters:
 
         `@"notes"`   (optional) Any additional comment the user provided.
 
         `@"email"`   (optional) The email of the user.
 
 @param success      Success callback
 @param failure      Failure callback
*/
-(void)postMessage:(LFSMessageAction)action
        forContent:(NSString*)contentId
      inCollection:(NSString*)collectionId
         userToken:(NSString*)userToken
        parameters:(NSDictionary*)parameters
         onSuccess:(LFSSuccessBlock)success
         onFailure:(LFSFailureBlock)failure;

/*!
 @abstract Flag a user (either ban or whitelist or undo)
 @discussion Send a command to flag a user. The following actions can be performed
             with this method: banning/unbanning a user, and white-/unwhitelisting a user.
 @param action       A LFSAuthorAction type
 @param sites        (optional) a site (string) or a list of sites (array)
 @param retroactive  (Boolean) A value that indicates whether to apply unban to previously posted content
 @param userToken    JWT-encoded user token
 @param success      Success callback
 @param failure      Failure callback
 */
- (void)flagAuthor:(NSString *)userId
            action:(LFSAuthorAction)userAction
          forSites:(id)sites
       retroactive:(BOOL)retroactive
         userToken:(NSString*)userToken
         onSuccess:(LFSSuccessBlock)success
         onFailure:(LFSFailureBlock)failure;

/*!
 @abstract Feature (or unfeature) a comment in a collection.
 @discussion Feature (or unfeature) a comment in a collection. The comment must be in a collection the user is authenticated for, and he user must have moderator-level permissions. Trying to feature things other than comments may have odd results.
 @param feature       One of the following: YES, NO
 @param messageId    id of content which is being featured/unfeatured
 @param collectionId The collection in which the content appears.
 @param userToken    JWT-encoded user token
 @param success      Success callback
 @param failure      Failure callback
 */
- (void)feature:(BOOL)feature
        comment:(NSString*)messageId
   inCollection:(NSString*)collectionId
      userToken:(NSString*)userToken
      onSuccess:(LFSSuccessBlock)success
      onFailure:(LFSFailureBlock)failure;

/*!
 @abstract Flag content with one of the flag types.
 @discussion Flag content with one of the flag types.
 @param flag         Either one of the following: `LFSFlagSpam | LFSFlagOffensive | LFSFlagDisagree | LFSFlagOfftopic`
 @param userToken    JWT-encoded user token
 @param contentId    The is of the content to flag.
 @param collectionId The Id of the collection where the content appears.
 @param parameters   A dictionary containing the following parameters:

        `@"notes"`   (optional) Any additional comment the user provided.

        `@"email"`   (optional) The email of the user.

 @param success      Success callback
 @param failure      Failure callback
 */
- (void)postFlag:(LFSContentFlag)flag
      forContent:(NSString*)contentId
    inCollection:(NSString*)collectionId
       userToken:(NSString*)userToken
      parameters:(NSDictionary*)parameters
       onSuccess:(LFSSuccessBlock)success
       onFailure:(LFSFailureBlock)failure;

/*!
 @abstract Convenience method to create a new comment in a collection.
 @discussion Convenience method to create a new comment in a collection. 
   Creating new posts requires that the user has permission to post in the collection.
 @param body HTML body of the new post.
 @param userToken JWT-encoded user token
 @param collectionId Collection to add the post to.
 @param parentId (optional) The post that this is a response to, if applicable.
 @param success Success callback
 @param failure Failure callback
 */
- (void)postContent:(NSString*)body
       inCollection:(NSString*)collectionId
          userToken:(NSString*)userToken
          inReplyTo:(NSString*)parentId
          onSuccess:(LFSSuccessBlock)success
          onFailure:(LFSFailureBlock)failure;

/*!
 @abstract Convenience method to create a new comment in a collection.
 @discussion Convenience method to create a new comment in a collection.
 Creating new posts requires that the user has permission to post in the collection.
 @param attachments array of attachments
 @param body HTML body of the new post.
 @param userToken JWT-encoded user token
 @param collectionId Collection to add the post to.
 @param parentId (optional) The post that this is a response to, if applicable.
 @param success Success callback
 @param failure Failure callback
 */
- (void)postContent:(NSString *)body
    withAttachments:(NSArray  *)attachments
       inCollection:(NSString *)collectionId
          userToken:(NSString *)userToken
          inReplyTo:(NSString *)parentId
          onSuccess:(LFSSuccessBlock)success
          onFailure:(LFSFailureBlock)failure;

/*!
 @abstract Post new content (comments, reviews, tweets, etc) to a collection
 @discussion Post new content (comments, reviews, tweets, etc) to a collection.
  Creating new posts requires that the user has permission to post in the collection.
 @param postType  One of the following:
 @param collectionId Collection to add the post to.
 @param parameters  A dictionary containing the following:
 
         `LFSCollectionPostBodyKey`        (required) HTML body
 
         `LFSCollectionPostUserTokenKey`   (required) user token
 
         `LFSCollectionPostTitleKey`       (required for LiveReviews only)
 
         `LFSCollectionPostRatingKey`      (required for LiveReviews only)
 
         `FSCollectionPostParentIdKey`     parent content id (for threaded content)
 
         `LFSCollectionPostMIMETypeKey`    MIME type
 
         `LFSCollectionPostShareTypesKey`  share types
 
         `LFSCollectionPostAttachmentsKey` attachment
 
         `LFSCollectionPostMediaKey`       media
 
 @param success Success callback
 @param failure Failure callback
 */
- (void)postContentType:(LFSPostType)postType
          forCollection:(NSString*)collectionId
             parameters:(NSDictionary*)parameters
              onSuccess:(LFSSuccessBlock)success
              onFailure:(LFSFailureBlock)failure;

/*!
 @abstract Create a collection on the given site.
 @discussion Create a collection on the given site.
  Note: to create an unsigned collection, pass nil as the siteKey parameter
 @param siteId    site Id
 @param siteKey   (optional) Site Key to sign JWT token with
                  If nil, so-called "unsigned collection creation" will take place
 @param collectionMeta   A dictionary containing the following parameters:
 
         `LFSCollectionMetaArticleIdKey` (required) A string (<=255 characters) representing user-assigned article id
 
         `LFSCollectionMetaURLKey`       (required) A string representing user-assigned URL article URL. Note: a pair consisting of siteId and articleId correponds to a collection entity.
 
         `LFSCollectionMetaTitleKey`     (required for signed collections) A string (<=255 characters) representing article title
 
         `LFSCollectionMetaTagsKey`      (optional) An array of user-assigned tags
 
         `LFSCollectionMetaTypeKey` (optional) A type of stream to be created. One of the following: `LFSStreamTypeThreaded | LFSStreamTypeLiveComments | LFSStreamTypeLiveChat | LFSStreamTypeLiveBlog | LFSStreamTypeReviews | LFSStreamTypeLiveReviews | LFSStreamTypeRatings | LFSStreamTypeStory | LFSStreamTypeCounting`
 
 @param success   Success callback
 @param failure   Failure callback
 */
-(void)postArticleForSite:(NSString*)siteId
              withSiteKey:(NSString*)siteKey
           collectionMeta:(NSDictionary*)collectionMeta
                onSuccess:(LFSSuccessBlock)success
                onFailure:(LFSFailureBlock)failure;

@end
