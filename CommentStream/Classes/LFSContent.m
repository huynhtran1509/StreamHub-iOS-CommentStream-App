//
//  LFSContent.m
//  CommentStream
//
//  Created by Eugene Scherba on 9/24/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import "LFSModelMacros.h"
#import "LFSContent.h"

const static char kVisibleNodeCount;

// TODO: return latest eventId, event for nodes that are not shown (hidden)
NSUInteger addVisibleMessagesToStack(NSMutableArray *stack, id root)
{
    // return number of visible nodes, add all nodes that have at least
    // one visible child to the stack
    const static NSString* const visKey = @"vis";
    const static NSString* const typeKey = @"type";
    const static NSString* const childContentKey = @"childContent";
    
    LFSContentType type = (LFSContentType)[[root objectForKey:typeKey] unsignedIntegerValue];
    if (type != LFSContentTypeMessage) {
        return 0u;
    }
    
    __block NSUInteger visibleNodeCount = ([[root objectForKey:visKey] unsignedIntegerValue] == LFSContentVisibilityEveryone ? 1u : 0u);
    NSArray *childContent = [root objectForKey:childContentKey];
    if (childContent) {
        for (id obj in childContent) {
            visibleNodeCount += addVisibleMessagesToStack(stack, obj);
        }
    }
    
    // only visit a child if that child or *any* of its children are visible
    // (this creates a problem where we visit a child only after all of its own
    // children have been visited. To remedy this, we build up a LIFO stack)
    if (visibleNodeCount > 0u)
    {
        LFSContent *content = [[LFSContent alloc] initWithObject:root];
        [content setNodeCount:visibleNodeCount];
        [stack addObject:content];
    }
    return visibleNodeCount;
}


// For detailed info, see
// https://github.com/Livefyre/lfdj/blob/production/lfcore/lfcore/v2/publishing/models.proto
typedef NS_ENUM(NSUInteger, LFSContentSource) {
    LFSContentSourceDefault = 0u,   // 0
    LFSContentSourceTwitter,        // 1
    LFSContentSourceFacebook,       // 2
    LFSContentSourceGooglePlus,     // 3
    LFSContentSourceFlickr,         // 4
    LFSContentSourceYouTube,        // 5
    LFSContentSourceRSS,            // 6
    LFSContentSourceInstagram       // 7
};

#define SOURCE_IMAGE_MAP_LENGTH 8u
static NSString* const kLFSSourceImageMap[SOURCE_IMAGE_MAP_LENGTH] = {
    nil,                        // LFSContentSourceDefault      (0)
    @"SourceTwitter",           // LFSContentSourceTwitter      (1)
    @"SourceFacebook",          // LFSContentSourceFacebook     (2)
    nil,                        // LFSContentSourceGooglePlus   (3)
    nil,                        // LFSContentSourceFlickr       (4)
    nil,                        // LFSContentSourceYouTube      (5)
    @"SourceRSS",               // LFSContentSourceRSS          (6)
    @"SourceInstagram",         // LFSContentSourceInstagram    (7)
};

#define CONTENT_SOURCE_DECODE_LENGTH 20u
static const NSUInteger kLFSContentSourceDecode[CONTENT_SOURCE_DECODE_LENGTH] =
{
    LFSContentSourceDefault,    //  0
    LFSContentSourceTwitter,    //  1
    LFSContentSourceTwitter,    //  2
    LFSContentSourceFacebook,   //  3
    LFSContentSourceDefault,    //  4
    LFSContentSourceDefault,    //  5
    LFSContentSourceFacebook,   //  6
    LFSContentSourceTwitter,    //  7
    LFSContentSourceDefault,    //  8
    LFSContentSourceDefault,    //  9
    LFSContentSourceGooglePlus, // 10
    LFSContentSourceFlickr,     // 11
    LFSContentSourceYouTube,    // 12
    LFSContentSourceRSS,        // 13
    LFSContentSourceFacebook,   // 14
    LFSContentSourceTwitter,    // 15
    LFSContentSourceYouTube,    // 16
    LFSContentSourceDefault,    // 17
    LFSContentSourceDefault,    // 18
    LFSContentSourceInstagram,  // 19
};

