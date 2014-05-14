//
//  LFSResources.h
//  CommentStream
//
//  Created by Eugene Scherba on 5/13/14.
//  Copyright (c) 2014 Livefyre. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <StreamHub-iOS-SDK/LFSConstants.h>

#import "LFSContent.h"

UIImage* ImageForContentSource(LFSContentSource contentSource);
UIImage* SmallImageForContentSource(LFSContentSource contentSource);

id AttributeObjectFromContent(LFSContent* content);