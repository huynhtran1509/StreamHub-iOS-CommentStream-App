//
//  LFSContent.m
//  CommentStream
//
//  Created by Eugene Scherba on 9/24/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import "LFSContent.h"

@implementation LFSContent {
    id _object;
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


// For more info, see
// https://github.com/Livefyre/lfdj/blob/production/lfcore/lfcore/v2/publishing/models.proto

static const NSUInteger kLFSContentSourceDecode[] = {
    LFSContentSourceLivefyre, // 0
    LFSContentSourceTwitter,  // 1
    LFSContentSourceTwitter,  // 2
    LFSContentSourceFacebook, // 3
    LFSContentSourceLivefyre, // 4
    LFSContentSourceLivefyre, // 5
    LFSContentSourceFacebook,  // 6
    LFSContentSourceTwitter,  // 7
    LFSContentSourceLivefyre,  // 8
    LFSContentSourceLivefyre,  // 9
    LFSContentSourceGooglePlus,  // 10
    LFSContentSourceFlickr,  // 11
    LFSContentSourceYouTube,  // 12
    LFSContentSourceRSS,  // 13
    LFSContentSourceFacebook,  // 14
    LFSContentSourceTwitter,  // 15
    LFSContentSourceYouTube,  // 16
    LFSContentSourceLivefyre,  // 17
    LFSContentInstagram,  // 18
};

static NSString* const kLFSSourceImageMap[] = {
    nil, // LFSContentSourceLivefyre (0)
    @"SourceTwitter", //LFSContentSourceTwitter (1)
    @"SourceFacebook", //LFSContentSourceFacebook (2)
    nil, //LFSContentSourceGooglePlus (3)
    nil, //LFSContentSourceFlickr (4)
    nil, //LFSContentSourceYouTube (5)
    @"SourceRSS", //LFSContentSourceRSS (6)
    @"SourceInstagram", //LFSContentInstagram (7)
};

#pragma mark - Properties

@synthesize contentTwitterId = _contentTwitterId;
@synthesize contentTwitterUrlString = _contentTwitterUrlString;

@synthesize content = _content;
@synthesize eventId = _eventId;
@synthesize visibility = _visibility;
@synthesize childContent = _childContent;
@synthesize contentType = _contentType;
@synthesize contentSource = _contentSource;

@synthesize contentParentId = _contentParentId;
@synthesize contentBodyHtml = _contentBodyHtml;
@synthesize contentAnnotations = _contentAnnotations;
@synthesize contentAuthorId = _contentAuthorId;
@synthesize contentCreatedAt = _contentCreatedAt;
@synthesize contentUpdatedAt = _contentUpdatedAt;
@synthesize contentId = _contentId;

@synthesize author = _author;

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
        [regex firstMatchInString:self.contentId
                          options:0
                            range:NSMakeRange(0, [self.contentId length])];
        if (match != nil) {
            _contentTwitterId = [self.contentId substringWithRange:[match rangeAtIndex:1u]];
        }
    }
    return _contentTwitterId;
}

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

-(NSDictionary*)content
{
    const static NSString* const key = @"content";
    if (_content == nil) {
        _content = [_object objectForKey:key];
    }
    return _content;
}

-(NSString*)contentParentId
{
    const static NSString* const key = @"parentId";
    if (_contentParentId == nil) {
        _contentParentId = [self.content objectForKey:key];
    }
    return _contentParentId;
}

-(NSString*)contentBodyHtml
{
    const static NSString* const key = @"bodyHtml";
    if (_contentBodyHtml == nil) {
        _contentBodyHtml = [self.content objectForKey:key];
    }
    return _contentBodyHtml;
}

-(NSDictionary*)contentAnnotations
{
    const static NSString* const key = @"annotations";
    if (_contentAnnotations == nil) {
        _contentAnnotations = [self.content objectForKey:key];
    }
    return _contentAnnotations;
}

-(NSString*)contentAuthorId
{
    const static NSString* const key = @"authorId";
    if (_contentAuthorId == nil) {
        _contentAuthorId = [self.content objectForKey:key];
    }
    return _contentAuthorId;
}

-(NSDate*)contentUpdatedAt
{
    const static NSString* const key = @"updatedAt";
    if (_contentUpdatedAt == nil) {
        _contentUpdatedAt = [NSDate dateWithTimeIntervalSince1970:
                             [[self.content objectForKey:key] doubleValue]];
    }
    return _contentUpdatedAt;
}