#pragma mark - LFSContent implementaiton
@implementation LFSContent {
    BOOL _lastVisIsSet;
    BOOL _visibilityIsSet;
    BOOL _contentTypeIsSet;
    BOOL _contentSourceIsSet;
    BOOL _authorIsModeratorIsSet;
}

/* Sample content:

{
    childContent =     (
                        {
                            content =             {
                                authorId = "-";
                                id = "tweet-393797235068002304@twitter.com.http://twitter.com/qajoker/status/393797235068002304/photo/1";
                                link = "http://twitter.com/qajoker/status/393797235068002304/photo/1";
                                oembed =                 {
                                    "author_name" = qajoker;
                                    "author_url" = "http://twitter.com/qajoker";
                                    height = 225;
                                    link = "http://twitter.com/qajoker/status/393797235068002304/photo/1";
                                    "provider_name" = Twitter;
                                    "provider_url" = "http://twitter.com";
                                    "thumbnail_height" = 150;
                                    "thumbnail_url" = "https://pbs.twimg.com/media/BXcMf7YCYAEFdCc.jpg:thumb";
                                    "thumbnail_width" = 150;
                                    title = "Twitter / qajoker: SF 49ers logo http://t.co/qF5bn5arBp";
                                    type = photo;
                                    url = "https://pbs.twimg.com/media/BXcMf7YCYAEFdCc.jpg:large";
                                    version = "1.0";
                                    width = 225;
                                };
                                position = 0;
                                targetId = "tweet-393797235068002304@twitter.com";
                            };
                            event = 1382723577264480;
                            source = 0;
                            type = 3;
                            vis = 1;
                        }
                        );
    content =     {
        annotations =         {
        };
        authorId = "802889209@twitter.com";
        bodyHtml = "SF 49ers logo <a href=\"http://t.co/qF5bn5arBp\" target=\"_blank\" rel=\"nofollow\">pic.twitter.com/qF5bn5arBp</a>";
        createdAt = 1382723552;
        id = "tweet-393797235068002304@twitter.com";
        parentId = "";
        updatedAt = 1382723554;
    };
    event = 1382723577264480;
    source = 1;
    type = 0;
    vis = 1;
}
*/

#pragma mark - Properties

@synthesize datePath = _datePath;
@synthesize likes = _likes;
@synthesize nodeCount = _nodeCount;
@synthesize parent = _parent;
@synthesize index = _index;

@synthesize object = _object;
-(void)setObject:(id)object
{
    if (_object != nil && _object != object) {
        typeof(self) newObject = [[self.class alloc] initWithObject:object];
        NSString *newId = newObject.idString;
        if (![self.idString isEqualToString:newId]) {
            [NSException raise:@"Object rebase conflict"
                        format:@"Cannot rebase object with id %@ on top %@", self.idString, newId];
        }
        [self resetCached];
    }
    _object = object;
}

-(NSString*)description
{
    return [_object description];
}

-(NSUInteger)hash
{
    return [self.idString hash];
}

-(BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[self class]]) {
        return [self.idString isEqualToString:[object idString]];
    } else {
        return NO;
    }
}

#pragma mark -
@synthesize author = _author;


#pragma mark - Lazy autho-synthesized properties

@synthLazyWithNull(NSDictionary, content, _object, @"content");
@synthLazyWithNull(NSDictionary, contentAnnotations, self.content, @"annotations");
@synthLazyWithNull(NSArray, childContent, _object, @"childContent");

@synthLazyWithNull(NSString, idString, self.content, @"id");
@synthLazyWithNull(NSString, targetId, self.content, @"targetId");
@synthLazyWithNull(NSString, contentParentId, self.content, @"parentId");
@synthLazyWithNull(NSString, contentBodyHtml, self.content, @"bodyHtml");
@synthLazyWithNull(NSString, contentAuthorId, self.content, @"authorId");

