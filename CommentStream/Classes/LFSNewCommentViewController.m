//
//  LFSNewCommentViewController.m
//  CommentStream
//
//  Created by Eugene Scherba on 9/13/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import "LFSNewCommentViewController.h"

@interface LFSNewCommentViewController ()

@end

@implementation LFSNewCommentViewController

#pragma mark - Properties


#pragma mark - UIViewController

// Hide Status Bar
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self hideStatusBar];
    //[self.navigationController setToolbarHidden:YES animated:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Methods

-(void)hideStatusBar
{
    // Hide Status Bar
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        // iOS 7
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    } else {
        // iOS 6
        [[UIApplication sharedApplication] setStatusBarHidden:YES
                                                withAnimation:UIStatusBarAnimationSlide];
    }
}


@end
