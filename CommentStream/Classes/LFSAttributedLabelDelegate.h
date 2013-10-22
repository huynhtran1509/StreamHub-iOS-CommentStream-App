//
//  LFSAttributedLabelDelegate.h
//  CommentStream
//
//  Created by Eugene Scherba on 10/21/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "LFSBasicHTMLLabel.h"

@interface LFSAttributedLabelDelegate : NSObject <OHAttributedLabelDelegate, UIWebViewDelegate>

@property (nonatomic, strong) UIViewController *webViewController;
@property (nonatomic, strong) UINavigationController *navigationController;

@end
