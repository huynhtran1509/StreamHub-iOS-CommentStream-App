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

@synthesize array = _array;
@synthesize index = _index;

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
        LFSContent *content = [_array objectAtIndex:--_index];
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
@property (nonatomic, strong) NSMutableDictionary *likes;

@end


@implementation LFSContentCollection

@synthesize lastEventId = _lastEventId;
@synthesize mapping = _mapping;
@synthesize array = _array;

@synthesize likes = _likes;

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
                return [obj2 compare:obj1];
            }];
}

- (NSUInteger)indexOfKey:(id<NSCopying>)key
{
    LFSContent *content = [self objectForKey:key];
    if (content == nil) {
        return NSNotFound;
    } else {
        return [self indexOfObject:content];
    }
}

-(void)insertObject:(LFSContent*)object
{
    [self insertObject:object forKey:[(LFSContent*)object idString]];
}

-(void)insertObject:(LFSContent*)object forKey:(id<NSCopying>)key
{
    // this is our insert primitive -- all other methods with similar functionality
    // ultimately redirect here
    //
    // first insert into the dictionary
    NSAssert([_mapping objectForKey:key] == nil, @"Pre-existing object found");
    [_mapping setObject:object forKey:key];
    
    // prepare our nested enumeration data
    LFSContent *parent;
    if (object.contentParentId != nil
        && (parent = [self objectForKey:object.contentParentId]) != nil)
    {
        // found parent
        NSAssert(parent.datePath != nil, @"evenPath cannot be nil");
        NSMutableArray *array = [parent.datePath mutableCopy];
        [array addObject:object.contentCreatedAt];
        [object setDatePath:array];
        [object setParent:parent];
        [parent.children addObject:object];
    }
    else
    {
        // either no nesting or parent does not exist in memory
        object.datePath = [[NSMutableArray alloc] initWithObjects:object.contentCreatedAt, nil];
    }
    
    // determine the correct index to insert the object into
    NSUInteger index = [_array indexOfObject:object
                               inSortedRange:NSMakeRange(0u, [_array count])
                                     options:NSBinarySearchingInsertionIndex
                             usingComparator:^NSComparisonResult(LFSContent *obj1,
                                                                 LFSContent *obj2)
                        {
                            return [obj2 compare:obj1];
                        }];
    [_array insertObject:object atIndex:index];
}

-(void)removeObject:(id)object
{
    [self removeObject:object forKey:[(LFSContent*)object idString]];
}

- (void)removeObjectAtIndex:(NSUInteger)index
{
    id object = [self.array objectAtIndex:index];
    [self removeObject:object];
}

-(void)removeObject:(id)object forKey:(id)key
{
    // this is our remove primitive -- all other methods with similar functionality
    // ultimately redirect here
    //
    [[[object parent] children] removeObject:object];
    [object setParent:nil];
    [_mapping removeObjectForKey:key];
    NSUInteger index = [self indexOfObject:object];
    [_array removeObjectAtIndex:index];
}

-(void)updateLastEventWithContent:(LFSContent*)content
{
    // store last event id
    if (_lastEventId == nil
        || (content.eventId != nil && ![content.eventId isEqual:[NSNull null]]
            && [content.eventId compare:_lastEventId] == NSOrderedDescending))
    {
        _lastEventId = content.eventId;
    }
}

- (void)registerOpineWithContent:(LFSContent*)content
{
    NSString *targetId = content.targetId;
    NSMutableSet *authors = [_likes objectForKey:targetId];
    if (authors == nil) {
        authors = [[NSMutableSet alloc] init];
        [_likes setObject:authors forKey:targetId];
    }
    if (content.visibility == LFSContentVisibilityNone) {
        // unlike -- remove author id
        [authors removeObject:content.contentAuthorId];
    }
    else if (content.visibility == LFSContentVisibilityEveryone) {
        // like -- add author id
        [authors addObject:content.contentAuthorId];
    }
}

- (void)addObject:(id)anObject
{
    // check if object is of appropriate type
    LFSContent *content = [[LFSContent alloc] initWithObject:anObject];
    [self setObject:content forKey:content.idString];
}

