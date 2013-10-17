//
//  LFSHeader.m
//  CommentStream
//
//  Created by Eugene Scherba on 9/30/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import "LFSResource.h"

@implementation LFSResource

@synthesize attributeString = _attributeString;
@synthesize identifier = _identifier;
@synthesize icon = _icon;
@synthesize displayString = _displayString;
@synthesize iconURLString = _iconURLString;

// designated initializer
-(id)initWithIdentifier:(NSString*)detailString
        attributeString:(NSString*)attributeString
          displayString:(NSString*)mainString
                   icon:(UIImage*)iconImage
{
    self = [super init];
    if (self) {
        _identifier = detailString;
        _attributeString = attributeString;
        _icon = iconImage;
        _displayString = mainString;
    }
    return self;
}

-(id)initWithIdentifier:(NSString*)detailString
          displayString:(NSString*)mainString
                   icon:(UIImage*)iconImage
{
    self = [self initWithIdentifier:detailString
                    attributeString:nil
                      displayString:mainString
                               icon:iconImage];
    return self;
}

-(id)init
{
    self = [self initWithIdentifier:nil
                    attributeString:nil
                      displayString:nil
                               icon:nil];
    return self;
}
@end