@synthLazyWithNull(NSNumber, eventId, _object, @"event");

#pragma mark -
@synthesize firstOembed = _firstOembed;
-(LFSOembed*)firstOembed
{
    // return first attachment of type "photo" if it exists
    if (_firstOembed == nil) {
        if (self.childContent != nil) {
            for (NSDictionary *obj in self.childContent) {
                NSDictionary *content = [obj objectForKey:@"content"];
                if (content != nil) {
                    id oembedObject = [content objectForKey:@"oembed"];
                    if (oembedObject != nil) {
                        LFSOembed *oembed = [[LFSOembed alloc] initWithObject:oembedObject];
                        LFSOembedType oembedType = oembed.oembedType;
                        if (oembedType == LFSOembedTypePhoto ||
                            oembedType == LFSOembedTypeVideo ||
                            oembedType == LFSOembedTypeRich) {
                            _firstOembed = oembed;
                            break;
                        }
                    }
                }
            }
        }
    }
    return _firstOembed;
}

#pragma mark -
-(NSUInteger)nodeCountSumOfChildren
{
    NSUInteger count = 0u;
    for (typeof(self) child in self.children) {
        count += child.nodeCount;
    }
    return count;
}

#pragma mark -
@synthesize children = _children;
-(NSHashTable*)children
{
    if (_children == nil) {
        _children = [NSHashTable weakObjectsHashTable];
    }
    return _children;
}

#pragma mark -
@synthesize authorIsModerator = _authorIsModerator;
-(BOOL)authorIsModerator
{
    const static NSString* const key = @"moderator";
    if (!_authorIsModeratorIsSet) {
        NSNumber *moderator = [self.contentAnnotations objectForKey:key];
        _authorIsModerator = (moderator != nil && [moderator boolValue]);
    }
    return _authorIsModerator;
}

#pragma mark -
-(UIImage*)contentSourceIcon
{
    NSUInteger rawContentSource = self.contentSource;
    if (rawContentSource < CONTENT_SOURCE_DECODE_LENGTH) {
        LFSContentSource contentSource = kLFSContentSourceDecode[rawContentSource];
        return [self imageForContentSource:contentSource];
    } else {
        return nil;
    }
}

#pragma mark -
-(UIImage*)contentSourceIconSmall
{
    NSUInteger rawContentSource = self.contentSource;
    if (rawContentSource < CONTENT_SOURCE_DECODE_LENGTH) {
        LFSContentSource contentSource = kLFSContentSourceDecode[rawContentSource];
        return [self smallImageForContentSource:contentSource];
    } else {
        return nil;
    }
}


#pragma mark -
@synthesize contentTwitterId = _contentTwitterId;
-(NSString*)contentTwitterId
{
    // try to extract twitter id from contentId --
    // if we fail, return nil
    static NSRegularExpression *regex = nil;
    if (_contentTwitterId == nil) {
        NSString *idString = self.idString;
        if (idString != nil) {
            if (regex == nil) {
                NSError *regexError = nil;
                regex = [NSRegularExpression
                         regularExpressionWithPattern:@"^tweet-(\\d+)@twitter.com$"
                         options:0
                         error:&regexError];
                NSAssert(regexError == nil,
                         @"Error creating regex: %@",
                         regexError.localizedDescription);
            }
            NSTextCheckingResult *match =
            [regex firstMatchInString:idString
                              options:0
                                range:NSMakeRange(0, [idString length])];
            if (match != nil) {
                _contentTwitterId = [idString substringWithRange:[match rangeAtIndex:1u]];
            }
        }
    }
    return _contentTwitterId;
}

#pragma mark -
@synthesize contentTwitterUrlString = _contentTwitterUrlString;
-(NSString*)contentTwitterUrlString
{
    if (_contentTwitterUrlString == nil) {
        NSString *twitterId = self.contentTwitterId;
        NSString *twitterHandle = self.author.twitterHandle;
        if (twitterId != nil && twitterHandle != nil)
        {
            _contentTwitterUrlString =
            [NSString stringWithFormat:@"https://twitter.com/%@/status/%@",
             twitterHandle, twitterId];
        }
    }
    if (_contentTwitterUrlString == (NSString*)[NSNull null]) {
        return nil;
    }
    return _contentTwitterUrlString;
}

