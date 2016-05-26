//
//  LFSStreamClient.h
//  LFSClient
//
//  Created by Eugene Scherba on 9/3/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import "LFSBaseClient.h"

@interface LFSStreamClient : LFSBaseClient

/** @name Streaming Interface */

/**
 @abstract Current streaming URL
 */
@property (nonatomic, readonly) NSURL *collectionStreamURL;

/**
 @abstract current collection Id
 */
@property (nonatomic, strong) NSString *collectionId;

/**
 @abstract last seen event id
 */
@property (nonatomic, strong) NSNumber *eventId;

/*!
 @abstract Set result, success, and failure handlers
 @discussion Set result, success, and failure handlers
 @param handler   Callback to handle response data
 @param success   Success callback (if provided, invalidates handler)
 @param failure   Failure callback
 */

- (void)setResultHandler:(LFHandleBlock)handler
                 success:(LFSSuccessBlock)success
                 failure:(LFSFailureBlock)failure;

/*!
 @abstract Start stream reusing the stored event Id
 */

- (void)startStream;

/*!
 @abstract Start stream with event Id
 @param eventId event Id (only events with event Ids larger than the given one
        will be streamed)
 */

- (void)startStreamWithEventId:(NSNumber*)eventId;

/*!
 @abstract Pause streaming
 */

- (void)pauseStream;

/*!
 @abstract Resume streaming
 */

- (void)resumeStream;

/*!
 @abstract stop streaming
 */
- (void)stopStream;


@end
