//
//  LFSNewCommentViewController.m
//  CommentStream
//
//  Created by Eugene Scherba on 9/13/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import <StreamHub-iOS-SDK/LFSWriteClient.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <FilepickerSDK/FPConstants.h>
#import <FilepickerSDK/FPLibrary.h>
#import <FilepickerSDK/FPMBProgressHUD.h>
#import <AssetsLibrary/ALAssetsLibrary.h>

#import "UIImagePickerController+StatusBarHidden.h"
#import "LFSPostViewController.h"
#import "LFSAuthorProfile.h"
#import "LFSResource.h"
#import "UIColor+CommentStream.h"


#define LFS_PHOTO_ACTIONS_LENGTH 3u

typedef NS_ENUM(NSUInteger, kAddPhotoAction) {
    kAddPhotoTakePhoto = 0u,
    kAddPhotoChooseExisting,
    kAddPhotoSocialSource
};

// (for internal use):
// https://github.com/Livefyre/lfdj/blob/production/lfwrite/lfwrite/api/v3_0/urls.py#L75
static NSString* const kPhotoActionsArray[LFS_PHOTO_ACTIONS_LENGTH] =
{
    @"Take Photo",            // 0
    @"Choose Existing Photo", // 1
    @"Use Social Sources",    // 2
};


@interface LFSPostViewController ()

// render iOS7 status bar methods as writable properties
@property (nonatomic, assign) BOOL prefersStatusBarHidden;
@property (nonatomic, assign) UIStatusBarAnimation preferredStatusBarUpdateAnimation;

@property (nonatomic, readonly) LFSWriteClient *writeClient;
@property (weak, nonatomic) IBOutlet LFSWriteCommentView *writeCommentView;

@property (weak, nonatomic) IBOutlet UINavigationBar *postNavbar;

- (IBAction)cancelClicked:(UIBarButtonItem *)sender;
- (IBAction)postClicked:(UIBarButtonItem *)sender;

@property (nonatomic, strong) NSMutableArray *attachments;

@end

@implementation LFSPostViewController {
    NSDictionary *_authorHandles;
    BOOL _pauseKeyboard;
}

#pragma mark - Properties

@synthesize writeCommentView;

@synthesize delegate = _delegate;

// render iOS7 status bar methods as writable properties
@synthesize prefersStatusBarHidden = _prefersStatusBarHidden;
@synthesize preferredStatusBarUpdateAnimation = _preferredStatusBarUpdateAnimation;

@synthesize postNavbar = _postNavbar;
@synthesize user = _user;

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

#pragma mark -
@synthesize actionSheet = _actionSheet;
-(UIActionSheet*)actionSheet
{
    if (_actionSheet == nil) {
        _actionSheet = [[UIActionSheet alloc]
                        initWithTitle:nil
                        delegate:self
                        cancelButtonTitle:@"Cancel"
                        destructiveButtonTitle:nil
                        otherButtonTitles:
                        kPhotoActionsArray[kAddPhotoTakePhoto],
                        kPhotoActionsArray[kAddPhotoChooseExisting],
                        kPhotoActionsArray[kAddPhotoSocialSource],
                        nil];
    }
    return _actionSheet;
}

#pragma mark - UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // TODO: this method is incomplete
    
    // Get the name of the button pressed
    NSString *action = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if (actionSheet == self.actionSheet) {
        if ([action isEqualToString:kPhotoActionsArray[kAddPhotoTakePhoto]])
        {
            [self presentImagePickerWithSourceType:UIImagePickerControllerSourceTypeCamera];
        }
        else if ([action isEqualToString:kPhotoActionsArray[kAddPhotoChooseExisting]])
        {
            [self presentImagePickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        }
        else if ([action isEqualToString:kPhotoActionsArray[kAddPhotoSocialSource]])
        {
            // use FilePicker control
            [self presentSocialPicker];
        }
        else {
            // do nothing
        }
    }
}

