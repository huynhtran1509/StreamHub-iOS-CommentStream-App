//
//  LFSStreamClient.m
//  LFSClient
//
//  Created by Eugene Scherba on 9/3/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import "LFSStreamClient.h"

// Various constants to help with parsing JSON files
static const NSString *const kLFSMaxEventId = @"maxEventId";

@interface LFSStreamClient ()

@property (nonatomic, strong) LFSSuccessBlock successBlock;
@property (nonatomic, strong) LFSFailureBlock failureBlock;
@property (nonatomic, strong) LFHandleBlock resultHandler;

@end

@implementation LFSStreamClient

@synthesize successBlock = _successBlock;
@synthesize failureBlock = _failureBlock;
@synthesize resultHandler = _resultHandler;
@synthesize eventId = _eventId;

#pragma mark - Overrides
// TODO: implement ring with consistent hashing for managing streams
-(NSString*)subdomain { return @"stream1"; }

- (id)initWithEnvironment:(NSString *)environment
                  network:(NSString *)network
{
    self = [super initWithNetwork:network environment:environment];
    if (self) {
        _collectionId = nil;
        _collectionStreamURL = nil;
        _successBlock = nil;
        _failureBlock = nil;
        _resultHandler = nil;
        _eventId = nil;
    }
    return self;
}

#pragma mark - Properties

@synthesize collectionId = _collectionId;
- (void)setCollectionId:(NSString *)collectionId
{
    _collectionId = collectionId;
    _collectionStreamURL = nil;
}

#pragma mark -
@synthesize collectionStreamURL = _collectionStreamURL;
- (NSURL*)collectionStreamURL
{
    if (_collectionStreamURL == nil)
    {
        NSString *component = [NSString stringWithFormat:@"v3.0/collection/%@", self.collectionId];
        _collectionStreamURL = [self.reqOpManager.baseURL URLByAppendingPathComponent:component];
        
    }
    return _collectionStreamURL;
}

#pragma mark - Public methods
- (void)setResultHandler:(LFHandleBlock)handler
                 success:(LFSSuccessBlock)success
                 failure:(LFSFailureBlock)failure
{
    self.resultHandler = handler;
    self.successBlock = success;
    self.failureBlock = failure;
}

- (void)stopStream
{
    [self.reqOpManager.operationQueue cancelAllOperations];
}

- (void)pauseStream
{
    [self.reqOpManager.operationQueue setSuspended:YES];
}

-(void)resumeStream
{
    [self.reqOpManager.operationQueue setSuspended:NO];
    [self startStreamWithEventId:nil];
}

- (void)startStream
{
    [self startStreamWithEventId:nil];
}

- (void)startStreamWithEventId:(NSNumber*)eventId
{
    if ([self.reqOpManager.operationQueue isSuspended]) {
        return;
    }
    
    AFHTTPRequestOperation *op =
    (AFHTTPRequestOperation *)[self.reqOpManager HTTPRequestOperationWithRequest:
                                [self buildRequestWithEventId:eventId]
                                                             success:
                                ^(AFHTTPRequestOperation *operation, id responseObject)
                                {
                                    
                                    if (self.successBlock) {
                                        self.successBlock(operation, responseObject);
                                    } else {
                                        // if success block is not provided, manually reschedule
                                        // polling
                                        NSDictionary *json = (NSDictionary*)responseObject;
                                        // received data
                                        if (self.resultHandler) {
                                            self.resultHandler(responseObject);
                                        }
                                        NSNumber *maxEventId = [json objectForKey:kLFSMaxEventId];
                                        // issue another request
                                        [self startStreamWithEventId:maxEventId];
                                    }
                                }
                                                             failure:
                                ^(AFHTTPRequestOperation *operation, NSError *error)
                                {
                                    
                                    if (self.failureBlock) {
                                        // developer can choose to restart
                                        // by providing a custom failure block
                                        self.failureBlock(operation, error);
                                    } else if (error.domain == NSURLErrorDomain &&
                                               error.code == NSURLErrorTimedOut) {
                                        // time out
                                        [self performSelector:@selector(startStreamWithEventId:)
                                                   withObject:eventId
                                                   afterDelay:2.0];
                                    }
                                }];
    op.responseSerializer = self.responseSerializer;
    [self.reqOpManager.operationQueue addOperation:op];
}

#pragma mark - Private methods

- (NSMutableURLRequest*)buildRequestWithEventId:(NSNumber*)eventId
{
    if (eventId == nil) {
        // try using cached event id if nil
        eventId = self.eventId;
    } else {
        // cache current value
        self.eventId = eventId;
    }
    NSAssert(eventId != nil, @"eventId cannot be nil");
    NSURL *streamURL = [self.collectionStreamURL URLByAppendingPathComponent:[eventId stringValue]];
    
    AFHTTPRequestSerializer* requestSerializer =
    [self.requestSerializers objectForKey:[NSNumber numberWithInteger:AFFormURLParameterEncoding]];
    
    NSMutableURLRequest *request = [requestSerializer
                                    requestWithMethod:@"GET"
                                    URLString:[streamURL absoluteString]
                                    parameters:nil
                                    error:nil];
    [request setTimeoutInterval:50.0];
    return request;
}


@end
