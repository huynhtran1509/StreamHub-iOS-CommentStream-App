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
            id key = keys[i];
            id object = objects[i];
            
            // TODO: handle "replaces" cases here...
            
            // note that array is added to at the end but it is actually
            // the most recent stuff that is being added
            
            LFSContent *content;
            LFSContent *oldContent = _mapping[key];
            if (oldContent)
            {
                // update content
                content = [[LFSContent alloc] initWithObject:oldContent];
                [content setObject:object];
                // not setting the array -- it should already contain the object
            } else {
                // find the appropriate index to insert content at
                // always keep the array sorted by eventId
                content = [[LFSContent alloc] initWithObject:object];
                NSRange searchRange = NSMakeRange(0u, [_array count]);
                NSUInteger index = [_array indexOfObject:content
                                           inSortedRange:searchRange
                                                 options:NSBinarySearchingInsertionIndex
                                         usingComparator:^(LFSContent *obj1,
                                                           LFSContent *obj2)
                                    {
                                        return obj1.eventId < obj2.eventId;
                                    }];
                [_array insertObject:content atIndex:index];
            }
            _mapping[key] = content;
        }
    }
    return self;
}

- (id)objectForKey:(id)key
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
        for (id object in array)
        {
            // TODO: handle "replaces" cases here...
            
            // note that array is added to at the end but it is actually
            // the most recent stuff that is being added
            
            LFSContent *content = [[LFSContent alloc] initWithObject:object];
            id key = content.idString;
            LFSContent *oldContent = _mapping[key];
            if (oldContent)
            {
                // update content
                content = [[LFSContent alloc] initWithObject:oldContent];
                [content setObject:object];
                // not setting the array -- it should already contain the object
            } else {
                // find the appropriate index to insert content at
                // always keep the array sorted by eventId
                content = [[LFSContent alloc] initWithObject:object];
                NSRange searchRange = NSMakeRange(0u, [_array count]);
                NSUInteger index = [_array indexOfObject:content
                                           inSortedRange:searchRange
                                                 options:NSBinarySearchingInsertionIndex
                                         usingComparator:^(LFSContent *obj1,
                                                           LFSContent *obj2)
                                    {
                                        return obj1.eventId < obj2.eventId;
                                    }];
                [_array insertObject:content atIndex:index];
            }
            _mapping[key] = content;
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
    for (id key in otherDictionary)
    {
        [self setObject:otherDictionary[key] forKey:key];
    }
}

- (void)removeObjectAtIndex:(NSUInteger)index
{
    LFSContent *object = [self.array objectAtIndex:index];
    [self.mapping removeObjectForKey:object.idString];
    [self.array removeObjectAtIndex:index];
}

- (void)removeObjectForKey:(id)key
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
    for (id key in [keyArray copy])
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
    LFSContent *content;
    LFSContent *oldContent = self.mapping[key];
    if (oldContent)
    {
        // update content
        content = [[LFSContent alloc] initWithObject:oldContent];
        [content setObject:object];
        // not setting the array -- it should already contain the object
    } else {
        // find the appropriate index to insert content at
        // always keep the array sorted by eventId
        content = [[LFSContent alloc] initWithObject:object];
        NSRange searchRange = NSMakeRange(0u, [self.array count]);
        NSUInteger index = [self.array indexOfObject:content
                                       inSortedRange:searchRange
                                             options:NSBinarySearchingInsertionIndex
                                     usingComparator:^(LFSContent *obj1,
                                                       LFSContent *obj2)
                            {
                                return obj1.eventId < obj2.eventId;
                            }];
        [self.array insertObject:content atIndex:index];
    }
    self.mapping[key] = content;
}

#pragma mark - NSMutableArray

- (void)addObject:(id)anObject
{
    LFSContent *content = [[LFSContent alloc] initWithObject:anObject];
    NSString *key = content.idString;
    LFSContent *oldContent = self.mapping[content.idString];
    if (!oldContent)
    {
        // find the appropriate index to insert content at
        // always keep the array sorted by eventId
        NSRange searchRange = NSMakeRange(0u, [self.array count]);
        NSUInteger index = [self.array indexOfObject:content
                                       inSortedRange:searchRange
                                             options:NSBinarySearchingInsertionIndex
                                     usingComparator:^(LFSContent *obj1,
                                                       LFSContent *obj2)
                            {
                                return obj1.eventId < obj2.eventId;
                            }];
        [self.array insertObject:content atIndex:index];
    }
    self.mapping[key] = content;
}

-(void)addObjectsFromArray:(NSArray*)array
{
    for (id object in array)
    {
        [self addObject:object];
    }
}

#pragma mark - KVC
- (void)setValue:(id)value forKey:(NSString *)key
{
    if (value)
    {
        [self setObject:value forKey:key];
    }
    else
    {
        [self removeObjectForKey:key];
    }
}

@end
