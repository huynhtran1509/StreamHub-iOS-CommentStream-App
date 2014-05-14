//
//  LFSResources.m
//  CommentStream
//
//  Created by Eugene Scherba on 5/13/14.
//  Copyright (c) 2014 Livefyre. All rights reserved.
//

#import "LFSViewResources.h"

#define SOURCE_IMAGE_MAP_LENGTH 8u
static const NSString* const kLFSSourceImageMap[SOURCE_IMAGE_MAP_LENGTH] =
{
    /* C99 designated initializer, with other fields set to nil */
    [LFSContentSourceTwitter]   = @"SourceTwitter",
    [LFSContentSourceFacebook]  = @"SourceFacebook",
    [LFSContentSourceRSS]       = @"SourceRSS",
    [LFSContentSourceInstagram] = @"SourceInstagram"
};


id AttributeObjectFromContent(LFSContent* content)
{
    if (content.authorIsModerator) {
        return @"Moderator";
    }
    else if (content.isFeatured) {
        return [UIImage imageNamed:@"Featured"];
    }
    else {
        return @"";
    }
}


UIImage* ImageForContentSource(LFSContentSource contentSource)
{
    assert((NSUInteger)contentSource < SOURCE_IMAGE_MAP_LENGTH);
    const NSString* const imageName = kLFSSourceImageMap[contentSource];
    return [UIImage imageNamed:(NSString*)imageName];
}

UIImage* SmallImageForContentSource(LFSContentSource contentSource)
{
    assert((NSUInteger)contentSource < SOURCE_IMAGE_MAP_LENGTH);
    const NSString* const imageName = kLFSSourceImageMap[contentSource];
    NSString *smallImageName = [imageName stringByAppendingString:@"Small"];
    return [UIImage imageNamed:smallImageName];
}