#pragma mark -
@synthesize contentUpdatedAt = _contentUpdatedAt;
-(NSDate*)contentUpdatedAt
{
    const static NSString* const key = @"updatedAt";
    if (_contentUpdatedAt == nil) {
        _contentUpdatedAt = [NSDate dateWithTimeIntervalSince1970:
                             [[self.content objectForKey:key] doubleValue]];
    }
    return _contentUpdatedAt;
}

#pragma mark -
@synthesize contentCreatedAt = _contentCreatedAt;
-(NSDate*)contentCreatedAt
{
    const static NSString* const key = @"createdAt";
    if (_contentCreatedAt == nil) {
        _contentCreatedAt = [NSDate dateWithTimeIntervalSince1970:
                             [[self.content objectForKey:key] doubleValue]];
    }
    return _contentCreatedAt;
}

#pragma mark -
@synthesize lastVis = _lastVis;
-(LFSContentVisibility)lastVis
{
    const static NSString* const key = @"lastVis";
    if (!_lastVisIsSet) {
        _lastVis = [[_object objectForKey:key] unsignedIntegerValue];
    }
    return _lastVis;
}

#pragma mark -
@synthesize visibility = _visibility;
-(LFSContentVisibility)visibility
{
    const static NSString* const key = @"vis";
    if (!_visibilityIsSet) {
        _visibility = [[_object objectForKey:key] unsignedIntegerValue];
        _visibilityIsSet = YES;
    }
    return _visibility;
}

#pragma mark -
@synthesize contentType = _contentType;
-(LFSContentType)contentType
{
    const static NSString* const key = @"type";
    if (!_contentTypeIsSet) {
        _contentType = [[_object objectForKey:key] unsignedIntegerValue];
        _contentTypeIsSet = YES;
    }
    return _contentType;
}

#pragma mark -
@synthesize contentSource = _contentSource;
-(NSUInteger)contentSource
{
    const static NSString* const key = @"source";
    if (!_contentSourceIsSet) {
        _contentSource = [[_object objectForKey:key] unsignedIntegerValue];
        _contentSourceIsSet = YES;
    }
    return _contentSource;
}

#pragma mark - Private methods

-(UIImage*)imageForContentSource:(LFSContentSource)contentSource
{
    NSParameterAssert((NSUInteger)contentSource < SOURCE_IMAGE_MAP_LENGTH);
    // do a simple range check for memory safety
    if (contentSource <= LFSContentSourceInstagram) {
        NSString* const imageName = kLFSSourceImageMap[contentSource];
        return [UIImage imageNamed:imageName];
    } else {
        return nil;
    }
}

-(UIImage*)smallImageForContentSource:(LFSContentSource)contentSource
{
    NSParameterAssert((NSUInteger)contentSource < SOURCE_IMAGE_MAP_LENGTH);
    // do a simple range check for memory safety
    if (contentSource <= LFSContentSourceInstagram) {
        NSString* const imageName = kLFSSourceImageMap[contentSource];
        NSString *smallImageName = [imageName stringByAppendingString:@"Small"];
        return [UIImage imageNamed:smallImageName];
    } else {
        return nil;
    }
}


#pragma mark - Public methods

-(NSOrderedSet*)conversationParticipants
{
    // return profiles of all members of a conversation
    NSMutableOrderedSet *members = [[NSMutableOrderedSet alloc] init];
    for (LFSContent *object = self; object != nil; object = object.parent)
    {
        LFSAuthorProfile *member = object.author;
        if (member != nil) {
            [members addObject:member];
        }
    }
    return members;
}

