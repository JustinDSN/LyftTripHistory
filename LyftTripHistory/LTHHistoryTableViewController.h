//
//  LTHHistoryTableViewController.h
//  LyftTripHistory
//
//  Created by Justin Steffen on 5/7/15.
//  Copyright (c) 2015 Justin Steffen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LTHLocationManager.h"
#import "LTHTripStore.h"

@interface LTHHistoryTableViewController : UITableViewController

@property (nonatomic) LTHLocationManager *locationManager;
@property (nonatomic) LTHTripStore *tripStore;

@end
