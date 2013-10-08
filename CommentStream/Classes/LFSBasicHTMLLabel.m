//
//  LFSBasicHTMLLabel.m
//  CommentStream
//
//  Created by Eugene Scherba on 9/20/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import "LFSBasicHTMLLabel.h"
#import "LFSBasicHTMLParser.h"

typedef NS_ENUM(NSUInteger, kTwitterAppState) {
    kTwitterAppStateUnknown = 0u,
    kTwitterAppStateTwitter,
    kTwitterAppStateBrowser
};
static kTwitterAppState twitterState = kTwitterAppStateUnknown;


@interface LFSBasicHTMLLabel ()
@property (nonatomic, strong) NSMutableParagraphStyle *paragraphStyle;
@end

@implementation LFSBasicHTMLLabel

#pragma mark - Properties
@synthesize font = _font;
@synthesize paragraphStyle = _paragraphStyle;

-(CGFloat)lineSpacing
{
    return [self.paragraphStyle lineSpacing];
}

-(BOOL)canOpenLinksInTwitterClient {
    if (twitterState == kTwitterAppStateUnknown) {
        NSURL *twitterUrl = [NSURL URLWithString:@"twitter://"];
        twitterState = ([[UIApplication sharedApplication] canOpenURL:twitterUrl]
                        ? kTwitterAppStateTwitter
                        : kTwitterAppStateBrowser);
    }
    return (twitterState == kTwitterAppStateTwitter);
}

-(void)setLineSpacing:(CGFloat)points
{
    [self.paragraphStyle setLineSpacing:points];
}

-(NSTextAlignment)textAlignment
{
    return [self.paragraphStyle alignment];
}

-(void)setTextAlignment:(NSTextAlignment)textAlignment
{
    [self.paragraphStyle setAlignment:textAlignment];
}

- (void)setHTMLString:(NSString *)html
{
    if (html == nil) {
        return;
    }
    
    NSMutableAttributedString *attributedText =
    [LFSBasicHTMLParser attributedStringByProcessingMarkupInString:html];
    
    if (self.font) {
        [attributedText setFont:self.font];
    }
    
    if (self.paragraphStyle) {
        [attributedText addAttribute:NSParagraphStyleAttributeName
                               value:self.paragraphStyle
                               range:NSMakeRange(0, [attributedText length])];
    }
    
    [self setAttributedText:attributedText];
}

-(NSMutableParagraphStyle*)paragraphStyle {
    if (_paragraphStyle == nil) {
        _paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    }
    return _paragraphStyle;
}

#pragma mark - Lifestyle
-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _font = nil;
        _paragraphStyle = nil;
        
        self.delegate = self;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _font = nil;
        _paragraphStyle = nil;
        
        self.delegate = self;
    }
    return self;
}

-(void)dealloc
{
    _font = nil;
    _paragraphStyle = nil;
}

#pragma mark - OHAttributedLabelDelegate
-(BOOL)attributedLabel:(OHAttributedLabel*)attributedLabel
      shouldFollowLink:(NSTextCheckingResult*)linkInfo
{
    static NSRegularExpression* regexHashtag = nil;
    static NSRegularExpression* regexHandle = nil;
    static NSRegularExpression* regexStatus = nil;
    
    NSString *urlString = [linkInfo.URL absoluteString];
    
    // check if linkInfo.URL is a hashtag
    if (regexHashtag == nil) {
        NSError *error = nil;
        regexHashtag = [NSRegularExpression
                        regularExpressionWithPattern:@"^(http|https)://twitter.com/(#!/)?search/realtime/([^/]*?)$"
                        options:0 error:&error];
        NSAssert(error == nil, @"Error creating regex: %@",
                 error.localizedDescription);
    }
    NSTextCheckingResult *hashtagMatch =
    [regexHashtag firstMatchInString:urlString
                             options:0
                               range:NSMakeRange(0, [urlString length])];
    if (hashtagMatch != nil) {
        // have match, now create Twitter URI, open Twitter app here, and return
        NSString *schemaString = [urlString substringWithRange:[hashtagMatch rangeAtIndex:1u]];
        NSString *contentString = [urlString substringWithRange:[hashtagMatch rangeAtIndex:3u]];
        NSString *convertedURL = ([self canOpenLinksInTwitterClient]
                                  ? [NSString stringWithFormat:@"twitter://search?query=%@", contentString]
                                  : [NSString stringWithFormat:@"%@://twitter.com/search/realtime/%@",
                                     schemaString, contentString]);
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:convertedURL]];
        return NO;
    }
    
    // if we are still here, look for possible user handle
    if (regexHandle == nil) {
        NSError *error = nil;
        regexHandle = [NSRegularExpression
                       regularExpressionWithPattern:@"^(http|https)://twitter.com/(#!/)?([^/]*?)$"
                       options:0 error:&error];
        NSAssert(error == nil, @"Error creating regex: %@",
                 error.localizedDescription);
    }
    NSTextCheckingResult *handleMatch =
    [regexHandle firstMatchInString:urlString
                            options:0
                              range:NSMakeRange(0, [urlString length])];
    if (handleMatch != nil) {
        // have match, now create Twitter URI, open Twitter app here, and return
        NSString *schemaString = [urlString substringWithRange:[handleMatch rangeAtIndex:1u]];
        NSString *contentString = [urlString substringWithRange:[handleMatch rangeAtIndex:3u]];
        NSString *convertedURL = ([self canOpenLinksInTwitterClient]
                                  ? [NSString stringWithFormat:@"twitter://user?screen_name=%@", contentString]
                                  : [NSString stringWithFormat:@"%@://twitter.com/%@",
                                     schemaString, contentString]);
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:convertedURL]];
        return NO;
    }
    
    // if we are still here, check for status URI
    if (regexStatus == nil) {
        NSError *error = nil;
        regexStatus = [NSRegularExpression
                       regularExpressionWithPattern:@"^(http|https)://twitter.com/(#!/)?([^/]*?)/status/([^/]*?)$"
                       options:0 error:&error];
        NSAssert(error == nil, @"Error creating regex: %@",
                 error.localizedDescription);
    }
    NSTextCheckingResult *statusMatch =
    [regexStatus firstMatchInString:urlString
                            options:0
                              range:NSMakeRange(0, [urlString length])];
    if (statusMatch != nil) {
        // have match, now create Twitter URI, open Twitter app here, and return
        NSString *schemaString = [urlString substringWithRange:[statusMatch rangeAtIndex:1u]];
        NSString *accountString = [urlString substringWithRange:[statusMatch rangeAtIndex:3u]];
        NSString *statusIdString = [urlString substringWithRange:[statusMatch rangeAtIndex:4u]];
        NSString *convertedURL = ([self canOpenLinksInTwitterClient]
                                  ? [NSString stringWithFormat:@"twitter://status?id=%@&account=%@", statusIdString, accountString]
                                  : [NSString stringWithFormat:@"%@://twitter.com/%@/status/%@",
                                     schemaString, accountString, statusIdString]);
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:convertedURL]];
        return NO;
    }
    
    return YES;
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

@end
