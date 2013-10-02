//
//  LFSBasicHTMLLabel.m
//  CommentStream
//
//  Created by Eugene Scherba on 9/20/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import "LFSBasicHTMLLabel.h"
#import "LFSBasicHTMLParser.h"

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
    //_font = nil;
    _paragraphStyle = nil;
}

#pragma mark - OHAttributedLabelDelegate
-(BOOL)attributedLabel:(OHAttributedLabel*)attributedLabel
      shouldFollowLink:(NSTextCheckingResult*)linkInfo
{
    return YES;
}

-(UIColor*)attributedLabel:(OHAttributedLabel*)attributedLabel
              colorForLink:(NSTextCheckingResult*)linkInfo
            underlineStyle:(int32_t*)underlineStyle
{
    static NSString* const kTwitterSearchPrefix = @"https://twitter.com/search/realtime/";
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
