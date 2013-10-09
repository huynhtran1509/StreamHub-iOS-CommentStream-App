//
//  LFSContent.m
//  CommentStream
//
//  Created by Eugene Scherba on 9/24/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import "LFSContent.h"

@implementation LFSContent {
    BOOL _visibilityIsSet;
    BOOL _contentTypeIsSet;
    BOOL _contentSourceIsSet;
}

/* Sample content:
 {
 childContent: [ ],
 vis: 1,
 content: {
 parentId: "",
 bodyHtml: "Can anyone tell me what Vila Velha in Brazil is like? <a href="https://twitter.com/#!/search/realtime/%23WorldCup" class="fyre-hashtag" hashtag="WorldCup" rel="tag" target="_blank">#WorldCup</a> <a href="https://twitter.com/#!/search/realtime/%23carnival" class="fyre-hashtag" hashtag="carnival" rel="tag" target="_blank">#carnival</a>",
 annotations: { },
 authorId: "391303630@twitter.com",
 updatedAt: 1374902038,
 id: "tweet-360991428312186880@twitter.com",
 createdAt: 1374902038
 },
 source: 1,
 type: 0,
 event: 1374902038279948
 }
 */


// For detailed info, see
// https://github.com/Livefyre/lfdj/blob/production/lfcore/lfcore/v2/publishing/models.proto
typedef NS_ENUM(NSUInteger, LFSContentSource) {
    LFSContentSourceDefault = 0u,
    LFSContentSourceTwitter,
    LFSContentSourceFacebook,
    LFSContentSourceGooglePlus,
    LFSContentSourceFlickr,
    LFSContentSourceYouTube,
    LFSContentSourceRSS,
    LFSContentSourceInstagram
};

#define CONTENT_SOURCE_DECODE_LENGTH 20u

static const NSUInteger kLFSContentSourceDecode[CONTENT_SOURCE_DECODE_LENGTH] =
{
    LFSContentSourceDefault, // 0
    LFSContentSourceTwitter,  // 1
    LFSContentSourceTwitter,  // 2
    LFSContentSourceFacebook, // 3
    LFSContentSourceDefault, // 4
    LFSContentSourceDefault, // 5
    LFSContentSourceFacebook,  // 6
    LFSContentSourceTwitter,  // 7
    LFSContentSourceDefault,  // 8
    LFSContentSourceDefault,  // 9
    LFSContentSourceGooglePlus,  // 10
    LFSContentSourceFlickr,  // 11
    LFSContentSourceYouTube,  // 12
    LFSContentSourceRSS,  // 13
    LFSContentSourceFacebook,  // 14
    LFSContentSourceTwitter,  // 15
    LFSContentSourceYouTube,  // 16
    LFSContentSourceDefault,  // 17
    LFSContentSourceDefault,  // 18
    LFSContentSourceInstagram,  // 19
};

static NSString* const kLFSSourceImageMap[] = {
    nil, // LFSContentSourceDefault (0)
    @"SourceTwitter", //LFSContentSourceTwitter (1)
    @"SourceFacebook", //LFSContentSourceFacebook (2)
    nil, //LFSContentSourceGooglePlus (3)
    nil, //LFSContentSourceFlickr (4)
    nil, //LFSContentSourceYouTube (5)
    @"SourceRSS", //LFSContentSourceRSS (6)
    @"SourceInstagram", //LFSContentSourceInstagram (7)
};

#pragma mark - Properties

@synthesize object = _object;
-(void)setObject:(id)object
{
    if (_object != nil && _object != object) {
        id newObject = [[self.class alloc] initWithObject:object];
        NSString *newId = [newObject idString];
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

#pragma mark -
@synthesize author = _author;

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
@synthesize content = _content;
-(NSDictionary*)content
{
    const static NSString* const key = @"content";
    if (_content == nil) {
        _content = [_object objectForKey:key];
    }
    return _content;
}

#pragma mark -
@synthesize idString = _idString;
-(NSString*)idString
{
    const static NSString* const key = @"id";
    if (_idString == nil) {
        _idString = [self.content objectForKey:key];
    }
    return _idString;
}

#pragma mark -
@synthesize contentTwitterId = _contentTwitterId;
-(NSString*)contentTwitterId
{
    // try to extract twitter id from contentId --
    // if we fail, return nil
    static NSRegularExpression *regex = nil;
    if (_contentTwitterId == nil) {
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
        [regex firstMatchInString:self.idString
                          options:0
                            range:NSMakeRange(0, [self.idString length])];
        if (match != nil) {
            _contentTwitterId = [self.idString substringWithRange:[match rangeAtIndex:1u]];
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
            _contentTwitterUrlString = [NSString
                                        stringWithFormat:@"https://twitter.com/%@/status/%@",
                                        twitterHandle, twitterId];
        }
    }
    return _contentTwitterUrlString;
}

#pragma mark -
@synthesize contentParentId = _contentParentId;
-(NSString*)contentParentId
{
    const static NSString* const key = @"parentId";
    if (_contentParentId == nil) {
        _contentParentId = [self.content objectForKey:key];
    }
    return _contentParentId;
}

#pragma mark -
@synthesize contentBodyHtml = _contentBodyHtml;
-(NSString*)contentBodyHtml
{
    const static NSString* const key = @"bodyHtml";
    if (_contentBodyHtml == nil) {
        _contentBodyHtml = [self.content objectForKey:key];
    }
    return _contentBodyHtml;
}

#pragma mark -
@synthesize contentAnnotations = _contentAnnotations;
-(NSDictionary*)contentAnnotations
{
    const static NSString* const key = @"annotations";
    if (_contentAnnotations == nil) {
        _contentAnnotations = [self.content objectForKey:key];
    }
    return _contentAnnotations;
}

#pragma mark -
@synthesize contentAuthorId = _contentAuthorId;
-(NSString*)contentAuthorId
{
    const static NSString* const key = @"authorId";
    if (_contentAuthorId == nil) {
        _contentAuthorId = [self.content objectForKey:key];
    }
    return _contentAuthorId;
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
@synthesize childContent = _childContent;
-(id)childContent
{
    const static NSString* const key = @"childContent";
    if (_childContent == nil) {
        _childContent = [_object objectForKey:key];
    }
    return _childContent;
}

#pragma mark -
@synthesize eventId = _eventId;
-(NSNumber*)eventId
{
    const static NSString* const key = @"event";
    if (_eventId == nil) {
        _eventId = [_object objectForKey:key];
    }
    return _eventId;
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
}

-(void)resetCached
{
    // reset all cached properties except _object
    _author = nil;
    
    _content = nil;
    
    _idString = nil;
    
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
    
    _visibility = LFSContentVisibilityNone;
    _contentType = LFSContentTypeMessage;
    _contentSource = 0u;
    
    _visibilityIsSet = NO;
    _contentSourceIsSet = NO;
    _contentTypeIsSet = NO;
}

@end