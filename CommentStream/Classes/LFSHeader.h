//
//  LFSHeader.h
//  CommentStream
//
//  Created by Eugene Scherba on 9/30/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import <Foundation/Foundation.h>

// group related info together
@interface LFSHeader : NSObject

@property (strong, nonatomic) UIImage *iconImage;
@property (copy, nonatomic) NSString *attributeString;
@property (copy, nonatomic) NSString *mainString;
@property (copy, nonatomic) NSString *detailString;

-(id)initWithDetailString:(NSString*)detailString
          attributeString:(NSString*)attributeString
               mainString:(NSString*)mainString
                iconImage:(UIImage*)iconImage;
@end
