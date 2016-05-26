//
//  LFSBootstrapClient.h
//  
//
//  Created by Eugene Scherba on 8/20/13.
//
//

#import "LFSBaseClient.h"

@interface LFSBootstrapClient : LFSBaseClient

/*!
 @name Content Retrieval
 */

/**
* @abstract infoInit - Init response object (JSON)
* @see -getInitForSite:article:onSuccess:onFailure:
*/
@property (nonatomic, strong) NSDictionary *infoInit;


/*!
 @abstract Get the initial bootstrap data for a collection
 @discussion Get the initial bootstrap data for a collection. For more information see:
 https://github.com/Livefyre/livefyre-docs/wiki/StreamHub-API-Reference#wiki-init
 http://answers.livefyre.com/developers/api-reference/#collection-info-plus
 @param articleId The Id of the collection's article.
 @param siteId    The Id of the article's site.
 @param success   Success callback
 @param failure   Failure callback
 */
- (void)getInitForSite:(NSString *)siteId
               article:(NSString *)articleId
             onSuccess:(LFSSuccessBlock)success
             onFailure:(LFSFailureBlock)failure;

/*!
 @abstract Retrieves featured content for a collection
 @discussion Retrieves featured content for a collection. For more information see:
 http://answers.livefyre.com/developers/api-reference/#featured-content-head
 http://answers.livefyre.com/developers/api-reference/#featured-content-all
 @param articleId The Id of the collection's article.
 @param siteId    The Id of the article's site.
 @param headOnly  If true, will only grab featured comments in the top of a collection, 
                  if false will retrieve all of them
 @param success   Success callback
 @param failure   Failure callback
 */
- (void)getFeaturedForSite:(NSString *)siteId
                   article:(NSString *)articleId
                      head:(BOOL)headOnly
                 onSuccess:(LFSSuccessBlock)success
                 onFailure:(LFSFailureBlock)failure;

/*!
 @abstract Get content for page
 @discussion The init data for a collection contains information about that collection's number of pages and where to fetch the content for those pages.
 @param pageIndex The page to fetch content for. The pages are numbered from zero. If the page index provided is outside the bounds of what the init data knows about the error callback will convey that failure.
 @param success   Success callback
 @param failure   Failure callback
 */
- (void)getContentForPage:(NSInteger)pageIndex
                onSuccess:(LFSSuccessBlock)success
                onFailure:(LFSFailureBlock)failure;

/** @name User Information */

/*!
 @abstract Fetches the user's content history
 @discussion Fetches the user's content history. For more information see:
 https://github.com/Livefyre/livefyre-docs/wiki/User-Content-API
 @param userId The Id of the user whose content is to be fetched.
 @param userToken (optional) The lftoken of the user whose content is to be fetched. This parameter is required by default unless the network specifies otherwise.
 @param statuses (optional) array of comment states to return.
 @param offset (optional) Number of results to skip, defaults to 0. 25 items are returned at a time.
 @param success   Success callback
 @param failure   Failure callback
 */
- (void)getUserContentForUser:(NSString *)userId
                        token:(NSString *)userToken
                     statuses:(NSArray*)statuses
                       offset:(NSInteger)offset
                    onSuccess:(LFSSuccessBlock)success
                    onFailure:(LFSFailureBlock)failure;

/** @name Heat Index Trends */

/*!
 @abstract Polls for hottest Collections
 @discussion Polls for hottest Collections. For more information see:
 https://github.com/Livefyre/livefyre-docs/wiki/Heat-Index-API
 @param siteId (optional) Site ID to filter on.
 @param tag (optional) Tag to filter on.
 @param number (optional) Number of results to be returned. The default is 10 and the maximum is 100.
 @param success   Success callback
 @param failure   Failure callback
 */
- (void)getHottestCollectionsForSite:(NSString *)siteId
                                 tag:(NSString *)tag
                      desiredResults:(NSUInteger)number
                           onSuccess:(LFSSuccessBlock)success
                           onFailure:(LFSFailureBlock)failure;

@end
