//
//  LTHLocationManager.m
//  LyftTripHistory
//
//  Created by Justin Steffen on 5/7/15.
//  Copyright (c) 2015 Justin Steffen. All rights reserved.
//

@import CoreLocation;
#import "LTHLocationManager.h"

static float kMPHRatio = 2.23694;
static int kMinMPH = 10;
static int kTimerInterval = 5;
static int kDeviceIdleTime = 5;
static NSString *kStreetKey = @"Street";
static NSString * const LTHUserDefaultsKeyToggleSwitchEnabled = @"LTHUserDefaultsKeyToggleSwitchEnabled";

@interface LTHLocationManager () <CLLocationManagerDelegate> {
    CLAuthorizationStatus _authorizationStatus;
    LTHTrip *_trip;
    NSTimer *_timer;
}

@property (nonatomic) CLGeocoder *geocoder;
@property (nonatomic) CLLocationManager *manager;
@property (nonatomic) LTHTripStore *tripStore;

@end

@implementation LTHLocationManager

- (instancetype)init
{
    return [self initWithTripStore:[LTHTripStore sharedStore]];
}

- (instancetype)initWithTripStore:(LTHTripStore *)tripStore
{
    self = [super init];
    
    if (self) {
        self.tripStore = tripStore;
        
        self.manager = [[CLLocationManager alloc] init];
        self.manager.delegate = self;
        
        self.manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        self.manager.distanceFilter = kCLDistanceFilterNone; // meters
        self.manager.pausesLocationUpdatesAutomatically = YES;
        self.manager.activityType = CLActivityTypeAutomotiveNavigation;
        
        _authorizationStatus = [CLLocationManager authorizationStatus];
    }
    
    return self;
}

#pragma mark - Properties

- (CLGeocoder *)geocoder
{
    if (!_geocoder) {
        _geocoder = [[CLGeocoder alloc] init];
    }
    
    return _geocoder;
}

#pragma mark - Methods

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

- (void)setTripLogging:(BOOL)enabled
{
    [self toggleSwitchStateWithStatus:[CLLocationManager authorizationStatus] toggleSwitchState:enabled];
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
                
                _trip = [self.tripStore createItem];
                _trip.firstLocation = [locations firstObject];
                
                //Reverse geocode the first location.
                [self.geocoder reverseGeocodeLocation:_trip.firstLocation completionHandler:^(NSArray *placemarks, NSError *error) {
                    if (error) {
                        NSLog(@"Error: %@, UserInfo: %@", error.localizedDescription, error.userInfo);
                    }
                    
                    CLPlacemark *placemark = [placemarks firstObject];
                    _trip.firstLocationAddress = placemark.addressDictionary[kStreetKey];
                }];
            }
        }
    }
    
    _trip.lastLocation = [locations lastObject];

    //Reset timer
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:kTimerInterval
                                              target:self
                                            selector:@selector(endTrip)
                                            userInfo:nil
                                             repeats:NO];
}

- (void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager
{
    NSLog(@"locationManagerDidPauseLocationUpdates");
}

- (void)locationManagerDidResumeLocationUpdates:(CLLocationManager *)manager
{
    NSLog(@"locationManagerDidResumeLocationUpdates");
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    BOOL currentToggleSwitchState = [standardDefaults boolForKey:LTHUserDefaultsKeyToggleSwitchEnabled];
    
    [self toggleSwitchStateWithStatus:status toggleSwitchState:currentToggleSwitchState];
}

#pragma mark - Helper Methods

- (void)endTrip
{
    NSLog(@"Timer Fired");
    
    LTHTrip *tempTrip = _trip;
    _trip = nil;
    
    [self.geocoder reverseGeocodeLocation:tempTrip.lastLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error) {
            NSLog(@"Error: %@, UserInfo: %@", error.localizedDescription, error.userInfo);
        }
        
        CLPlacemark *placemark = [placemarks firstObject];
        tempTrip.lastLocationAddress = placemark.addressDictionary[kStreetKey];
        
        NSLog(@"Trip has been completed. Trip %@", tempTrip);
    }];
}

- (BOOL)currentState
{
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    return [standardDefaults boolForKey:LTHUserDefaultsKeyToggleSwitchEnabled];
}

- (BOOL)toggleSwitchStateWithStatus:(CLAuthorizationStatus)newStatus toggleSwitchState:(BOOL)toggleSwitchState
{
    BOOL result;
    
    if (_authorizationStatus == kCLAuthorizationStatusNotDetermined)
    {
        if (newStatus == kCLAuthorizationStatusNotDetermined && toggleSwitchState) {
            [self.manager requestWhenInUseAuthorization];
            result = NO;
        } else if (newStatus == kCLAuthorizationStatusDenied || newStatus == kCLAuthorizationStatusRestricted) {
            result = NO;
        } else if (newStatus == kCLAuthorizationStatusAuthorizedWhenInUse || newStatus == kCLAuthorizationStatusAuthorizedAlways) {
            result =  YES;
        }
    } else if (_authorizationStatus == kCLAuthorizationStatusAuthorizedAlways || _authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse) {
        if (newStatus == kCLAuthorizationStatusDenied || newStatus == kCLAuthorizationStatusRestricted) {
            result = NO;
        } else if (!toggleSwitchState) {
            [_timer fire];
            result = NO;
        } else {
            result = toggleSwitchState;
        }
    } else if (_authorizationStatus == kCLAuthorizationStatusDenied || _authorizationStatus == kCLAuthorizationStatusRestricted) {
        if (newStatus == kCLAuthorizationStatusAuthorizedAlways || newStatus == kCLAuthorizationStatusAuthorizedWhenInUse) {
            result = NO;
        }
    }
    
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    [standardDefaults setBool:result forKey:LTHUserDefaultsKeyToggleSwitchEnabled];
    
    _authorizationStatus = newStatus;
    
    if (result) {
        [self.manager startUpdatingLocation];
    } else {
        [self.manager stopUpdatingLocation];
    }
    
    [self.delegate trackingStatusDidUpdate:result];
    
    return result;
}
@end
