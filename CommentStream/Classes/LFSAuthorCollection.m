//
//  LFSAuthorCollection.m
//  CommentStream
//
//  Created by Eugene Scherba on 9/23/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import "LFSAuthorCollection.h"

@implementation LFSAuthorCollection {
    NSMutableDictionary *_dictionary;
}

- (id)init
{
	return [self initWithCapacity:0u];
}

- (id)copy
{
	return [self mutableCopy];
}

-(void)dealloc
{
    _dictionary = nil;
}

+(instancetype)dictionary
{
    return [[self alloc] init];
}

#pragma mark - NSMutableDictionary primitives

-(id)initWithCapacity:(NSUInteger)numItems
{
    self = [super init];
	if (self != nil)
	{
        _dictionary = [[NSMutableDictionary alloc] initWithCapacity:numItems];
	}
	return self;
}

-(void)setObject:(id)anObject forKey:(id<NSCopying>)aKey
{
    if ([anObject isKindOfClass:[LFSAuthor class]]) {
        [_dictionary setObject:anObject forKey:aKey];
    } else {
        LFSAuthor *author = [[LFSAuthor alloc] initWithObject:anObject];
        [_dictionary setObject:author forKey:aKey];
    }
}

-(void)removeObjectForKey:(id)aKey
{
    [_dictionary removeObjectForKey:aKey];
}

#pragma mark - NSDictionary primitives

-(NSUInteger)count
{
    return [_dictionary count];
}

// designated initializer
-(id)initWithObjects:(const __unsafe_unretained id [])objects
             forKeys:(const __unsafe_unretained id<NSCopying> [])keys
               count:(NSUInteger)cnt
{
    self = [super init];
    if (self != nil) {
        // initialize stuff here
        
        // create an NSDictionary from a C array of object pointers
        // and a C array of key pointers
        Class classOfLFSAuthor = [LFSAuthor class];
        LFSAuthor *__strong *array =
        (LFSAuthor *__strong *)malloc(sizeof(LFSAuthor*) * cnt);
        for (NSUInteger i = 0; i < cnt; i++) {
            id object = objects[i];
            LFSAuthor *author = ([object isKindOfClass:classOfLFSAuthor]
                                 ? (LFSAuthor*)object
                                 : [[LFSAuthor alloc] initWithObject:object]);
            array[i] = author;
        }
        _dictionary = [[NSMutableDictionary alloc]
                       initWithObjects:array forKeys:keys count:cnt];
        free(array);
    }
    
    return self;
}

-(id)objectForKey:(id)aKey
{
    return [_dictionary objectForKey:aKey];
}

-(NSEnumerator*)keyEnumerator
{
    return [_dictionary keyEnumerator];
}

@end
