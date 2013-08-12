//
//  LFViewController.m
//  CommentStream
//
//  Created by Eugene Scherba on 8/7/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import <LFClient/LFClient.h>
#import "LFViewController.h"

@interface LFViewController ()
@property (nonatomic, strong) NSDictionary *authors;
@property (nonatomic, strong) NSArray *content;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation LFViewController

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
}

- (void) dealloc
{
    _authors = nil;
    _content = nil;
}

#pragma mark - UITableViewControllerDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_content count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"lfcomment";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:simpleTableIdentifier];
    }
    
    NSDictionary *datum = [_content objectAtIndex:indexPath.row];
    NSString *authorId = [[datum objectForKey:@"content"] objectForKey:@"authorId"];
    cell.textLabel.text = [[_authors objectForKey:authorId] objectForKey:@"displayName"];
    cell.detailTextLabel.text = [[datum objectForKey:@"content"] objectForKey:@"bodyHtml"];
    return cell;
}

@end