- (void)presentImagePickerWithSourceType:(UIImagePickerControllerSourceType)sourceType
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    [picker setDelegate:self];
    @try {
        [picker setSourceType:sourceType];
    }
    @catch (NSException *e) {
        if ([e name] == NSInvalidArgumentException) {
            return; // source type not available (on iOS simulator)
        } else {
            @throw e;
        }
    }
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)presentSocialPicker
{
    FPPickerController *picker = [[FPPickerController alloc] init];
    [picker setFpdelegate:self];
    [picker setDataTypes:[NSArray arrayWithObjects:@"image/*", nil]];
    [picker setSourceNames:[[NSArray alloc]
                            initWithObjects: FPSourceImagesearch, FPSourceFacebook, FPSourceInstagram, FPSourceFlickr, FPSourcePicasa, FPSourceBox, FPSourceDropbox, FPSourceGoogleDrive, nil]];

    [picker setSelectMultiple:NO];
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if (![mediaType isEqualToString:(__bridge NSString *)kUTTypeImage])
    {
        // only accept @"public.image" types -- ignore video
        [self dismissViewControllerAnimated:NO completion:^{
            [self.writeCommentView.textView becomeFirstResponder];
        }];
        return;
    }
    
    UIImage *originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    NSURL *referenceURL = [info objectForKeyedSubscript:UIImagePickerControllerReferenceURL];
    
    if (referenceURL != nil) {
        ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
        [assetslibrary assetForURL:referenceURL resultBlock:^(ALAsset *asset)
         {
             FPMBProgressHUD __block *hud;
             dispatch_async(dispatch_get_main_queue(),^{
                 hud = [FPMBProgressHUD showHUDAddedTo:self.view animated:YES];
                 hud.labelText = @"Uploading file";
                 hud.mode = FPMBProgressHUDModeDeterminate;
             });
             
             [FPLibrary uploadAsset:asset withOptions:nil shouldUpload:YES
                            success:^(id JSON, NSURL *localurl)
              {
                  NSDictionary *dictionary = FPDictionaryFromJSONInfoPhoto(JSON, originalImage, localurl);
                  [self addMediaWithInfo:dictionary];
                  [FPMBProgressHUD hideAllHUDsForView:self.view animated:YES];
                  _pauseKeyboard = NO;
                  [self.writeCommentView.textView becomeFirstResponder];
                  //NSLog(@"Got JSON: %@, localURL: %@", JSON, localurl);
              }
                            failure:^(NSError *error, id JSON, NSURL *localurl)
              {
                  //NSDictionary *dictionary = FPDictionaryFromJSONInfoPhotoFailure(image, localurl, nil);
                  [FPMBProgressHUD hideAllHUDsForView:self.view animated:YES];
                  _pauseKeyboard = NO;
                  [self.writeCommentView.textView becomeFirstResponder];
              }
                           progress:^(float progress)
              {
                  hud.progress = progress;
              }];
         } failureBlock:nil];
        _pauseKeyboard = YES;
        [self.writeCommentView.textView resignFirstResponder];
    }
    else if (originalImage != nil) {
        
        FPMBProgressHUD __block *hud = [FPMBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"Uploading file";
        hud.mode = FPMBProgressHUDModeDeterminate;
        
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void) {
            
            [FPLibrary uploadImage:originalImage ofMimetype:@"image/*" withOptions:nil shouldUpload:YES
                           success:^(id JSON, NSURL *localurl)
             {
                 NSDictionary *dictionary = FPDictionaryFromJSONInfoPhoto(JSON, originalImage, localurl);
                 [self addMediaWithInfo:dictionary];
                 [FPMBProgressHUD hideAllHUDsForView:self.view animated:YES];
                 _pauseKeyboard = NO;
                 [self.writeCommentView.textView becomeFirstResponder];
                 //NSLog(@"Got JSON: %@, localURL: %@", JSON, localurl);
             }
                           failure:^(NSError *error, id JSON, NSURL *localurl)
             {
                 //NSDictionary *dictionary = FPDictionaryFromJSONInfoPhotoFailure(image, localurl, nil);
                 [FPMBProgressHUD hideAllHUDsForView:self.view animated:YES];
                 _pauseKeyboard = NO;
                 [self.writeCommentView.textView becomeFirstResponder];
             }
                          progress:^(float progress)
             {
                 hud.progress = progress;
             }];
        });
        _pauseKeyboard = YES;
        [self.writeCommentView.textView resignFirstResponder];
    }
    else {
        _pauseKeyboard = NO;
        [self.writeCommentView.textView becomeFirstResponder];
    }
    [self dismissViewControllerAnimated:NO completion:nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:NO completion:^{
        [self.writeCommentView.textView becomeFirstResponder];
    }];
}

