//
//  LFViewController.m
//  CommentStream
//
//  Created by Eugene Scherba on 8/7/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import "LFViewController.h"
#import <LFClient/JSONKit.h>
#import <LFClient/LFClient.h>

@interface LFViewController ()
@property (nonatomic, strong) NSArray *tableData;
@end

@implementation LFViewController

@synthesize tableData;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    tableData = [NSArray arrayWithObjects:@"Egg Benedict", @"Mushroom Risotto", @"Full Breakfast", @"Hamburger", @"Ham and Egg Sandwich", @"Creme Brelee", @"White Chocolate Donut", @"Starbucks Coffee", @"Vegetable Curry", @"Instant Noodle with Egg", @"Noodle with BBQ Pork", @"Japanese Noodle with Pork", @"Green Tea", @"Thai Shrimp Cake", @"Angry Birds Cake", @"Ham and Cheese Panini", nil];
    
    
    [LFBootstrapClient getInitForArticle:@"fakeArticle"
                                    site:@"fakeSite"
                                 network:@"init-sample"
                             environment:nil
                               onSuccess:^(NSDictionary *collection) {
                                   //bootstrapInitInfo = collection;
                                   //dispatch_semaphore_signal(sema);
                               }
                               onFailure:^(NSError *error) {
                                   if (error)
                                       NSLog(@"Error code %d, with description %@", error.code, [error localizedDescription]);
                                   //dispatch_semaphore_signal(sema);
                               }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dealloc
{
    tableData = nil;
}

#pragma mark - UITableViewControllerDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [tableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    cell.textLabel.text = [tableData objectAtIndex:indexPath.row];
    return cell;
}

@end