-(NSMutableDictionary*)authorHandles
{
    // return a dictionary of { authorHandle -> authorProfileURL }
    // where authorHandle is a lowercase string
    NSOrderedSet *members = self.conversationParticipants;
    NSMutableDictionary *handles = [[NSMutableDictionary alloc] init];
    for (LFSAuthorProfile *member in members)
    {
        if (member.profileUrlString != nil && member.authorHandle != nil)
        {
            [handles setObject:member.profileUrlString
                        forKey:[member.authorHandle lowercaseString]];
        }
    }
    return handles;
}

-(void)setAuthorWithCollection:(LFSAuthorCollection *)authorCollection
{
    self.author = [authorCollection objectForKey:self.contentAuthorId];
}

-(NSComparisonResult)compare:(LFSContent*)otherObject
{
    // this is where the magic happens
    NSArray *path1 = self.datePath;
    NSArray *path2 = otherObject.datePath;
    
    NSUInteger minCount = MIN(path1.count, path2.count);
    NSComparisonResult result = [[path1 objectAtIndex:0u] compare:[path2 objectAtIndex:0u]];
    NSUInteger i;
    if (minCount > 0u) {
        result = [[path1 objectAtIndex:0u] compare:[path2 objectAtIndex:0u]];
    }
    for (i = 1u; i < minCount && result == NSOrderedSame; i++) {
        result = [[path2 objectAtIndex:i] compare:[path1 objectAtIndex:i]];
    }
    if (result == NSOrderedSame) {
        NSNumber *count1 = [NSNumber numberWithUnsignedInteger:path1.count];
        NSNumber *count2 = [NSNumber numberWithUnsignedInteger:path2.count];
        result = [count2 compare:count1];
    }
    return result;
}

-(void)enumerateVisiblePathsUsingBlock:(LFSContentChildVisitor)block
{
    // one visible child to the stack
    if (self.contentType != LFSContentTypeMessage) {
        return;
    }
    
    NSMutableArray *stack = [[NSMutableArray alloc] init];
    __block NSUInteger visibleNodeCount = self.visibility == LFSContentVisibilityEveryone ? 1u : 0u;
    [self.childContent enumerateObjectsWithOptions:NSEnumerationReverse
                                   usingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         // order does not matter here as all immediate children are on the
         // same level in the tree
         visibleNodeCount += addVisibleMessagesToStack(stack, obj);
     }];
    
    self.nodeCount = visibleNodeCount;
    if (visibleNodeCount > 0u) {
        [stack addObject:self];
    }
    
    [stack enumerateObjectsWithOptions:NSEnumerationReverse
                            usingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         block(obj);
     }];
}

#pragma mark - Lifecycle

// designated initializer
-(id)initWithObject:(id)object
{
    // check if object is of appropriate type
    if ([object isKindOfClass:[self class]])
    {
        self = object; // let ARC release self
    }
    else
    {
        self = [super init];
        if (self)
        {
            // initialization stuff here
            [self resetCached];
            _object = object;
            _datePath = nil;
            _parent = nil;
            _children = nil;
            _nodeCount = 0;
            _index = NSNotFound;
        }
    }
    return self;
}

-(id)init
{
    // simply call designated initializer
    self = [self initWithObject:nil];
    return self;
}

-(void)dealloc
{
    [self resetCached];
    _object = nil;
    _datePath = nil;
    _parent = nil;
    _children = nil;
}

-(void)resetCached
{
    // reset all cached properties except _object
    _idString = nil;
    _author = nil;
    
    _content = nil;
    _firstOembed = nil;
    
    _contentTwitterId = nil;
    _contentTwitterUrlString = nil;
    _contentParentId = nil;
    _contentBodyHtml = nil;
    _contentAnnotations = nil;
    _contentAuthorId = nil;
    _contentUpdatedAt = nil;
    _contentCreatedAt = nil;
    _childContent = nil;
    _eventId = nil;
    
    _lastVisIsSet = NO;
    _visibilityIsSet = NO;
    _contentSourceIsSet = NO;
    _contentTypeIsSet = NO;
    _authorIsModeratorIsSet = NO;
}

@end
