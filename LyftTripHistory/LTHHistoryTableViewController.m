//
//  LTHHistoryTableViewController.m
//  LyftTripHistory
//
//  Created by Justin Steffen on 5/7/15.
//  Copyright (c) 2015 Justin Steffen. All rights reserved.
//

#import "LTHHistoryTableViewController.h"
#import "LTHHeaderTableViewCell.h"
#import "LTHLocationManager.h"

@interface LTHHistoryTableViewController () <LTHHeaderTableViewCellDelegate>

@property (nonatomic) LTHLocationManager *locationManager;

@end

@implementation LTHHistoryTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.locationManager = [[LTHLocationManager alloc] init];
    
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 1;
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LTHDetailTableViewCell" forIndexPath:indexPath];
    
    // Configure the cell...
    
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
                //Display alert indicating that the user has disabled location services.
                //TODO: Add help button to show user how to do it.
                
                NSString *title = NSLocalizedString(@"location_manager_denied_title", @"title for message: location manager has been denied by the user");
                NSString *message = NSLocalizedString(@"location_manager_denied_message", @"location manager has been denied by the user");
                                                      
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                                         message:message
                                                                                  preferredStyle:UIAlertControllerStyleAlert];
                
                NSString *actionTitle = NSLocalizedString(@"ok_button", @"OK Button");
                UIAlertAction *alertAction = [UIAlertAction actionWithTitle:actionTitle style:UIAlertActionStyleDefault handler:nil];
                
                [alertController addAction:alertAction];
                
                [self presentViewController:alertController animated:YES completion:^{
                    [toggleSwitch setOn:NO animated:YES];
                }];
            }
        }
        
    } else {
        NSLog(@"Trip Logging Disabled");
    }
}

@end
