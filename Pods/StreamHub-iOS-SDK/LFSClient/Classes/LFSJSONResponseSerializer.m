//
//  LFSJSONResponseSerializer.m
//  LFSClient
//
//  Created by Eugene Scherba on 4/6/14.
//  Copyright (c) 2014 Livefyre. All rights reserved.
//

#import "LFSJSONResponseSerializer.h"

static NSError* LFSErrorFromResponse(NSUInteger errorCode, id responseObject)
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    if (responseObject != nil) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSNumber *error_code = [responseObject objectForKey:@"code"];
            NSString *error_type = [responseObject objectForKey:@"error_type"];
            NSString *error_msg = [responseObject objectForKey:@"msg"];
            [dictionary setObject:[NSString stringWithFormat:@"Error %@: %@", error_code, error_type]
                           forKey:NSLocalizedDescriptionKey];
            [dictionary setObject:[NSString stringWithFormat:@"%@", error_msg]
                           forKey:NSLocalizedRecoverySuggestionErrorKey];
        } else {
            [dictionary setObject:[NSString stringWithFormat:@"Error %zd", errorCode]
                           forKey:NSLocalizedDescriptionKey];
            [dictionary setObject:[NSString stringWithFormat:@"%@", responseObject]
                           forKey:NSLocalizedRecoverySuggestionErrorKey];
        }
        [dictionary setObject:responseObject
                       forKey:NSUnderlyingErrorKey];
    }
    return [NSError errorWithDomain:NSURLErrorDomain
                               code:errorCode
                           userInfo:dictionary];
}

static NSError* LFSErrorFromObject(NSDictionary* object)
{
    NSInteger errorCode = [[object objectForKey:@"code"] integerValue];
    return LFSErrorFromResponse(errorCode, object);
}

static NSError* AFErrorWithUnderlyingError(NSError *error, NSError *underlyingError) {
    if (!error) {
        return underlyingError;
    }
    
    if (!underlyingError || error.userInfo[NSUnderlyingErrorKey]) {
        return error;
    }
    
    NSMutableDictionary *mutableUserInfo = [error.userInfo mutableCopy];
    mutableUserInfo[NSUnderlyingErrorKey] = underlyingError;
    
    return [[NSError alloc] initWithDomain:error.domain code:error.code userInfo:mutableUserInfo];
}

static BOOL AFErrorOrUnderlyingErrorHasCode(NSError *error, NSInteger code) {
    if (error.code == code) {
        return YES;
    } else if (error.userInfo[NSUnderlyingErrorKey]) {
        return AFErrorOrUnderlyingErrorHasCode(error.userInfo[NSUnderlyingErrorKey], code);
    }
    
    return NO;
}

@interface LFSJSONResponseSerializer ()

@property (nonatomic, strong) JSONDecoder* decoder;

@end


@implementation LFSJSONResponseSerializer

@synthesize readingOptions = _readingOptions;

+ (instancetype)serializer {
    return [self serializerWithReadingOptions:JKParseOptionTruncateNumbers];
}

+ (instancetype)serializerWithReadingOptions:(JKFlags)readingOptions
{
    return [(LFSJSONResponseSerializer*)[self alloc] initWithReadingOptions:readingOptions];
}

-(id)initWithReadingOptions:(JKFlags)jkflags {
    self = [super init];
    if (self) {
        self.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"application/javascript", @"application/x-javascript", @"text/json", @"text/javascript", @"text/x-javascript", nil];
        self.decoder = [JSONDecoder decoderWithParseOptions:jkflags];
        
        NSMutableSet* acceptableContentTypes = [self.acceptableContentTypes mutableCopy];
        
        self.acceptableContentTypes = acceptableContentTypes;
    }
    return self;
}

-(id)init {
    return [self initWithReadingOptions:JKParseOptionTruncateNumbers];
}

- (BOOL)validateResponse:(NSHTTPURLResponse *)response
                    data:(NSData *)data
                   error:(NSError * __autoreleasing *)error
{
    BOOL responseIsValid = YES;
    NSError *validationError = nil;
    
    if (response && [response isKindOfClass:[NSHTTPURLResponse class]]) {
        if (self.acceptableStatusCodes && ![self.acceptableStatusCodes containsIndex:(NSUInteger)response.statusCode])
        {
            NSDictionary *userInfo = @{
                                       NSLocalizedDescriptionKey: [NSString stringWithFormat:NSLocalizedStringFromTable(@"Request failed: %@ (%lu)", @"AFNetworking", nil), [NSHTTPURLResponse localizedStringForStatusCode:response.statusCode], (unsigned long)response.statusCode],
                                       NSURLErrorFailingURLErrorKey:[response URL],
                                       AFNetworkingOperationFailingURLResponseErrorKey: response
                                       };
            
            validationError = AFErrorWithUnderlyingError([NSError errorWithDomain:AFURLResponseSerializationErrorDomain code:NSURLErrorBadServerResponse userInfo:userInfo], validationError);
            
            responseIsValid = NO;
        }
        
        // only check content types if response is valid
        
        if (responseIsValid && self.acceptableContentTypes && ![self.acceptableContentTypes containsObject:[response MIMEType]])
        {
            if ([data length] > 0) {
                NSDictionary *userInfo = @{
                                           NSLocalizedDescriptionKey: [NSString stringWithFormat:NSLocalizedStringFromTable(@"Request failed: unacceptable content-type: %@", @"AFNetworking", nil), [response MIMEType]],
                                           NSURLErrorFailingURLErrorKey:[response URL],
                                           AFNetworkingOperationFailingURLResponseErrorKey: response
                                           };
                
                validationError = AFErrorWithUnderlyingError([NSError errorWithDomain:AFURLResponseSerializationErrorDomain code:NSURLErrorCannotDecodeContentData userInfo:userInfo], validationError);
            }
            
            responseIsValid = NO;
        }
    }
    
    if (error && !responseIsValid) {
        *error = validationError;
    }
    
    return responseIsValid;
}

