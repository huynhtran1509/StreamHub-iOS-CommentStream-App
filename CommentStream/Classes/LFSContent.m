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

#pragma mark - Properties

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

/*
 @property (nonatomic, strong) NSString *contentParentId;
 @property (nonatomic, strong) NSString *contentBodyHTML;
 @property (nonatomic, strong) NSDictionary *contentAnnotations;
 @property (nonatomic, strong) NSString *contentAuthorId;
 @property (nonatomic, strong) NSDate *contentUpdatedAt;
 @property (nonatomic, strong) NSDate *contentCreatedAt;
 @property (nonatomic, strong) NSString *contentId;

 */


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


#pragma mark - Lifecycle
-(id)initWithObject:(id)object
{
    self = [super init];
    if (self ) {
        // initialization stuff here
        _object = object;
        _visibilityIsSet = NO;
        _contentTypeIsSet = NO;
        _contentSourceIsSet = NO;
    }
    return self;
}

-(id)init
{
    // simply call designated initializer
    self = [self initWithObject:nil];
    if (self) {
        // initialize stuff here
    }
    return self;
}

-(void)dealloc
{
    _object = nil;
}

@end
