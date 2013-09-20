//
//  LFSBasicHTMLParser.m
//  CommentStream
//
//  Created by Eugene Scherba on 9/19/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import "LFSBasicHTMLParser.h"
#import <OHAttributedLabel/NSAttributedString+Attributes.h>

#if __has_feature(objc_arc)
#define MRC_AUTORELEASE(x) (x)
#else
#define MRC_AUTORELEASE(x) [(x) autorelease]
#endif


@implementation LFSBasicHTMLParser

+(NSDictionary*)tagMappings
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            
            // &
            ^NSAttributedString*(NSAttributedString* str, NSTextCheckingResult* match)
            {
                NSRange textRange = [match rangeAtIndex:1];
                if (textRange.length>0)
                {
                    return MRC_AUTORELEASE([[NSAttributedString alloc] initWithString:@"&"]);
                } else {
                    return nil;
                }
            }, @"(&amp;)",
            
            // <
            ^NSAttributedString*(NSAttributedString* str, NSTextCheckingResult* match)
            {
                NSRange textRange = [match rangeAtIndex:1];
                if (textRange.length>0)
                {
                    return MRC_AUTORELEASE([[NSAttributedString alloc] initWithString:@"<"]);
                } else {
                    return nil;
                }
            }, @"(&lt;)",
            
            // <
            ^NSAttributedString*(NSAttributedString* str, NSTextCheckingResult* match)
            {
                NSRange textRange = [match rangeAtIndex:1];
                if (textRange.length>0)
                {
                    return MRC_AUTORELEASE([[NSAttributedString alloc] initWithString:@">"]);
                } else {
                    return nil;
                }
            }, @"(&gt;)",
            
            // Ignoring these tags
            ^NSAttributedString*(NSAttributedString* str, NSTextCheckingResult* match)
            {
                NSRange innerRange = [match rangeAtIndex:2];
                if (innerRange.length>0)
                {
                    return MRC_AUTORELEASE([str attributedSubstringFromRange:innerRange]);
                } else {
                    return nil;
                }
            }, @"<(p|span)\\b[^>]*>(.*?)</\\1>",
            
            // Hyperlinks
            ^NSAttributedString*(NSAttributedString* str, NSTextCheckingResult* match)
            {
                NSRange hrefRange = [match rangeAtIndex:2];
                NSRange innerRange = [match rangeAtIndex:3];
                if (hrefRange.length > 0 && innerRange.length > 0)
                {
                    NSString* href = [str attributedSubstringFromRange:hrefRange].string;
                    NSMutableAttributedString* innerText = [[str attributedSubstringFromRange:innerRange] mutableCopy];
                    [innerText setLink:[NSURL URLWithString:href] range:NSMakeRange(0,innerRange.length)];
                    return MRC_AUTORELEASE(innerText);
                } else {
                    return nil;
                }
            }, @"<a\\s[^>]*\\bhref\\s*=\\s*(['\"])(.*?)\\1[^>]*>(.*?)</a>",
            
            /*
            // Bold, strong
            ^NSAttributedString*(NSAttributedString* str, NSTextCheckingResult* match)
            {
                NSRange innerRange = [match rangeAtIndex:2];
                if (innerRange.length>0)
                {
                    NSMutableAttributedString* innerText = [[str attributedSubstringFromRange:innerRange] mutableCopy];
                    [innerText setTextBold:YES range:NSMakeRange(0,innerRange.length)];
                    return MRC_AUTORELEASE(innerText);
                } else {
                    return nil;
                }
            }, @"<(b|strong)\\b[^>]*>(.+?)</\\1>",
            
            // Underlined (no semantic equivalent)
            ^NSAttributedString*(NSAttributedString* str, NSTextCheckingResult* match)
            {
                NSRange innerRange = [match rangeAtIndex:1];
                if (innerRange.length>0)
                {
                    NSMutableAttributedString* innerText = [[str attributedSubstringFromRange:innerRange] mutableCopy];
                    [innerText setTextIsUnderlined:YES];
                    return MRC_AUTORELEASE(innerText);
                } else {
                    return nil;
                }
            }, @"<u>(.+?)</u>",
            
            // Italic, em
            ^NSAttributedString*(NSAttributedString* str, NSTextCheckingResult* match)
            {
                NSRange innerRange = [match rangeAtIndex:2];
                if (innerRange.length>0)
                {
                    NSMutableAttributedString* innerText = [[str attributedSubstringFromRange:innerRange] mutableCopy];
                    [innerText setTextItalics:YES range:NSMakeRange(0,innerText.length)];
                    return MRC_AUTORELEASE(innerText);
                } else {
                    return nil;
                }
            }, @"<(i|em)\\b[^>]*>(.*?)</\\1>",
            */
            
            nil];
}


@end
