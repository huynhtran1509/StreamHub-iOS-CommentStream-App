//
//  LFSDetailViewController.h
//  CommentStream
//
//  Created by Eugene Scherba on 9/13/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LFSDetailViewController : UIViewController

@property (nonatomic, strong) NSDictionary *collection;
@property (nonatomic, strong) NSString *collectionId;

@property (nonatomic, strong) NSDictionary *authorItem;
@property (nonatomic, strong) NSDictionary *contentItem;

@end
