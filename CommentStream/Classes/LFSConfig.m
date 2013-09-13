//
//  LFConfig.m
//  LivefyreClient
//
//  Created by Thomas Goyne on 5/27/12.
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

#import "LFSConfig.h"

@interface LFSConfig ()
@property (nonatomic, readonly, strong) NSDictionary *config;
@end

@implementation LFSConfig
@synthesize config = _config;
@synthesize collections = _collections;

#pragma mark - Lifecycle
-(id)initWithPlist:(NSString*)resourcePath
{
    self = [super init];
    if (self) {
        _collections = nil;
        [self processConfig:resourcePath];
    }
    return self;
}

-(void)dealloc
{
    _config = nil;
    _collections = nil;
}

#pragma mark - private methods
- (void)processConfig:(NSString*)resourcePath
{
    NSString *path = [[NSBundle bundleForClass:[self class]]
                      pathForResource:resourcePath ofType:@"plist"];
    _config = [[NSDictionary alloc] initWithContentsOfFile:path];
}

#pragma mark - public methods
-(NSArray*)collections
{
    if (_collections) {
        return _collections;
    }
    NSDictionary *defaults = [_config objectForKey:@"defaults"];
    NSArray *collections = [_config objectForKey:@"collections"];
    NSMutableArray *temp = [NSMutableArray arrayWithCapacity:[collections count]];
    for (NSDictionary *collection in collections) {
        NSMutableDictionary *base = [defaults mutableCopy];
        [base addEntriesFromDictionary:collection];
        [temp addObject:base];
    }
    _collections = [temp copy];
    return _collections;
}

@end
