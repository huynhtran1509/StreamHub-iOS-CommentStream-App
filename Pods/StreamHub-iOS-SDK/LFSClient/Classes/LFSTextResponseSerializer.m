//
//  LFSTextResponseSerializer.m
//  LFSClient
//
//  Created by Eugene Scherba on 4/6/14.
//  Copyright (c) 2014 Livefyre. All rights reserved.
//

#import "LFSTextResponseSerializer.h"

@implementation LFSTextResponseSerializer
- (instancetype)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    self.stringEncoding = NSUTF8StringEncoding;
    self.acceptableStatusCodes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(200, 100)];
    self.acceptableContentTypes = [NSSet setWithObjects:@"text/html", @"text/plain", nil];
    return self;
}

-(id)responseObjectForResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError *__autoreleasing *)error
{
    NSString *text = [[NSString alloc] initWithData:data encoding:self.stringEncoding];
    return text;
}
@end
