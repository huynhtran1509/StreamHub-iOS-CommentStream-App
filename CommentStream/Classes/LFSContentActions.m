//
//  LFSContentActions.m
//  CommentStream
//
//  Created by Eugene Scherba on 5/16/14.
//  Copyright (c) 2014 Livefyre. All rights reserved.
//

#import "LFSContentActions.h"
#import <StreamHub-iOS-SDK/LFSConstants.h>

@implementation LFSContentActions

@synthesize delegate = _delegate;

#pragma mark -
@synthesize actionSheet = _actionSheet;
-(UIActionSheet*)actionSheet
{
    if (_actionSheet == nil) {
        // Initialization code
        _actionSheet = [[UIActionSheet alloc]
                        initWithTitle:@"Flag Comment"
                        delegate:self
                        cancelButtonTitle:@"Cancel"
                        destructiveButtonTitle:[LFSContentFlags[LFSFlagSpam] capitalizedString]
                        otherButtonTitles:
                        [LFSContentFlags[LFSFlagOffensive] capitalizedString],
                        [LFSContentFlags[LFSFlagOfftopic] capitalizedString],
                        [LFSContentFlags[LFSFlagDisagree] capitalizedString],
                        nil];
    }
    return _actionSheet;
}

#pragma mark - UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //Get the name of the current pressed button
    NSString *action = [actionSheet buttonTitleAtIndex:buttonIndex];
    if  ([action isEqualToString:[LFSContentFlags[LFSFlagSpam] capitalizedString]])
    {
        [self.delegate flagContentWithFlag:LFSFlagSpam];
    }
    else if ([action isEqualToString:[LFSContentFlags[LFSFlagOffensive] capitalizedString]])
    {
        [self.delegate flagContentWithFlag:LFSFlagOffensive];
    }
    else if ([action isEqualToString:[LFSContentFlags[LFSFlagOfftopic] capitalizedString]])
    {
        [self.delegate flagContentWithFlag:LFSFlagOfftopic];
    }
    else if ([action isEqualToString:[LFSContentFlags[LFSFlagDisagree] capitalizedString]])
    {
        [self.delegate flagContentWithFlag:LFSFlagDisagree];
    }
    else if ([action isEqualToString:@"Cancel"])
    {
        // do nothing
    }
}

@end
