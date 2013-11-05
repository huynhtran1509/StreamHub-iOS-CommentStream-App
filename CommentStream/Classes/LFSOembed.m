//
//  LFSOembed.m
//  CommentStream
//
//  Created by Eugene Scherba on 10/27/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import "LFSModelMacros.h"
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

#pragma mark - Lazy autho-synthesized properties
@synthLazyWithNull(NSString, providerName, _object, @"provider_name");
@synthLazyWithNull(NSString, providerUrlString, _object, @"provider_url");
@synthLazyWithNull(NSString, title, _object, @"title");
@synthLazyWithNull(NSString, linkUrlString, _object, @"link");
@synthLazyWithNull(NSString, authorName, _object, @"author_name");
@synthLazyWithNull(NSString, authorUrlString, _object, @"author_url");
@synthLazyWithNull(NSString, urlSring, _object, @"url");
@synthLazyWithNull(NSString, version, _object, @"version");


#pragma mark -
@synthesize thumbnailUrlString = _thumbnailUrlString;
-(NSString*)thumbnailUrlString
{
    const static NSString* const key = @"thumbnail_url";
    if (_thumbnailUrlString == nil) {
        _thumbnailUrlString = [_object objectForKey:key];
        // return full-size image URL if thumbnail URL is missing
        if (_thumbnailUrlString == nil) {
            _thumbnailUrlString = self.urlSring;
        }
    }
    if (_thumbnailUrlString == (NSString*)[NSNull null]) {
        // return full-size image URL if thumbnail URL is missing
        return self.urlSring;
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
        _thumbnailSize = CGSizeMake([[_object objectForKey:kWidthKey] floatValue] / 2.f,
                                    [[_object objectForKey:kHeightKey] floatValue] / 2.f);
    }
    return _thumbnailSize;
}

#pragma mark -
@synthesize size = _size;
-(CGSize)size
{
    const static NSString* const kWidthKey = @"width";
    const static NSString* const kHeightKey = @"height";
    if (_sizeIsSet == NO) {
        _size = CGSizeMake([[_object objectForKey:kWidthKey] floatValue] / 2.f,
                           [[_object objectForKey:kHeightKey] floatValue] / 2.f);
    }
    return _size;
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

@end
