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
#import "LFSPostViewController.h"

@interface LFSCollectionViewController : UITableViewController <UITextFieldDelegate, LFSPostNewControllerDelegate>

@property (nonatomic, copy) NSDictionary *collection;
@property (nonatomic, copy) NSString *collectionId;

@end
