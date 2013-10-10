//
//  LFSNewCommentViewController.m
//  CommentStream
//
//  Created by Eugene Scherba on 9/13/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import <StreamHub-iOS-SDK/LFSWriteClient.h>
#import "LFSPostViewController.h"

@interface LFSPostViewController ()

// render iOS7 status bar methods as writable properties
@property (nonatomic, assign) BOOL prefersStatusBarHidden;
@property (nonatomic, assign) UIStatusBarAnimation preferredStatusBarUpdateAnimation;

@property (nonatomic, readonly) LFSWriteClient *writeClient;

@property (weak, nonatomic) IBOutlet UINavigationBar *postNavbar;
@property (weak, nonatomic) IBOutlet UITextView *textView;

- (IBAction)cancelClicked:(UIBarButtonItem *)sender;
- (IBAction)postClicked:(UIBarButtonItem *)sender;

@end

@implementation LFSPostViewController

#pragma mark - Properties

@synthesize delegate = _delegate;

// render iOS7 status bar methods as writable properties
@synthesize prefersStatusBarHidden = _prefersStatusBarHidden;
@synthesize preferredStatusBarUpdateAnimation = _preferredStatusBarUpdateAnimation;

@synthesize postNavbar = _postNavbar;
@synthesize textView = _textView;

@synthesize writeClient = _writeClient;
@synthesize collection = _collection;
@synthesize collectionId = _collectionId;
@synthesize replyToContent = _replyToContent;

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

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self resetEverything];
    }
    return self;
}

-(void)resetEverything {
    _writeClient = nil;
    _collection = nil;
    _collectionId = nil;
    _replyToContent = nil;
    _delegate = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // hide status bar for iOS7 and later
    [self setStatusBarHidden:LFS_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(LFSSystemVersion70)
               withAnimation:UIStatusBarAnimationNone];
    
    // show keyboard (doing this in viewDidAppear causes unnecessary lag)
    [self.textView becomeFirstResponder];
    
    if (self.replyToContent != nil) {
        [self.postNavbar.topItem setTitle:@"Reply"];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [self resetEverything];
}

#pragma mark - Status bar

-(void)setStatusBarHidden:(BOOL)hidden
            withAnimation:(UIStatusBarAnimation)animation
{
    _prefersStatusBarHidden = hidden;
    _preferredStatusBarUpdateAnimation = animation;
    
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)])
    {
        // iOS 7
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
    static NSString* const kFailurePostTitle = @"Failed to post content";
    
    NSString *userToken = [self.collection objectForKey:@"lftoken"];
    if (userToken != nil) {
        NSString *text = self.textView.text;
        [self.textView setText:@""];
        [self.writeClient postContent:text
                         inCollection:self.collectionId
                            userToken:userToken
                            inReplyTo:self.replyToContent.idString
                            onSuccess:^(NSOperation *operation, id responseObject)
         {
             if ([self.delegate respondsToSelector:@selector(operation:didPostContentWithResponse:)])
             {
                 [self.delegate operation:operation didPostContentWithResponse:responseObject];
             }
         }
                            onFailure:^(NSOperation *operation, NSError *error)
         {
             // show an error message
             UIAlertView *alert = [[UIAlertView alloc]
                                   initWithTitle:kFailurePostTitle
                                   message:[error localizedDescription]
                                   delegate:nil
                                   cancelButtonTitle:@"OK"
                                   otherButtonTitles:nil];
             [alert show];
             
         }];
    } else {
        // userToken is nil -- show an error message
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:kFailurePostTitle
                              message:@"You do not have permission to write to this collection"
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
