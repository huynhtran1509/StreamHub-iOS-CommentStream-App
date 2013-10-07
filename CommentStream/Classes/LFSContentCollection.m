//
//  LFSContentCollection.m
//  CommentStream
//
//  Created by Eugene Scherba on 9/24/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import "LFSContent.h"
#import "LFSContentCollection.h"
#import "LFSAuthorCollection.h"

NSString *descriptionForObject(id object, id locale, NSUInteger indent)
{
    if ([object respondsToSelector:@selector(descriptionWithLocale:indent:)])
    {
        return [object descriptionWithLocale:locale indent:indent];
    }
    else if ([object respondsToSelector:@selector(descriptionWithLocale:)])
    {
        return [object descriptionWithLocale:locale];
    }
    else
    {
        return [object description];
    }
}

#pragma mark LFSOrderedKeyEnumerator
@interface LFSContentKeyEnumerator : NSEnumerator

@property (nonatomic, copy) NSArray *array;
@property (nonatomic, assign) NSUInteger index;

- (id)initWithObjects:(NSArray *)array;

@end

@implementation LFSContentKeyEnumerator

- (id)initWithObjects:(NSArray *)array
{
    self = [super init];
    if (self)
    {
        _array = [array copy];
        _index = [_array count];
    }
    return self;
}

- (id)nextObject
{
    if (_index > 0) {
        LFSContent *content = _array[--_index];
        return content.idString;
    } else {
        return nil;
    }
}

@end

#pragma mark - LFSContentCollection
@interface LFSContentCollection ()

@property (nonatomic, strong) NSMutableDictionary *mapping;
@property (nonatomic, strong) NSMutableArray *array;

@end


@implementation LFSContentCollection

@synthesize mapping = _mapping;
@synthesize array = _array;

- (id)copyWithZone:(__unused NSZone *)zone
{
    return self;
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    return [[[LFSMutableContentCollection class] allocWithZone:zone]
            initWithDictionary:self];
}

#pragma mark - insertion stuff

- (NSUInteger)indexOfObject:(id)anObject
{
    return [_array indexOfObject:anObject
                   inSortedRange:NSMakeRange(0u, [_array count])
                         options:NSBinarySearchingFirstEqual
                 usingComparator:^NSComparisonResult(LFSContent *obj1,
                                                     LFSContent *obj2)
            {
                return [obj2.eventId compare:obj1.eventId];
            }];
}

-(void)insertContentObject:(LFSContent*)content
{
    // determine recursion level (will be used to offset content
    // to show replies)
    
    [content updateGenerationInCollection:self withLimit:4u];

    // determine the correct index to insert the object into
    NSUInteger index = [_array indexOfObject:content
                               inSortedRange:NSMakeRange(0u, [_array count])
                                     options:NSBinarySearchingInsertionIndex
                             usingComparator:^NSComparisonResult(LFSContent *obj1,
                                                                 LFSContent *obj2)
                        {
                            return [obj2.eventId compare:obj1.eventId];
                        }];
    [_array insertObject:content atIndex:index];
}

- (void)setObject:(id)object forKey:(id<NSCopying>)key
{
    LFSContent *content = [[LFSContent alloc] initWithObject:object];
    if (content.visibility != LFSContentVisibilityEveryone
        || content.contentType != LFSContentTypeMessage)
    {
        return;
    }
    LFSContent *oldContent = _mapping[key];
    if (oldContent)
    {
        // update content
        content = [[LFSContent alloc] initWithObject:oldContent];
        [content setObject:object];
        // not setting the array -- it should already contain the object
    } else {
        [self insertContentObject:content];
    }
    
    // important: add child content *after* adding current object
    // to the mapping structure
    _mapping[key] = content;
    [self addChildContent:content];
}

- (void)addObject:(id)anObject
{
    LFSContent *content = [[LFSContent alloc] initWithObject:anObject];
    if (content.visibility != LFSContentVisibilityEveryone
        || content.contentType != LFSContentTypeMessage)
    {
        return;
    }
    id<NSCopying> key = content.idString;
    LFSContent *oldContent = _mapping[key];
    if (oldContent)
    {
        // update content
        content = [[LFSContent alloc] initWithObject:oldContent];
        [content setObject:anObject];
        // not setting the array -- it should already contain the object
    } else {
        [self insertContentObject:content];
    }
    
    // important: add child content *after* adding current object
    // to the mapping structure
    _mapping[key] = content;
    [self addChildContent:content];
}

- (void)addChildContent:(LFSContent*)content
{
    // Purpose: recursively add all children
    //
    // Note: there is no need to add children in deterministic order,
    // so we use concurrent enumeration
    //
    id childContent = content.childContent;
    if (childContent != nil) {
        if ([childContent isKindOfClass:[NSArray class]]) {
            [childContent
             enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                 [self addObject:obj];
             }];
        } else if ([childContent isKindOfClass:[NSDictionary class]]) {
            [childContent
             enumerateKeysAndObjectsWithOptions:NSEnumerationConcurrent
             usingBlock:^(id<NSCopying> key, id obj, BOOL *stop)
             {
                 [self setObject:obj forKey:key];
             }];
        } else {
            [NSException raise:@"Uknown childContent type"
                        format:@"Child content type %@ while expected NSArray or NSDictionary",
             [childContent class]];
        }
    }
}

#pragma mark - Description

- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)indent
{
    NSMutableString *padding = [NSMutableString string];
    for (NSUInteger i = 0; i < indent; i++)
    {
        [padding appendString:@"    "];
    }
    
    NSMutableString *description = [NSMutableString string];
    [description appendFormat:@"%@{\n", padding];
    for (LFSContent *object in _array)
    {
        [description appendFormat:@"%@    %@ = %@;\n", padding,
         descriptionForObject(object.idString, locale, indent),
         descriptionForObject([object description], locale, indent)];
    }
    [description appendFormat:@"%@}\n", padding];
    return description;
}



#pragma mark - NSDictionary primitives


- (NSUInteger)count
{
    return [_array count];
}

// designated initializer

-(id)initWithObjects:(const __unsafe_unretained id [])objects
             forKeys:(const __unsafe_unretained id<NSCopying> [])keys
               count:(NSUInteger)cnt
{
    self = [super init];
    if (self != nil) {
        // initialize stuff here
        _mapping = [[NSMutableDictionary alloc] initWithCapacity:cnt];
        _array = [[NSMutableArray alloc] initWithCapacity:cnt];
        
        for (NSUInteger i = 0; i < cnt; i++)
        {
            [self setObject:objects[i] forKey:keys[i]];
        }
    }
    return self;
}

- (id)objectForKey:(id<NSCopying>)key
{
    return _mapping[key];
}

- (id)objectAtIndex:(NSUInteger)index
{
    return _array[index];
}

- (NSEnumerator *)keyEnumerator
{
    return [[LFSContentKeyEnumerator alloc] initWithObjects:_array];
}

#pragma mark - NSDictionary (not primitives)

-(NSEnumerator*)objectEnumerator
{
    return [_array objectEnumerator];
}

#pragma mark - NSArray
- (NSEnumerator *)reverseObjectEnumerator
{
    return [_array reverseObjectEnumerator];
}

-(instancetype)initWithArray:(NSArray*)array
{
    self = [super init];
    if (self != nil) {
        for (id object in array) {
            [self addObject:object];
        }
    }
    return self;
}

@end


#pragma mark - LFSMutableContentCollection

@implementation LFSMutableContentCollection

@synthesize authors = _authors;

-(LFSAuthorCollection*)authors
{
    if (_authors == nil) {
        _authors = [[LFSAuthorCollection alloc] init];
    }
    return _authors;
}

-(void)setAuthors:(id)authors
{
    if ([authors isKindOfClass:[LFSAuthorCollection class]]) {
        // everything is clear
        _authors = authors;
    } else {
        _authors = [[LFSAuthorCollection alloc] initWithDictionary:authors];
    }
}

-(void)addAuthorsCollection:(id)collection
{
    [self.authors addEntriesFromDictionary:collection];
}


- (id)objectAtIndex:(NSUInteger)index
{
    LFSContent *content = [self.array objectAtIndex:index];
    if (content.author == nil && _authors != nil) {
        [content setAuthorWithCollection:_authors];
    }
    return self.array[index];
}


#pragma mark - NSMutableDictionary methods
+ (id)dictionaryWithCapacity:(NSUInteger)count
{
    return [[self alloc] initWithCapacity:count];
}

// designated initializer
- (id)initWithCapacity:(NSUInteger)capacity
{
    self = [super init];
    if (self)
    {
        _authors = nil;
        
        // values and keys are private to LFSOrderedDictionary that we
        // inherit from
        self.mapping = [[NSMutableDictionary alloc] initWithCapacity:capacity];
        self.array = [[NSMutableArray alloc] initWithCapacity:capacity];
        
        // just checking that we didn't mess up attribute naming
        NSAssert(self.mapping != nil, @"self.mapping failed to initialize");
        NSAssert(self.array != nil, @"self.array failed to initialize");
    }
    return self;
}

- (id)init
{
    return [self initWithCapacity:0u];
}

- (id)copyWithZone:(NSZone *)zone
{    
    return [[[LFSContentCollection class] allocWithZone:zone]
            initWithDictionary:self];
}

- (void)addEntriesFromDictionary:(NSDictionary *)otherDictionary
{
    [otherDictionary
     enumerateKeysAndObjectsWithOptions:NSEnumerationConcurrent
     usingBlock:^(id<NSCopying> key, id value, BOOL *stop)
     {
         [self setObject:value forKey:key];
     }];
}

- (void)removeObjectAtIndex:(NSUInteger)index
{
    LFSContent *object = [self.array objectAtIndex:index];
    [self.mapping removeObjectForKey:object.idString];
    [self.array removeObjectAtIndex:index];
}

- (void)removeObjectForKey:(id<NSCopying>)key
{
    LFSContent *object = [self.mapping objectForKey:key];
    [self.mapping removeObjectForKey:key];
    [self.array removeObject:object];
}

- (void)removeAllObjects
{
    [self removeObjectsForKeys:[self allKeys]];
}
 
- (void)removeObjectsForKeys:(NSArray *)keyArray
{    
    for (id<NSCopying> key in [keyArray copy])
    {
        [self removeObjectForKey:key];
    }
}

- (void)setDictionary:(NSDictionary *)otherDictionary
{    
    [self removeAllObjects];
    [self addEntriesFromDictionary:otherDictionary];
}

- (void)setObject:(id)object forKey:(id<NSCopying>)key
{
    [super setObject:object forKey:key];
}

#pragma mark - NSMutableArray

- (void)addObject:(id)anObject
{
    [super addObject:anObject];
}

-(void)addObjectsFromArray:(NSArray*)array
{
    for (id object in array)
    {
        [self addObject:object];
    }
}

@end
