//
//  LTHLocationManager.m
//  LyftTripHistory
//
//  Created by Justin Steffen on 5/7/15.
//  Copyright (c) 2015 Justin Steffen. All rights reserved.
//

@import CoreLocation;
#import "LTHLocationManager.h"
#import "LTHTrip.h"

static float kMPHRatio = 2.23694;
static int kMinMPH = 10;
static int kTimerInterval = 60;
static int kDeviceIdleTime = 60;

@interface LTHLocationManager () <CLLocationManagerDelegate> {
    LTHTrip *_trip;
    NSTimer *_timer;
}

@property (nonatomic) CLLocationManager *manager;

@end

@implementation LTHLocationManager

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        self.manager = [[CLLocationManager alloc] init];
        self.manager.delegate = self;
        
        self.manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        self.manager.distanceFilter = kCLDistanceFilterNone; // meters
        self.manager.pausesLocationUpdatesAutomatically = YES;
        self.manager.activityType = CLActivityTypeAutomotiveNavigation;
        
        _timer = [NSTimer scheduledTimerWithTimeInterval:kTimerInterval
                                                  target:self
                                                selector:@selector(endTrip)
                                                userInfo:nil
                                                 repeats:YES];
    }
    
    return self;
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

- (void)startStandardUpdates
{
    [self.manager startUpdatingLocation];
}

- (void)stopStandardUpdates
{
    [self.manager stopUpdatingLocation];
}

#pragma mark Location Manager Delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    for (CLLocation *location in locations) {
        NSInteger mph = location.speed * kMPHRatio;

        //A given location is moving at 10 miles per hour.  Create a trip if we haven't already.
        if (mph >= kMinMPH) {
            NSLog(@"Speed in MPH: %ld", mph);
            
            if (_trip == nil) {
                //Not tracking a trip, create a new trip.
                NSLog(@"Creating trip.");
                _trip = [[LTHTrip alloc] initWithFirstLocation:[locations firstObject]];
            }
        }
    }
    
    _trip.lastLocation = [locations lastObject];
}

- (void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager
{
    NSLog(@"locationManagerDidPauseLocationUpdates");
}

- (void)locationManagerDidResumeLocationUpdates:(CLLocationManager *)manager
{
    NSLog(@"locationManagerDidResumeLocationUpdates");
}

- (void)endTrip
{
    NSLog(@"End Trip Called.");
    NSTimeInterval intervalSinceLastUpdate = [[NSDate date] timeIntervalSinceDate:_trip.lastLocation.timestamp];
    
    if (intervalSinceLastUpdate > kDeviceIdleTime) {
        NSLog(@"The device has been still for %f seconds.", intervalSinceLastUpdate);
    }
}


@end
