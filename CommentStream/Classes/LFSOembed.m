//
//  LFSOembed.m
//  CommentStream
//
//  Created by Eugene Scherba on 10/27/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import "LFSOembed.h"

const NSString *const LFSOembedTypes[LFS_OEMBED_TYPES_LENGTH] =
{
    @"photo",
    @"video",
    @"link",
    @"rich"
};

@implementation LFSOembed {
    BOOL _sizeIsSet;
    BOOL _thumbnailSizeIsSet;
    BOOL _attachmentTypeIsSet;
}

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
}

-(void)resetCached
{
    // reset all cached properties except _object
    _providerName = nil;
    _providerUrlString = nil;
    
    _title = nil;
    _linkUrlString = nil;
    
    _thumbnailUrlString = nil;
    _urlSring = nil;
    
    _authorName = nil;
    _authorUrlString = nil;
    
    _version = nil;
}


@synthesize object = _object;

#pragma mark -
@synthesize providerName = _providerName;
-(NSString*)providerName
{
    const static NSString* const key = @"provider_name";
    if (_providerName == nil) {
        _providerName = [_object objectForKey:key];
    }
    return _providerName;
}

#pragma mark -
@synthesize providerUrlString = _providerUrlString;
-(NSString*)providerUrlString
{
    const static NSString* const key = @"provider_url";
    if (_providerUrlString == nil) {
        _providerUrlString = [_object objectForKey:key];
        if (_providerUrlString == (NSString*)[NSNull null]) {
            _providerUrlString = nil;
        }
    }
    return _providerUrlString;
}

#pragma mark -
@synthesize title = _title;
-(NSString*)title
{
    const static NSString* const key = @"title";
    if (_title == nil) {
        _title = [_object objectForKey:key];
    }
    return _title;
}

#pragma mark -
@synthesize linkUrlString = _linkUrlString;
-(NSString*)linkUrlString
{
    const static NSString* const key = @"link";
    if (_linkUrlString == nil) {
        _linkUrlString = [_object objectForKey:key];
        if (_linkUrlString == (NSString*)[NSNull null]) {
            _linkUrlString = nil;
        }
    }
    return _linkUrlString;
}

#pragma mark -
@synthesize thumbnailUrlString = _thumbnailUrlString;
-(NSString*)thumbnailUrlString
{
    const static NSString* const key = @"thumbnail_url";
    if (_thumbnailUrlString == nil) {
        _thumbnailUrlString = [_object objectForKey:key];
        if (_thumbnailUrlString == (NSString*)[NSNull null]) {
            _thumbnailUrlString = nil;
        }
    }
    return _thumbnailUrlString;
}

#pragma mark -
@synthesize thumbnailSize = _thumbnailSize;
-(CGSize)thumbnailSize
{
    const static NSString* const kWidthKey = @"thumbnail_width";
    const static NSString* const kHeightKey = @"thumbnail_height";
    if (_thumbnailSizeIsSet == NO) {
        _thumbnailSize = CGSizeMake([[_object objectForKey:kWidthKey] floatValue],
                                    [[_object objectForKey:kHeightKey] floatValue]);
    }
    return _thumbnailSize;
}

#pragma mark -
@synthesize urlSring = _urlSring;
-(NSString*)urlSring
{
    const static NSString* const key = @"url";
    if (_urlSring == nil) {
        _urlSring = [_object objectForKey:key];
        if (_urlSring == (NSString*)[NSNull null]) {
            _urlSring = nil;
        }
    }
    return _urlSring;
}

#pragma mark -
@synthesize size = _size;
-(CGSize)size
{
    const static NSString* const kWidthKey = @"width";
    const static NSString* const kHeightKey = @"height";
    if (_sizeIsSet == NO) {
        _size = CGSizeMake([[_object objectForKey:kWidthKey] floatValue],
                           [[_object objectForKey:kHeightKey] floatValue]);
    }
    return _size;
}

#pragma mark -
@synthesize authorName = _authorName;
-(NSString*)authorName
{
    const static NSString* const key = @"author_name";
    if (_authorName == nil) {
        _authorName = [_object objectForKey:key];
    }
    return _authorName;
}

#pragma mark -
@synthesize authorUrlString = _authorUrlString;
-(NSString*)authorUrlString
{
    const static NSString* const key = @"author_url";
    if (_authorUrlString == nil) {
        _authorUrlString = [_object objectForKey:key];
        if (_authorUrlString == (NSString*)[NSNull null]) {
            _authorUrlString = nil;
        }
    }
    return _authorUrlString;
}

#pragma mark -
@synthesize oembedType = _attachmentType;
-(LFSOembedType)oembedType
{
    static NSDictionary *translate = nil;
    if (translate == nil) {
        translate = @{
                      @"photo" : @0,
                      @"video" : @1,
                      @"link"  : @2,
                      @"rich"  : @3
                      };
    }
    const static NSString* const key = @"type";
    if (_attachmentTypeIsSet == NO) {
        NSString *typeString = [_object objectForKey:key];
        NSNumber *tmp = [translate objectForKey:typeString];
        _attachmentType = (tmp == nil
                           ? LFSOembedTypeUnknown
                           : (LFSOembedType)[tmp unsignedIntegerValue]);
    }
    return _attachmentType;
}

#pragma mark - 
@synthesize version = _version;
-(NSString*)version
{
    const static NSString* const key = @"version";
    if (_version == nil) {
        _version = [_object objectForKey:key];
    }
    return _version;
}

@end
