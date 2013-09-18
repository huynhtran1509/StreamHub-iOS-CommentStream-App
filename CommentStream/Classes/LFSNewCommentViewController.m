//
//  LFSNewCommentViewController.m
//  CommentStream
//
//  Created by Eugene Scherba on 9/13/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import <StreamHub-iOS-SDK/LFSWriteClient.h>
#import "LFSNewCommentViewController.h"

static NSString* const kFailureMessageTitle = @"U fail @ internetz";

@interface LFSNewCommentViewController ()

// render iOS7 status bar methods as writable properties
@property (nonatomic, assign) BOOL prefersStatusBarHidden;
@property (nonatomic, assign) UIStatusBarAnimation preferredStatusBarUpdateAnimation;

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (nonatomic, readonly) LFSWriteClient *writeClient;

- (IBAction)cancelClicked:(UIBarButtonItem *)sender;
- (IBAction)postClicked:(UIBarButtonItem *)sender;

@end

@implementation LFSNewCommentViewController

#pragma mark - Properties

// render iOS7 status bar methods as writable properties
@synthesize prefersStatusBarHidden = _prefersStatusBarHidden;
@synthesize preferredStatusBarUpdateAnimation = _preferredStatusBarUpdateAnimation;

@synthesize writeClient = _writeClient;
@synthesize collection = _collection;
@synthesize collectionId = _collectionId;

- (LFSWriteClient*)writeClient
{
    if (_writeClient == nil) {
        _writeClient = [LFSWriteClient
                        clientWithNetwork:[self.collection objectForKey:@"network"]
                        environment:[self.collection objectForKey:@"environment"]];
    }
    return _writeClient;
}


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
    
    _writeClient = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // hide status bar for iOS7 and later
    [self setStatusBarHidden:LFS_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(LFSSystemVersion70)
               withAnimation:UIStatusBarAnimationNone];
    
    // show keyboard (doing this in viewDidAppear causes unnecessary lag)
    [self.textView becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    _writeClient = nil;
}

#pragma mark - Status bar

-(void)setStatusBarHidden:(BOOL)hidden
            withAnimation:(UIStatusBarAnimation)animation
{
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)])
    {
        // iOS 7
        _prefersStatusBarHidden = hidden;
        _preferredStatusBarUpdateAnimation = animation;
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
    else
    {
        // iOS 6
        [[UIApplication sharedApplication] setStatusBarHidden:hidden
                                                withAnimation:animation];
        if (self.navigationController) {
            UINavigationBar *navigationBar = self.navigationController.navigationBar;
            if (hidden && navigationBar.frame.origin.y > 0.f)
            {
                CGRect frame = navigationBar.frame;
                frame.origin.y = 0;
                navigationBar.frame = frame;
            }
            else if (!hidden && navigationBar.frame.origin.y < 20.f)
            {
                CGRect frame = navigationBar.frame;
                frame.origin.y = 20.f;
                navigationBar.frame = frame;
            }
        }
    }
}

#pragma mark - Actions
- (IBAction)cancelClicked:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)postClicked:(UIBarButtonItem *)sender
{
    NSString *text = self.textView.text;
    [self.textView setText:@""];
    [self.writeClient postNewContent:text
                             forUser:[self.collection objectForKey:@"lftoken"]
                       forCollection:self.collectionId
                           inReplyTo:nil
                           onSuccess:^(NSOperation *operation, id responseObject)
     {
         // do nothing
         //NSLog(@"Success posting: %@", text);
     }
                           onFailure:^(NSOperation *operation, NSError *error)
     {
         // show an error message
         UIAlertView *alert = [[UIAlertView alloc]
                               initWithTitle:kFailureMessageTitle
                               message:[error localizedDescription]
                               delegate:nil
                               cancelButtonTitle:@"OK"
                               otherButtonTitles:nil];
         [alert show];
         
     }];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