- (id)responseObjectForResponse:(NSURLResponse *)response
                           data:(NSData *)data
                          error:(NSError *__autoreleasing *)error
{
    if (![self validateResponse:(NSHTTPURLResponse *)response data:data error:error]) {
        if (AFErrorOrUnderlyingErrorHasCode(*error, NSURLErrorCannotDecodeContentData)) {
            return nil;
        }
    }
    
    // Workaround for behavior of Rails to return a single space for `head :ok` (a workaround for a bug in Safari), which is not interpreted as valid input by NSJSONSerialization.
    // See https://github.com/rails/rails/issues/1742
    //
    // TODO: this is most certainly not necessary for Livefyre API
    //
    NSStringEncoding stringEncoding = self.stringEncoding;
    if (response.textEncodingName) {
        CFStringEncoding encoding = CFStringConvertIANACharSetNameToEncoding((CFStringRef)response.textEncodingName);
        if (encoding != kCFStringEncodingInvalidId) {
            stringEncoding = CFStringConvertEncodingToNSStringEncoding(encoding);
        }
    }
    
    id responseObject = nil;
    NSError *serializationError = nil;
    @autoreleasepool {
        NSString *responseString = [[NSString alloc] initWithData:data encoding:stringEncoding];
        
        if (!self.acceptableContentTypes || [self.acceptableContentTypes containsObject:[response MIMEType]]) {
            if (responseString && ![responseString isEqualToString:@" "]) {
                // Workaround for a bug in NSJSONSerialization when Unicode character escape codes are used instead of the actual character
                // See http://stackoverflow.com/a/12843465/157142
                //
                // TODO: this may not be necessary with JSONKit
                data = [responseString dataUsingEncoding:NSUTF8StringEncoding];
                
                if (data) {
                    if ([data length] > 0) {
                        // To use NSJSONSerialization instead of JSONKit simply replace
                        // the line below with (note that this may cause failure on some endpoints
                        // because of the large numbers problem):
                        // responseObject = [NSJSONSerialization JSONObjectWithData:data options:self.readingOptions error:&serializationError];
                        @try {
                            responseObject = [responseString objectFromJSONString];
                        }
                        @catch (NSException *e) {
                            // TODO: again, verify that the call in the try block above is
                            // needed at all (might be able to get away with just objectFromJSONString).
                            responseObject = [self.decoder objectWithData:data error:&serializationError];
                        }
                    }
                    else {
                        return nil;
                    }
                }
                else {
                    NSDictionary *userInfo = @{
                                               NSLocalizedDescriptionKey: NSLocalizedStringFromTable(@"Data failed decoding as a UTF-8 string", nil, @"AFNetworking"),
                                               NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:NSLocalizedStringFromTable(@"Could not decode string: %@", nil, @"AFNetworking"), responseString]
                                               };
                    
                    serializationError = [NSError errorWithDomain:AFURLResponseSerializationErrorDomain code:NSURLErrorCannotDecodeContentData userInfo:userInfo];
                }
            }
        }
        else {
            responseObject = responseString;
        }
    }

    NSUInteger statusCode = [(NSHTTPURLResponse*)response statusCode];
    if (self.acceptableStatusCodes && ![self.acceptableStatusCodes containsIndex:statusCode]) {
        if (error) {
            *error = LFSErrorFromResponse(statusCode, responseObject);
        }
        return nil;
    }

    if ([responseObject respondsToSelector:@selector(objectForKey:)]) {
        NSString *status = [responseObject objectForKey:@"status"];
        if ([status isEqualToString:@"ok"]) {
            responseObject = [responseObject objectForKey:@"data"];
        }
        else if (error && [status isEqualToString:@"error"]) {
            *error = LFSErrorFromObject(responseObject);
        }
    } else if (error) {
        *error = AFErrorWithUnderlyingError(serializationError, *error);
    }

    return responseObject;
}


#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (!self) {
        return nil;
    }
    
    self.readingOptions = (JKFlags)[decoder decodeIntegerForKey:NSStringFromSelector(@selector(readingOptions))];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    
    [coder encodeInteger:self.readingOptions forKey:NSStringFromSelector(@selector(readingOptions))];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    LFSJSONResponseSerializer *serializer = [[[self class] allocWithZone:zone] init];
    serializer.readingOptions = self.readingOptions;
    
    return serializer;
}

@end
