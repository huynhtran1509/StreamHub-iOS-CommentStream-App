//
//  LFSRootViewController.m
//  CommentStream
//
//  Created by Eugene Scherba on 9/10/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import "LFSConfig.h"
#import "LFSRootViewController.h"
#import "LFSCollectionViewController.h"

@interface LFSRootViewController ()
@property (nonatomic, strong) NSArray *tableModel;

// render iOS7 status bar methods as writable properties
@property (nonatomic, assign) BOOL prefersStatusBarHidden;
@property (nonatomic, assign) UIStatusBarAnimation preferredStatusBarUpdateAnimation;

@end

// some module-level constants
static NSString* const kAttributedCellReuseIdentifier = @"CollectionCell";
static NSString* const kCellSelectSegue = @"collectionView";

@implementation LFSRootViewController

#pragma mark - Properties
@synthesize tableModel = _tableModel;

// render iOS7 status bar methods as writable properties
@synthesize prefersStatusBarHidden = _prefersStatusBarHidden;
@synthesize preferredStatusBarUpdateAnimation = _preferredStatusBarUpdateAnimation;

#pragma mark - Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // set which collection to show content for...
    LFSConfig *config = [[LFSConfig alloc] initWithPlist:@"LFSConfig"];
    self.tableModel = config.collections;
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    [self.navigationController setToolbarHidden:YES animated:animated];
}

/*
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
*/

- (void)dealloc
{
    _tableModel = nil;
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0) {
        return [self.tableModel count];
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kAttributedCellReuseIdentifier
                                                            forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:kAttributedCellReuseIdentifier];
        
    }
    // Configure the cell...
    NSDictionary *collection = [self.tableModel objectAtIndex:indexPath.row];
    cell.textLabel.text = [collection objectForKey:@"_name"];
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:kCellSelectSegue])
    {
        // Get reference to the destination view controller
        if ([segue.destinationViewController isKindOfClass:[LFSCollectionViewController class]]) {
            if ([sender isKindOfClass:[UITableViewCell class]]) {
                NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
                LFSCollectionViewController *vc = segue.destinationViewController;
                
                // assign model object
                vc.collection = [self.tableModel objectAtIndex:indexPath.row];
            }
        }
    }
}

@end
