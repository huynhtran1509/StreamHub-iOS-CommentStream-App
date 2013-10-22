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
-(id)initWithIdentifier:(NSString*)identifierString
        attributeString:(NSString*)attributeString
          displayString:(NSString*)displayString
                   icon:(UIImage*)iconImage
{
    self = [super init];
    if (self) {
        _identifier = identifierString;
        _attributeString = attributeString;
        _icon = iconImage;
        _displayString = displayString;
    }
    return self;
}

-(id)initWithIdentifier:(NSString*)identifierString
          displayString:(NSString*)displayString
                   icon:(UIImage*)iconImage
{
    self = [self initWithIdentifier:identifierString
                    attributeString:nil
                      displayString:displayString
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
