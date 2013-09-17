//
//  LFSCollectionViewController.h
//  CommentStream
//
//  Created by Eugene Scherba on 8/7/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "LFSDetailViewController.h"
#import "LFSNewCommentViewController.h"

@interface LFSCollectionViewController : UITableViewController <UITextFieldDelegate>

@property (nonatomic, strong) NSDictionary *collection;
@property (nonatomic, strong) NSString *collectionId;

@end
