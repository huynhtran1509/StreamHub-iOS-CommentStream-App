//
//  LFSTriple.h
//  CommentStream
//
//  Created by Eugene Scherba on 9/30/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import <Foundation/Foundation.h>

// group related info together in this lightweight
// "triple" object
@interface LFSTriple : NSObject

@property (strong, nonatomic) UIImage *iconImage;
@property (copy, nonatomic) NSString *detailString;
@property (copy, nonatomic) NSString *mainString;

-(id)initWithDetailString:(NSString*)urlString
               mainString:(NSString*)displayString
                iconImage:(UIImage*)iconImage;
@end
