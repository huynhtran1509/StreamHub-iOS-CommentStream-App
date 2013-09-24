//
//  LFSContentCollection.h
//  CommentStream
//
//  Created by Eugene Scherba on 9/24/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LFSContent.h"

@interface LFSContentCollection : NSMutableArray

@property (nonatomic, strong) id authors;
-(void)addAuthorsCollection:(id)collection;

@end
