//
//  LFSBasicHTMLLabel.m
//  CommentStream
//
//  Created by Eugene Scherba on 9/20/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import "LFSBasicHTMLLabel.h"
#import "LFSBasicHTMLParser.h"


@implementation LFSBasicHTMLLabel {
    BOOL _customLineSpacing;
}

@synthesize font = _font;

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _font = nil;
        _customLineSpacing = NO;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _font = nil;
        _customLineSpacing = NO;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)setHTMLString:(NSString *)html
{
    NSMutableAttributedString *attributedText =
    [LFSBasicHTMLParser attributedStringByProcessingMarkupInString:html];
    
    if (_font) {
        [attributedText setFont:_font];
    }
    
    if (_customLineSpacing) {
        NSMutableParagraphStyle *paragrahStyle = [[NSMutableParagraphStyle alloc] init];
        [paragrahStyle setLineSpacing:_lineSpacing];
        [attributedText addAttribute:NSParagraphStyleAttributeName value:paragrahStyle range:NSMakeRange(0, [attributedText length])];
    }
    
    [self setAttributedText:attributedText];
}

-(void)setLineSpacing:(CGFloat)points
{
    _customLineSpacing = YES;
    _lineSpacing = points;
}

@end
