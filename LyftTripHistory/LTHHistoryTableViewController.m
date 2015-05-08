//
//  LTHHistoryTableViewController.m
//  LyftTripHistory
//
//  Created by Justin Steffen on 5/7/15.
//  Copyright (c) 2015 Justin Steffen. All rights reserved.
//

#import "LTHHistoryTableViewController.h"
#import "LTHHeaderTableViewCell.h"
#import "LTHDetailTableViewCell.h"

@interface LTHHistoryTableViewController () <LTHTripStoreDelegate, LTHHeaderTableViewCellDelegate>

@end

@implementation LTHHistoryTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tripStore.delegate = self;
    
    [self configureNavigationItem];
    
    self.tableView.estimatedRowHeight = 75.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;

    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation Bar Helper

- (void)configureNavigationItem
{
    UIImage *image = [UIImage imageNamed:@"navbar"];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:image];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tripStore.allItems.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    LTHHeaderTableViewCell *cell = (LTHHeaderTableViewCell *) [tableView dequeueReusableCellWithIdentifier:@"LTHHeaderTableViewCell"];
    
    cell.delegate = self;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 58.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSUInteger index = (self.tripStore.allItems.count - 1) - indexPath.row;
    LTHTrip *trip = self.tripStore.allItems[indexPath.row];
    
    LTHDetailTableViewCell *cell = (LTHDetailTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"LTHDetailTableViewCell" forIndexPath:indexPath];
    
    cell.titleLabel.text = trip.titleDescription;
    cell.timeLabel.text = trip.durationDescription;
    
    return cell;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - LTHHeaderTableViewCellDelegate

- (void)headerTableViewCell:(LTHHeaderTableViewCell *)cell didChangeToggleSwitch:(UISwitch *)toggleSwitch;
{
    if (toggleSwitch.on) {
        NSLog(@"Trip Logging Enabled");
        
        if (!self.locationManager.isAuthorized) {
            BOOL result = [self.locationManager requestPermission];
            
            if (!result) {
                [self presentLocationServicesDeniedWithSwitch:toggleSwitch];
                return;
            }
        }
        
        [self.locationManager startStandardUpdates];
    } else {
        NSLog(@"Trip Logging Disabled");
        [self.locationManager stopStandardUpdates];
    }
}


//Display alert indicating that the user has disabled location services.
- (void)presentLocationServicesDeniedWithSwitch:(UISwitch *)toggleSwitch
{
    NSString *title = NSLocalizedString(@"location_manager_denied_title", @"title for message: location manager has been denied by the user");
    NSString *message = NSLocalizedString(@"location_manager_denied_message", @"location manager has been denied by the user");
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    NSString *actionTitle = NSLocalizedString(@"ok_button", @"OK Button");
    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:actionTitle style:UIAlertActionStyleDefault handler:nil];
    
    //TODO: Add help button to show user how to do it.
    
    [alertController addAction:alertAction];
    
    [self presentViewController:alertController animated:YES completion:^{
        [toggleSwitch setOn:NO animated:YES];
    }];
}

#pragma mark - LTHTripStoreDelegate

- (void)tripStore:(LTHTripStore *)tripStore didCreateItem:(LTHTrip *)item
{
    NSLog(@"Did create item.  Item: %@", item);
    [self.tableView reloadData];
}

- (void)tripStore:(LTHTripStore *)tripStore didUpdateItem:(LTHTrip *)item
{
    NSLog(@"Did update item.  Item: %@", item);
    [self.tableView reloadData];
}

@end
