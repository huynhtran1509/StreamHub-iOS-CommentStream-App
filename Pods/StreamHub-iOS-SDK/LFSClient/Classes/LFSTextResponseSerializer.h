//
//  LFSTextResponseSerializer.h
//  LFSClient
//
//  Created by Eugene Scherba on 4/6/14.
//  Copyright (c) 2014 Livefyre. All rights reserved.
//

#import "LFSBaseClient.h"
#import <AFNetworking/AFURLResponseSerialization.h>

@interface LFSTextResponseSerializer: AFHTTPResponseSerializer
/**
 @abstract decode plain-text responses from LG authentication servers
 */
@end
