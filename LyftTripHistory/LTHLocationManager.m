//
//  LTHLocationManager.m
//  LyftTripHistory
//
//  Created by Justin Steffen on 5/7/15.
//  Copyright (c) 2015 Justin Steffen. All rights reserved.
//

@import CoreLocation;
#import "LTHLocationManager.h"

static int kTimerInterval = 5;
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
    if ([self currentState]) {
        //If we're not tracking a trip, test each location to see if a trip should be created.
        if (_trip == nil) {
            //We're not currently tracking a trip
            for (CLLocation *location in locations) {
                if ([LTHTrip tripShouldBeginWithLocation:location]) {
                    [self createTripForLocation:location];
                }
            }
        } else {
            //Update the existing trip's last location with the last location received.
            [self updateTripLastLocation:[locations lastObject]];
        }
    }
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

#pragma mark - Trip Helper Methods

- (void)createTripForLocation:(CLLocation *)location
{
    NSLog(@"Creating trip.");
    
    _trip = [self.tripStore createItem];
    _trip.firstLocation = location;
    
    //Reverse geocode the first location.
    [self.geocoder reverseGeocodeLocation:_trip.firstLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error) {
            NSLog(@"Error reverse geocoding first location: %@, UserInfo: %@", error.localizedDescription, error.userInfo);
            _trip.firstLocationAddress = NSLocalizedString(@"error_reverse_geocoding_location", @"Error reverse geocoding location.");
            return;
        }
        
        CLPlacemark *placemark = [placemarks firstObject];
        _trip.firstLocationAddress = placemark.addressDictionary[kStreetKey];
    }];
}

- (void)updateTripLastLocation:(CLLocation *)location
{
    _trip.lastLocation = location;
    
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

- (void)endTrip
{
    NSLog(@"Timer Fired");
    
    LTHTrip *tempTrip = _trip;
    _trip = nil;
    
    [self.geocoder reverseGeocodeLocation:tempTrip.lastLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error) {
            NSLog(@"Error reverse geocoding last location: %@, UserInfo: %@", error.localizedDescription, error.userInfo);
            _trip.lastLocationAddress = NSLocalizedString(@"error_reverse_geocoding_location", @"Error reverse geocoding location.");
            return;
        }
        
        CLPlacemark *placemark = [placemarks firstObject];
        tempTrip.lastLocationAddress = placemark.addressDictionary[kStreetKey];
        
        NSLog(@"Trip completed.  Trip %@", tempTrip);
    }];
}

- (BOOL)currentState
{
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    return [standardDefaults boolForKey:LTHUserDefaultsKeyToggleSwitchEnabled];
}

- (BOOL)toggleSwitchStateWithStatus:(CLAuthorizationStatus)newStatus toggleSwitchState:(BOOL)toggleSwitchState
{
    BOOL finalState;
    
    if (toggleSwitchState) {
        switch (newStatus) {
            case kCLAuthorizationStatusNotDetermined:
                //Ask user for permission
                [self.manager requestWhenInUseAuthorization];
                finalState = NO;
                break;
            case kCLAuthorizationStatusDenied:
            case kCLAuthorizationStatusRestricted:
                //Can't turn on switch, because location services is denied or restricted
                finalState = NO;
                //TODO: Alert view controller not enabled
                break;
            case kCLAuthorizationStatusAuthorizedAlways:
            case kCLAuthorizationStatusAuthorizedWhenInUse:
                //Can turn on switch, location services was allowed by user.
                finalState = YES;
                //Start updating location
                [self.manager startUpdatingLocation];
                break;
        }
    } else {
        [self.manager stopUpdatingLocation];  //Stop updating location ASAP
        finalState = NO;
        
        if (_timer) {
            [_timer fire];
            [_timer invalidate];
            _timer = nil;
        }
    }
    
    if ([self currentState] != finalState) {
        //Save finalState to NSUserDefaults
        NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
        [standardDefaults setBool:finalState forKey:LTHUserDefaultsKeyToggleSwitchEnabled];
        
        //Notify delegate
        [self.delegate trackingStatusDidUpdate:finalState];
    }
    
    return finalState;
}
@end
