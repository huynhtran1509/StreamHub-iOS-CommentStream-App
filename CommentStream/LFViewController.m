//
//  LFViewController.m
//  CommentStream
//
//  Created by Eugene Scherba on 8/7/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import <LFClient/LFClient.h>
#import "LFViewController.h"
#import <DTCoreText/DTAttributedTextCell.h>
#import <DTCoreText/DTLinkButton.h>

@interface LFViewController () <DTAttributedTextContentViewDelegate>
@property (nonatomic, strong) NSDictionary *authors;
@property (nonatomic, strong) NSArray *content;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

- (BOOL)canReuseCells;
@end

// identifier for cell reuse
NSString * const AttributedTextCellReuseIdentifier = @"AttributedTextCellReuseIdentifier";

@implementation LFViewController
{
	BOOL _useStaticRowHeight;
    NSCache* _cellCache;
}

#pragma mark - properties
@synthesize authors = _authors;
@synthesize content = _content;

-(void)setContent:(NSArray *)content authors:(NSDictionary*)authors
{
    self.content = content;
    self.authors = authors;
    
    // reload table on main thread
    [self.tableView performSelectorOnMainThread:@selector(reloadData)
                                     withObject:nil
                                  waitUntilDone:NO];
}


#pragma mark - Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    _useStaticRowHeight = NO;
    
    /*
	 if you enable static row height in this demo then the cell height is determined from the tableView.rowHeight. 
     Cells can be reused in this mode.
	 If you disable this then cells are prepared and cached to reused their internal layouter and layoutFrame. 
     Reuse is not recommended since the cells are cached anyway.
	 */
	
    if (_useStaticRowHeight) {
		self.tableView.rowHeight = 60.0f;
	}
	else {
		// establish a cache for prepared cells because heightForRowAtIndexPath and cellForRowAtIndexPath
        // both need the same cell for an index path
		_cellCache = [[NSCache alloc] init];
	}
    
    // Hide Status Bar
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        // iOS 7
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    } else {
        // iOS 6
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [LFBootstrapClient getInitForArticle:[LFConfig objectForKey:@"article"]
                                    site:[LFConfig objectForKey:@"site"]
                                 network:[LFConfig objectForKey:@"domain"]
                             environment:[LFConfig objectForKey:@"environment"]
                               onSuccess:^(NSDictionary *collection) {
                                   NSDictionary *headDocument = [collection objectForKey:@"headDocument"];
                                   [self setContent:[headDocument objectForKey:@"content"] authors:[headDocument objectForKey:@"authors"]];
                               }
                               onFailure:^(NSError *error) {
                                   if (error) {
                                       NSLog(@"Error code %d, with description %@", error.code, [error localizedDescription]);
                                   }
                               }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    _cellCache = nil;
}

- (void) dealloc
{
    _authors = nil;
    _content = nil;
    _cellCache = nil;
}

#pragma mark - UITableViewControllerDelegate

// disable this method to get static height = better performance
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (_useStaticRowHeight) {
		return tableView.rowHeight;
	}
	
	DTAttributedTextCell *cell = (DTAttributedTextCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
	return [cell requiredRowHeightInTableView:tableView];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_content count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	// workaround for iOS 5 bug (TODO: remove this)
	NSString *key = [NSString stringWithFormat:@"%d-%d", indexPath.section, indexPath.row];
	
	DTAttributedTextCell *cell = [_cellCache objectForKey:key];
    
	if (!cell) {
		if ([self canReuseCells]) {
			cell = (DTAttributedTextCell *)[tableView dequeueReusableCellWithIdentifier:AttributedTextCellReuseIdentifier];
		}
		if (!cell) {
			cell = [[DTAttributedTextCell alloc] initWithReuseIdentifier:AttributedTextCellReuseIdentifier];
		}
		cell.accessoryType = UITableViewCellStyleDefault;
		cell.hasFixedRowHeight = _useStaticRowHeight;
		
        //cell.imageView.image = [UIImage imageNamed:@"myImage.png"];
        
		// cache it, if there is a cache
		[_cellCache setObject:cell forKey:key];
	}
	
	[self configureCell:cell forIndexPath:indexPath];
	return cell;
}

#pragma mark - Private methods

// Hide Status Bar
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (BOOL)canReuseCells
{
	// reuse does not work for variable height -- only reuse cells with fixed height
    return (![self respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)]);
}

- (void)configureCell:(DTAttributedTextCell *)cell forIndexPath:(NSIndexPath *)indexPath
{
    
    NSDictionary *datum = [_content objectAtIndex:indexPath.row];
    NSDictionary *content = [datum objectForKey:@"content"];
    NSString *authorId = [content objectForKey:@"authorId"];
    NSDictionary *author = [_authors objectForKey:authorId];
    NSString *authorName = [author objectForKey:@"displayName"];
    //NSString *avatarURL = [author objectForKey:@"avatar"];
    NSString *bodyHTML = [content objectForKey:@"bodyHtml"];
	
	NSString *html = [NSString stringWithFormat:@"<font face='Avenir-Roman'><h3>%@</h3>%@</font>", authorName, bodyHTML];

    cell.attributedTextContextView.shouldDrawImages = YES;
    cell.attributedTextContextView.delegate = self;
    
	[cell setHTMLString:html];
}

#pragma mark - DTAttributedTextContentViewDelegate
-(UIView*)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView viewForLink:(NSURL *)url identifier:(NSString *)identifier frame:(CGRect)frame
{
    DTLinkButton *linkButton = [[DTLinkButton alloc] initWithFrame:frame];
    linkButton.URL = url;
    [linkButton addTarget:self action:@selector(linkButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    return linkButton;
}

#pragma mark - Events

- (IBAction)linkButtonClicked:(DTLinkButton*)sender
{
    [[UIApplication sharedApplication] openURL:sender.URL];
}

@end