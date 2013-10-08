//
//  LFSContentCollection.h
//  CommentStream
//
//  Created by Eugene Scherba on 9/24/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LFSContentCollection : NSDictionary

- (id)objectAtIndex:(NSUInteger)index;
- (NSEnumerator *)reverseObjectEnumerator;
- (instancetype)initWithArray:(NSArray*)array;

- (NSUInteger)indexOfObject:(id)anObject; // implemented using sorted range

@property (nonatomic, readonly) NSNumber *lastEventId;

@end

/**
 * The design goal is to have a similar interface to NSMutableDictionary
 */
@interface LFSMutableContentCollection : LFSContentCollection

+ (id)dictionaryWithCapacity:(NSUInteger)count;
- (id)initWithCapacity:(NSUInteger)count;

- (void)removeObjectAtIndex:(NSUInteger)index;
- (void)addEntriesFromDictionary:(NSDictionary *)otherDictionary;
- (void)removeAllObjects;
- (void)setDictionary:(NSDictionary *)otherDictionary;
- (void)setObject:(id)object forKey:(id<NSCopying>)key;
- (void)removeObjectForKey:(id<NSCopying>)key;
- (void)removeObjectsForKeys:(NSArray *)keyArray;
- (void)addObjectsFromArray:(NSArray*)array;
- (void)addObject:(id)anObject;

/* other stuff */
@property (nonatomic, strong) id authors;
-(void)addAuthorsCollection:(id)collection;

@end