#pragma mark - FPPickerDelegate

-(void)addMediaWithInfo:(NSDictionary*)info
{
    NSString *urlString = [@"http://media.fyre.co/" stringByAppendingString:
                           [info objectForKey:FPPickerControllerKey]];
    LFSOembedType oembedType = attachmentCodeFromUTType([info objectForKey:FPPickerControllerMediaType]);
    LFSOembed *oembed = [LFSOembed oembedWithUrl:urlString
                                            link:urlString
                                    providerName:@"LivefyreFilePicker"
                                            type:oembedType];
    
    [self.attachments addObject:[oembed object]];
    [self.writeCommentView.attachmentImageView setImageWithURL:[NSURL URLWithString:urlString]];
}

-(void)FPPickerController:(FPPickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self addMediaWithInfo:info];
    [self dismissViewControllerAnimated:NO completion:^{
        [self.writeCommentView.textView becomeFirstResponder];
    }];
}

-(void)FPPickerControllerDidCancel:(FPPickerController *)picker
{
    [self dismissViewControllerAnimated:NO completion:^{
        [self.writeCommentView.textView becomeFirstResponder];
    }];
}

#pragma mark - LFSWritecommentViewDelegate
-(void)didClickAddPhotoButton
{
    [self.actionSheet showInView:self.view];
}

#pragma mark - UIViewController

// Hide/show status bar
- (BOOL)prefersStatusBarHidden
{
    return NO;
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
    
    _pauseKeyboard = NO;
    
	// Do any additional setup after loading the view.

    LFSAuthorProfile *author = self.user.profile;
    NSString *detailString = (author.twitterHandle ? [@"@" stringByAppendingString:author.twitterHandle] : nil);
    LFSResource *headerInfo = [[LFSResource alloc]
                               initWithIdentifier:detailString
                               attribute:nil
                               displayString:author.displayName
                               icon:self.avatarImage];
    [headerInfo setIconURLString:author.avatarUrlString75];
    
    [self.writeCommentView setDelegate:self];
    [self.writeCommentView setProfileLocal:headerInfo];
    
    self.attachments = [[NSMutableArray alloc] init];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.replyToContent != nil) {
        [self.postNavbar.topItem setTitle:@"Reply"];
        
        _authorHandles = nil;
        NSString *replyPrefix = [self replyPrefixFromContent:self.replyToContent];
        if (replyPrefix != nil) {
            [self.writeCommentView.textView setText:replyPrefix];
        }
    }
    
    // show keyboard (doing this in viewDidAppear causes unnecessary lag)
    if (_pauseKeyboard == NO) {
        [self.writeCommentView.textView becomeFirstResponder];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.writeCommentView.textView resignFirstResponder];
}

- (NSString*)replyPrefixFromContent:(LFSContent*)content
{
    // remove self (own user handle) from list
    NSMutableDictionary *dictionary = [content authorHandles];
    NSString *currentHandle = self.user.profile.authorHandle;
    if (currentHandle != nil) {
        [dictionary removeObjectForKey:[currentHandle lowercaseString]];
    }
    
    _authorHandles = dictionary;
    NSArray *handles = [_authorHandles allKeys];
    NSString *prefix = nil;
    if (handles.count > 0) {
        NSString *joinedParticipants = [handles componentsJoinedByString:@" @"];
        prefix = [NSString stringWithFormat:@"@%@ ", joinedParticipants];
    }
    return prefix;
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
    const static CGFloat kStatusBarHeight = 20.f;
    _prefersStatusBarHidden = hidden;
    _preferredStatusBarUpdateAnimation = animation;
    
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)])
    {
        // iOS7
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
    else
    {
        // iOS6
        [[UIApplication sharedApplication] setStatusBarHidden:hidden
                                                withAnimation:animation];
        if (self.navigationController) {
            UINavigationBar *navigationBar = self.navigationController.navigationBar;
            if (hidden && navigationBar.frame.origin.y > 0.f)
            {
                CGRect frame = navigationBar.frame;
                frame.origin.y = 0.f;
                navigationBar.frame = frame;
            }
            else if (!hidden && navigationBar.frame.origin.y < kStatusBarHeight)
            {
                CGRect frame = navigationBar.frame;
                frame.origin.y = kStatusBarHeight;
                navigationBar.frame = frame;
            }
        }
    }
}

