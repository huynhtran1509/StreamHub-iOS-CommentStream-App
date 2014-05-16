//
//  LFSContentActions.m
//  CommentStream
//
//  Created by Eugene Scherba on 5/16/14.
//  Copyright (c) 2014 Livefyre. All rights reserved.
//

#import "LFSContentActions.h"
#import <StreamHub-iOS-SDK/LFSConstants.h>


#define LFS_CONTENT_ACTIONS_LENGTH 6u
const NSString* const LFSContentActionStrings[LFS_CONTENT_ACTIONS_LENGTH] =
{
    @"delete",      // 0
    @"ban user",    // 1
    @"bozo",        // 2
    @"edit",        // 3
    @"feature",     // 4
    @"flag"         // 5
};

#pragma mark -
@interface LFSContentActions ()
@property (nonatomic, strong) UIActionSheet *actionSheet2;
@end

#pragma mark -
@implementation LFSContentActions

@synthesize delegate = _delegate;

#pragma mark -
@synthesize actionSheet = _actionSheet;
-(UIActionSheet*)actionSheet
{
    if (_actionSheet == nil) {
        _actionSheet = [[UIActionSheet alloc]
                        initWithTitle:nil
                        delegate:self
                        cancelButtonTitle:@"Cancel"
                        destructiveButtonTitle:[LFSContentActionStrings[LFSContentActionDelete] capitalizedString]
                        otherButtonTitles:
                        [LFSContentActionStrings[LFSContentActionBanUser] capitalizedString],
                        [LFSContentActionStrings[LFSContentActionBozo] capitalizedString],
                        [LFSContentActionStrings[LFSContentActionEdit] capitalizedString],
                        [LFSContentActionStrings[LFSContentActionFeature] capitalizedString],
                        [LFSContentActionStrings[LFSContentActionFlag] capitalizedString],
                        nil];
    }
    return _actionSheet;
}

#pragma mark -
@synthesize actionSheet2 = _actionSheet2;
-(UIActionSheet*)actionSheet2
{
    if (_actionSheet2 == nil) {
        _actionSheet2 = [[UIActionSheet alloc]
                         initWithTitle:nil
                         delegate:self
                         cancelButtonTitle:@"Cancel"
                         destructiveButtonTitle:[LFSContentFlags[LFSFlagSpam] capitalizedString]
                         otherButtonTitles:
                         [LFSContentFlags[LFSFlagOffensive] capitalizedString],
                         [LFSContentFlags[LFSFlagOfftopic] capitalizedString],
                         [LFSContentFlags[LFSFlagDisagree] capitalizedString],
                         nil];
    }
    return _actionSheet2;
}

#pragma mark - UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // Get the name of the button pressed
    NSString *action = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if (actionSheet == self.actionSheet) {
        
        if ([action isEqualToString:[LFSContentActionStrings[LFSContentActionDelete] capitalizedString]])
        {
            [self.delegate performAction:LFSContentActionDelete];
        }
        else if ([action isEqualToString:[LFSContentActionStrings[LFSContentActionBanUser] capitalizedString]])
        {
            [self.delegate performAction:LFSContentActionBanUser];
        }
        else if ([action isEqualToString:[LFSContentActionStrings[LFSContentActionBozo] capitalizedString]])
        {
            [self.delegate performAction:LFSContentActionBozo];
        }
        else if  ([action isEqualToString:[LFSContentActionStrings[LFSContentActionEdit] capitalizedString]])
        {
            [self.delegate performAction:LFSContentActionEdit];
        }
        else if ([action isEqualToString:[LFSContentActionStrings[LFSContentActionFeature] capitalizedString]])
        {
            [self.delegate performAction:LFSContentActionFeature];
        }
        else if ([action isEqualToString:[LFSContentActionStrings[LFSContentActionFlag] capitalizedString]])
        {
            [self.actionSheet2 showInView:self.actionSheet.viewForBaselineLayout];
        }
        else if ([action isEqualToString:@"Cancel"])
        {
            // do nothing
        }
    }
    else if (actionSheet == self.actionSheet2) {
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
}

@end
