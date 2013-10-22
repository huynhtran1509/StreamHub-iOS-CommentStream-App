//
//  LFSAttributedLabelDelegate.m
//  CommentStream
//
//  Created by Eugene Scherba on 10/21/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import "LFSAttributedLabelDelegate.h"
#import "LFSAppDelegate.h"

@implementation LFSAttributedLabelDelegate

#pragma mark - Properties
@synthesize webViewController = _webViewController;
@synthesize navigationController = _navigationController;

-(UIViewController*)webViewController
{
    if (_webViewController == nil) {
        _webViewController = [[UIViewController alloc] init];
        UIWebView *webView = [[UIWebView alloc] init];
        [webView setDelegate:self];
        [_webViewController setView:webView];
    }
    return _webViewController;
}

#pragma mark - Lifecycle
-(id)init {
    self = [super init];
    if (self) {
        _webViewController = nil;
        _navigationController = nil;
    }
    return self;
}

#pragma mark - Public methods
-(void)followURL:(NSURL*)url
{
    if (![AppDelegate openInTwitterApp:[url absoluteString]]) {
        [(UIWebView*)self.webViewController.view loadRequest:[NSURLRequest requestWithURL:url]];
        [self.navigationController pushViewController:self.webViewController animated:YES];
    }
}

#pragma mark - OHAttributedLabelDelegate
-(BOOL)attributedLabel:(OHAttributedLabel*)attributedLabel
      shouldFollowLink:(NSTextCheckingResult*)linkInfo
{
    [self followURL:linkInfo.URL];
    return NO;
}

-(UIColor*)attributedLabel:(OHAttributedLabel*)attributedLabel
              colorForLink:(NSTextCheckingResult*)linkInfo
            underlineStyle:(int32_t*)underlineStyle
{
    static NSString* const kTwitterSearchPrefix = @"https://twitter.com/#!/search/realtime/";
    NSString *linkString = [linkInfo.URL absoluteString];
    if ([linkString hasPrefix:kTwitterSearchPrefix])
    {
        // Twitter hashtag
        return [UIColor grayColor];
    }
    else
    {
        // regular link
        return [UIColor blueColor];
    }
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

@end