#pragma mark - Utility methods

-(void)clearContent
{
    [self.attachments removeAllObjects];
    [self.writeCommentView.attachmentImageView setImage:nil];
    [self.writeCommentView.textView setText:@""];
}

-(NSString*)processReplyText:(NSString*)replyText
{
    if (_authorHandles == nil) {
        return replyText;
    }
    
    // process replyText such that all cases of handles get replaced with anchors
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:@"@(\\w+)\\b"
                                  options:NSRegularExpressionCaseInsensitive
                                  error:&error];
    
    NSArray *matches = [regex matchesInString:replyText
                                      options:0
                                        range:NSMakeRange(0, replyText.length)];
    
    // enumerate in reverse order because that way we can preserve location
    // in our mutable string
    NSMutableString *mutableReply = [replyText mutableCopy];
    [matches enumerateObjectsWithOptions:NSEnumerationReverse
                              usingBlock:
     ^(NSTextCheckingResult *match, NSUInteger idx, BOOL *stop)
    {
        NSRange handleRange = [match rangeAtIndex:1];
        NSString *candidate = [replyText substringWithRange:match.range];
        
        NSString *urlString = [_authorHandles objectForKey:[[replyText substringWithRange:handleRange] lowercaseString]];
        if (urlString != nil) {
            // candidate found in dictionary
            NSString *replacement = [NSString
                                     stringWithFormat:@"<a href=\"%@\">%@</a>",
                                     urlString, candidate];
            [mutableReply replaceCharactersInRange:match.range withString:replacement];
        }
    }];

    return [mutableReply copy];
}

#pragma mark - Actions
- (IBAction)cancelClicked:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)postContent
{
    static NSString* const kFailurePostTitle = @"Failed to post content";

    NSString *userToken = [self.collection objectForKey:@"lftoken"];
    if (userToken != nil) {
        UITextView *textView = self.writeCommentView.textView;
        NSString *text = (self.replyToContent
                          ? [self processReplyText:textView.text]
                          : textView.text);
        
        [self clearContent];
        
        id<LFSPostViewControllerDelegate> collectionViewController = nil;
        if ([self.delegate respondsToSelector:@selector(collectionViewController)]) {
            collectionViewController = [self.delegate collectionViewController];
        }
        [self.writeClient postContent:text
                      withAttachments:self.attachments
                         inCollection:self.collectionId
                            userToken:userToken
                            inReplyTo:self.replyToContent.idString
                            onSuccess:^(NSOperation *operation, id responseObject)
         {
             if ([collectionViewController respondsToSelector:@selector(didPostContentWithOperation:response:)])
             {
                 [collectionViewController didPostContentWithOperation:operation response:responseObject];
             }
         }
                            onFailure:^(NSOperation *operation, NSError *error)
         {
             // show an error message
             [[[UIAlertView alloc]
               initWithTitle:kFailurePostTitle
               message:[error localizedRecoverySuggestion]
               delegate:nil
               cancelButtonTitle:@"OK"
               otherButtonTitles:nil] show];
         }];
        if ([self.delegate respondsToSelector:@selector(didSendPostRequestWithReplyTo:)]) {
            [self.delegate didSendPostRequestWithReplyTo:self.replyToContent.idString];
        }
    } else {
        // userToken is nil -- show an error message
        [[[UIAlertView alloc]
          initWithTitle:kFailurePostTitle
          message:@"You do not have permission to write to this collection"
          delegate:nil
          cancelButtonTitle:@"OK"
          otherButtonTitles:nil] show];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)postClicked:(UIBarButtonItem *)sender
{
    [self postContent];
}

@end
