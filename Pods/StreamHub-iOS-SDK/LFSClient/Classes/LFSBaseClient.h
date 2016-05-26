//
//  LFSBaseClient.h
//  LFSClient
//
//  Created by Eugene Scherba on 8/27/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import <AFNetworking/AFHTTPRequestOperationManager.h>
#import <LFJSONKit/JSONKit.h>
#import "LFSConstants.h"

/*!
 @since Available since 0.3.0 and later
 */
typedef NS_ENUM(NSUInteger, AFHTTPClientParameterEncoding) {
    /*! form parameter encoding */
    AFFormURLParameterEncoding,      // 0
    /*! JSON parameter encoding */
    AFJSONParameterEncoding,         // 1
    /*! Apple property-list parameter encoding */
    AFPropertyListParameterEncoding  // 2
};


@interface LFSBaseClient : NSObject

/*!
  @abstract Environment with which this class instance was initialized
 */
@property (nonatomic, readonly) NSString* lfEnvironment;

/*!
 @abstract Network with which this class instance was initialized
 */
@property (nonatomic, readonly) NSString* lfNetwork;

/*!
 @abstract abstract (to be overriden) subdomain of the baseURL
 */
@property (nonatomic, readonly) NSString *subdomain;

/*!
 @abstract Request operation manager
 */
@property (nonatomic, readonly) AFHTTPRequestOperationManager *reqOpManager;

/*!
 @abstract Request serializer
 */
@property (nonatomic, strong) NSDictionary *requestSerializers;

/*!
 @abstract Response serializer
 */
@property (nonatomic, strong) AFHTTPResponseSerializer *responseSerializer;

/*!
 @abstract Creates AFHTTPRequestSerializer-compatible serializer instance
 @discussion Creates AFHTTPRequestSerializer-compatible serializer instance
 @return Object conforming to AFURLRequestSerialization protocol
 @param encoding Which encoding to use for request parameters (form, JSON, or property-list)
 */

-(NSObject<AFURLRequestSerialization>*)requestSerializerWithEncoding:(AFHTTPClientParameterEncoding)encoding;

/*!
 @abstract Initialize Livefyre client
 @discussion Initialize Livefyre client
 @param network network as identified by domain, i.e. livefyre.com.
 @param environment (optional) Where collection(s) are hosted, i.e. t-402.
         Used for development/testing purposes.
 @return LFSClient instance
 @see -initWithNetwork:environment:
 */

+ (instancetype)clientWithNetwork:(NSString *)network
                      environment:(NSString *)environment;

/*!
 @abstract Initialize Livefyre client with client and network
 @discussion Initialize Livefyre client with client and network
 @param network network as identified by domain, i.e. livefyre.com.
 @param environment (optional) Where collection(s) are hosted, i.e. t-402.
         Used for development/testing purposes.
 @return LFSClient instance
 */
- (id)initWithNetwork:(NSString *)network
          environment:(NSString *)environment;


/*!
 @abstract Creates and returns Livefyre client with base URL
 @discussion Creates and returns Livefyre client with base URL
 @param baseURL The base URL
 @return LFSBaseClient instance
 */

+ (instancetype)clientWithBaseURL:(NSURL *)baseURL;

/*!
 @abstract Initialize Livefyre client with base URL
 @discussion Initialize Livefyre client with base URL
 @param baseURL The base URL
 @return LFSBaseClient instance
 */
- (id)initWithBaseURL:(NSURL *)baseURL;

/*!
 @abstract Creates an `LFSJSONRequestOperation` with a `POST` request, and enqueues it to the HTTP client's operation queue
 @discussion Creates an `LFSJSONRequestOperation` with a `POST` request, and enqueues it to the HTTP client's operation queue. Lets developer specify the particular parameter encoding to use.
 @param path relative path
 @param parameters The parameters to be encoded and set in the request HTTP body.
 @param parameterEncoding The `AFHTTPClientParameterEncoding` value corresponding to how parameters are encoded into a request body
 @param success A block object to be executed when the request operation finishes successfully. This block has no return value and takes two arguments: the created request operation and the object created from the response data of request.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (void)postPath:(NSString *)path
      parameters:(NSDictionary *)parameters
parameterEncoding:(AFHTTPClientParameterEncoding)parameterEncoding
         success:(AFSuccessBlock)success
         failure:(AFFailureBlock)failure;

/*!
 @abstract Creates an `LFSJSONRequestOperation` with a `POST` request, and enqueues it to the HTTP client's operation queue
 @discussion Creates an `LFSJSONRequestOperation` with a `POST` request, and enqueues it to the HTTP client's operation queue. Let developer specify the particular parameter encoding to use.
 @param url URL to be used as request URL
 @param parameters The parameters to be encoded and set in the request HTTP body.
 @param parameterEncoding The `AFHTTPClientParameterEncoding` value corresponding to how parameters are encoded into a request body
 @param success A block object to be executed when the request operation finishes successfully. This block has no return value and takes two arguments: the created request operation and the object created from the response data of request.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (void)postURL:(NSURL *)url
     parameters:(NSDictionary *)parameters
parameterEncoding:(AFHTTPClientParameterEncoding)parameterEncoding
        success:(AFSuccessBlock)success
        failure:(AFFailureBlock)failure;

/*!
 @abstract Creates an `LFSJSONRequestOperation` with a `GET` request, and enqueues it to the HTTP client's operation queue
 @discussion Creates an `LFSJSONRequestOperation` with a `GET` request, and enqueues it to the HTTP client's operation queue. Let developer specify the particular parameter encoding to use.
 @param path relative path
 @param parameters The parameters to be encoded and set in the request HTTP body.
 @param parameterEncoding The `AFHTTPClientParameterEncoding` value corresponding to how parameters are encoded into a request body
 @param success A block object to be executed when the request operation finishes successfully. This block has no return value and takes two arguments: the created request operation and the object created from the response data of request.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (void)getPath:(NSString *)path
     parameters:(NSDictionary *)parameters
parameterEncoding:(AFHTTPClientParameterEncoding)parameterEncoding
        success:(AFSuccessBlock)success
        failure:(AFFailureBlock)failure;


@end
