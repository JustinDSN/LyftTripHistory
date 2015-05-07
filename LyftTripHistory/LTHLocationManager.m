//
//  LTHLocationManager.m
//  LyftTripHistory
//
//  Created by Justin Steffen on 5/7/15.
//  Copyright (c) 2015 Justin Steffen. All rights reserved.
//

#import "LTHLocationManager.h"
@import CoreLocation;

@interface LTHLocationManager () <CLLocationManagerDelegate>

@property (nonatomic) CLLocationManager *manager;

@end

@implementation LTHLocationManager

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        self.manager = [[CLLocationManager alloc] init];
        self.manager.delegate = self;
    }
    
    return self;
}

- (BOOL)requestPermission
{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    if (status == kCLAuthorizationStatusRestricted || status == kCLAuthorizationStatusDenied) {
        NSLog(@"The user previously declined to use location services");
        return NO;
    } else if (status == kCLAuthorizationStatusNotDetermined) {
        [self.manager requestWhenInUseAuthorization];
        return YES;
    } else {
        return YES;
    }
}

- (BOOL)isAuthorized
{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
        case kCLAuthorizationStatusRestricted:
        case kCLAuthorizationStatusDenied:
            return NO;
            break;
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            return YES;
            break;
    }
}

@end
