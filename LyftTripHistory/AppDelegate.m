//
//  AppDelegate.m
//  LyftTripHistory
//
//  Created by Justin Steffen on 5/7/15.
//  Copyright (c) 2015 Justin Steffen. All rights reserved.
//

#import "AppDelegate.h"
#import "LTHLocationManager.h"
#import "LTHTripStore.h"
#import "LTHHistoryTableViewController.h"

@interface AppDelegate ()

@property (nonatomic) LTHLocationManager *locationManager;
@property (nonatomic) LTHTripStore *tripStore;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //Inject dependencies
    self.tripStore = [LTHTripStore sharedStore];
    self.locationManager = [[LTHLocationManager alloc] initWithTripStore:self.tripStore];
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *initialViewController = [storyBoard instantiateInitialViewController];
    
    if ([initialViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)initialViewController;
        
        UIViewController *topViewController = [navigationController topViewController];

        if ([topViewController isKindOfClass:[LTHHistoryTableViewController class]]) {
            LTHHistoryTableViewController *historyTableViewController = (LTHHistoryTableViewController *)topViewController;
            
            historyTableViewController.locationManager = self.locationManager;
            historyTableViewController.tripStore = self.tripStore;
        } else {
            NSLog(@"ERROR: Unexpected view controller class of: %@", NSStringFromClass([topViewController class]));
        }
    } else {
        NSLog(@"ERROR: Unexpected view controller class of: %@", NSStringFromClass([initialViewController class]));
    }
    
    self.window.rootViewController = initialViewController;
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [self saveData];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    //End current trip
    LTHTrip *currentTrip = self.tripStore.allItems.firstObject;
    currentTrip.completed = YES;
    
    [self saveData];
}

- (void)saveData
{
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    BOOL success = [self.tripStore saveChanges];
    
    if (success) {
        NSLog(@"Successfully saved all of the trips.");
    } else {
        NSLog(@"Failed to save any of the trips.");
    }
}

@end
