//
//  LFSDetailViewController.h
//  CommentStream
//
//  Created by Eugene Scherba on 9/13/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "LFSBasicHTMLLabel.h"
#import "LFSAuthor.h"
#import "LFSContent.h"

@interface LFSDetailViewController : UIViewController <OHAttributedLabelDelegate>

@property (nonatomic, strong) NSDictionary *collection;
@property (nonatomic, strong) NSString *collectionId;

@property (nonatomic, strong) LFSAuthor *authorItem;
@property (nonatomic, strong) LFSContent *contentItem;

-(void)setAvatarImage:(UIImage*)image;

@end
