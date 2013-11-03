//
//  LFAppDelegate.h
//  CommentStream
//
//  Created by Eugene Scherba on 8/7/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define AppDelegate (LFSAppDelegate *)[[UIApplication sharedApplication] delegate]

@interface LFSAppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) UIStoryboard *mainStoryboard;

-(NSString*)processStreamUrl:(NSString*)urlString;

@end
