//
//  UIImagePickerController+StatusBarHidden.m
//  CommentStream
//
//  Created by Eugene Scherba on 5/28/14.
//  Copyright (c) 2014 Livefyre. All rights reserved.
//

#import "UIImagePickerController+StatusBarHidden.h"

@implementation UIImagePickerController (StatusBarHidden)

- (BOOL)prefersStatusBarHidden {
    return self.sourceType == UIImagePickerControllerSourceTypeCamera;
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    return nil;
}

@end