-(NSDate*)contentCreatedAt
{
    const static NSString* const key = @"createdAt";
    if (_contentCreatedAt == nil) {
        _contentCreatedAt = [NSDate dateWithTimeIntervalSince1970:
                             [[self.content objectForKey:key] doubleValue]];
    }
    return _contentCreatedAt;
}

-(NSString*)contentId
{
    const static NSString* const key = @"id";
    if (_contentId == nil) {
        _contentId = [self.content objectForKey:key];
    }
    return _contentId;
}

-(LFSContentCollection*)childContent
{
    const static NSString* const key = @"childContent";
    if (_childContent == nil) {
        _childContent = [[LFSContentCollection alloc]
                         initWithArray:[_object objectForKey:key]];
    }
    return _childContent;
}

-(NSNumber*)eventId
{
    const static NSString* const key = @"event";
    if (_eventId == nil) {
        _eventId = [_object objectForKey:key];
    }
    return _eventId;
}

-(LFSContentVisibility)visibility
{
    const static NSString* const key = @"vis";
    if (!_visibilityIsSet) {
        _visibility = [[_object objectForKey:key] unsignedIntegerValue];
        _visibilityIsSet = YES;
    }
    return _visibility;
}

-(LFSContentType)contentType
{
    const static NSString* const key = @"type";
    if (!_contentTypeIsSet) {
        _contentType = [[_object objectForKey:key] unsignedIntegerValue];
        _contentTypeIsSet = YES;
    }
    return _contentType;
}

-(NSUInteger)contentSource
{
    const static NSString* const key = @"source";
    if (!_contentSourceIsSet) {
        _contentSource = [[_object objectForKey:key] unsignedIntegerValue];
        _contentSourceIsSet = YES;
    }
    return _contentSource;
}

-(UIImage*)contentSourceIcon
{
    NSUInteger rawContentSource = self.contentSource;
    if (rawContentSource <= 18u) {
        LFSContentSource contentSource = kLFSContentSourceDecode[rawContentSource];
        return [self imageForContentSource:contentSource];
    } else {
        return nil;
    }
}

-(UIImage*)contentSourceIconSmall
{
    NSUInteger rawContentSource = self.contentSource;
    if (rawContentSource <= 18u) {
        LFSContentSource contentSource = kLFSContentSourceDecode[rawContentSource];
        return [self smallImageForContentSource:contentSource];
    } else {
        return nil;
    }
}


#pragma mark - Private methods

-(UIImage*)imageForContentSource:(LFSContentSource)contentSource
{
    // do a simple range check for memory safety
    if (contentSource <= LFSContentInstagram) {
        NSString* const imageName = kLFSSourceImageMap[contentSource];
        return [UIImage imageNamed:imageName];
    } else {
        return nil;
    }
}

-(UIImage*)smallImageForContentSource:(LFSContentSource)contentSource
{
    // do a simple range check for memory safety
    if (contentSource <= LFSContentInstagram) {
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

#pragma mark - Lifecycle

// designated initializer
-(id)initWithObject:(id)object
{
    self = [super init];
    if (self ) {
        // initialization stuff here
        _object = object;

        _contentTwitterId = nil;
        _contentTwitterUrlString = nil;
        
        _author = nil;
        
        _visibilityIsSet = NO;
        _contentTypeIsSet = NO;
        _contentSourceIsSet = NO;
        
        _content = nil;
        _eventId = nil;
        _childContent = nil;
        
        _contentParentId = nil;
        _contentBodyHtml = nil;
        _contentAnnotations = nil;
        _contentAuthorId = nil;
        _contentCreatedAt = nil;
        _contentUpdatedAt = nil;
        _contentId = nil;
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
    _object = nil;
    
    _contentTwitterId = nil;
    _contentTwitterUrlString = nil;
    
    _author = nil;
    
    _content = nil;
    _eventId = nil;
    _childContent = nil;
    
    _contentParentId = nil;
    _contentBodyHtml = nil;
    _contentAnnotations = nil;
    _contentAuthorId = nil;
    _contentCreatedAt = nil;
    _contentUpdatedAt = nil;
    _contentId = nil;
}

@end