- (void)setObject:(id)object forKey:(id<NSCopying>)key
{
    // check if object is of appropriate type
    LFSContent *content = ([object isKindOfClass:[LFSContent class]]
                           ? object
                           : [[LFSContent alloc] initWithObject:object]);
    [self updateLastEventWithContent:content];
    
    NSAssert([content.idString isEqualToString:(NSString*)key], @"Key not equal to content id");
    
    LFSContent *oldContent = [_mapping objectForKey:key];
    if (oldContent != nil)
    {
        // pre-existing object found (should never happen with bootstrap data)
        [oldContent setObject:content.object];
        
        [self handleVisibilityChangeForContent:oldContent];
    }
    else
    {
        // no pre-existing object found
        [content enumerateVisiblePathsUsingBlock:^(LFSContent *obj) {
            // insert all objects listed here in that order
            [self insertObject:obj];
        }];
        
        if (content.nodeCount > 0 && content.contentParentId != nil) {
            LFSContent *parent = [self objectForKey:content.contentParentId];
            // update parents
            if (parent != nil) {
                [self changeNodeCountOf:parent withDelta:content.nodeCount];
            }
        }
    }
    
    if (content.contentType == LFSContentTypeOpine)
    {
        // dealing with an opine
        [self registerOpineWithContent:content];
    }
}

-(NSArray*)handleVisibilityChangeForContent:(LFSContent*)content
{
    NSInteger expectedNodeCount = ((content.visibility == LFSContentVisibilityEveryone ? 1 : 0) +
                                   content.nodeCountSumOfChildren);
    NSInteger delta = (NSInteger)expectedNodeCount - content.nodeCount;
    if (delta < 0) {
        // checking if delta is negative here because it is possible that we receive content
        // after delete event
        NSAssert(delta == -1, @"No support for deleting more than one comment at once");
        return [self changeNodeCountOf:content withDelta:delta];
    }
    return nil;
}

-(NSArray*)changeNodeCountOf:(LFSContent*)content withDelta:(NSInteger)delta
{
    // return indexes of nodes that has been deleted
    //
    // recursively change (with optional removal) the node count of this node
    // and of all parent nodes above it
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    NSParameterAssert(content != nil);
    if (delta == 0) {
        return array;
    }

    content.nodeCount += delta;
    LFSContent *parent = content.parent;
    if (content.nodeCount < 1) {
        NSUInteger contentIndex = [self indexOfObject:content];
        [self removeObjectAtIndex:contentIndex];
        [array addObject:[NSIndexPath indexPathForRow:contentIndex inSection:0]];
    }

    while (parent != nil) {
        parent.nodeCount += delta;
        LFSContent *prev = parent;
        parent = parent.parent;
        if (prev.nodeCount < 1) {
            NSUInteger prevIndex = [self indexOfObject:prev];
            [self removeObjectAtIndex:prevIndex];
            [array addObject:[NSIndexPath indexPathForRow:prevIndex inSection:0]];
        }
    }
    return array;
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
        _likes = [[NSMutableDictionary alloc] init];
        _lastEventId = nil;
        
        for (NSUInteger i = 0; i < cnt; i++)
        {
            [self setObject:objects[i] forKey:keys[i]];
        }
    }
    return self;
}

- (id)objectForKey:(id)key
{
    return [_mapping objectForKey:key];
}

- (id)objectAtIndex:(NSUInteger)index
{
    return [_array objectAtIndex:index];
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
        // TODO: move setAuthorWithCollection out of LFSContent?
        [content setAuthorWithCollection:_authors];
    }
    NSMutableSet *authors = [self.likes objectForKey:content.idString];
    if (authors == nil) {
        authors = [[NSMutableSet alloc] init];
        [self.likes setObject:authors forKey:content.idString];
    }
    [content setLikes:authors];
    return [self.array objectAtIndex:index];
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
        self.likes = [[NSMutableDictionary alloc] init];
        
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

-(void)removeObject:(id)object
{
    [super removeObject:object];
}

- (void)removeObjectAtIndex:(NSUInteger)index
{
    [super removeObjectAtIndex:index];
}

- (void)removeObjectForKey:(id<NSCopying>)key
{
    [self removeObject:[self.mapping objectForKey:key]
                forKey:key];
}

- (void)removeAllObjects
{
    [self.mapping removeAllObjects];
    [self.array removeAllObjects];
    [self.likes removeAllObjects];
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

#pragma mark - Other

//TODO: consider using notifications for this
-(NSArray*)updateContentForContentId:(id<NSCopying>)contentId setVisibility:(LFSContentVisibility)visibility
{
    LFSContent *content = [self objectForKey:contentId];
    [content setVisibility:visibility];
    return [self handleVisibilityChangeForContent:content];
}


@end
