//
//  LFSDetailViewController.m
//  CommentStream
//
//  Created by Eugene Scherba on 9/13/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import <DTCoreText/DTCoreText.h>
#import "LFSDetailViewController.h"
#import "LFSAttributedTextView.h"

@interface LFSDetailViewController ()

// render iOS7 status bar methods as writable properties
@property (nonatomic, assign) BOOL prefersStatusBarHidden;
@property (nonatomic, assign) UIStatusBarAnimation preferredStatusBarUpdateAnimation;
@property (weak, nonatomic) IBOutlet LFSAttributedTextView *attributedTextView;
@end

@implementation LFSDetailViewController {
    NSUInteger _htmlHash; // preserved hash to avoid relayouting for same HTML
}

#pragma mark - Properties

@synthesize attributedTextView = _attributedTextView;

// render iOS7 status bar methods as writable properties
@synthesize prefersStatusBarHidden = _prefersStatusBarHidden;
@synthesize preferredStatusBarUpdateAnimation = _preferredStatusBarUpdateAnimation;

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
    
    //[self.contentView setAttributedString:@"reere"];
    NSString *bodyHTML = [self.contentItem objectForKey:@"bodyHtml"];
    NSString *html = [NSString stringWithFormat:@"<div style=\"font-family:Avenir; font-size:18pt;\">%@</div>", bodyHTML];
    [self setHTMLString:html];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    //[self.navigationController setToolbarHidden:YES animated:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Methods
- (void)setHTMLString:(NSString *)html
{
	// we don't preserve the html but compare it's hash
	NSUInteger newHash = [html hash];
	
	if (newHash == _htmlHash)
	{
		return;
	}
	
	_htmlHash = newHash;
	
	NSData *data = [html dataUsingEncoding:NSUTF8StringEncoding];
	NSAttributedString *string = [[NSAttributedString alloc] initWithHTMLData:data documentAttributes:NULL];
	self.attributedString = string;
	
	//[self setNeedsLayout];
}


- (void)setAttributedString:(NSAttributedString *)attributedString
{
	// passthrough
	self.attributedTextView.attributedString = attributedString;
}

- (NSAttributedString *)attributedString
{
	// passthrough
	return _attributedTextView.attributedString;
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
            if (hidden && navigationBar.frame.origin.y > 0.f) {
                CGRect frame = navigationBar.frame;
                frame.origin.y = 0;
                navigationBar.frame = frame;
            } else if (!hidden && navigationBar.frame.origin.y < 20.f) {
                CGRect frame = navigationBar.frame;
                frame.origin.y = 20.f;
                navigationBar.frame = frame;
            }
        }
    }
}


@end
