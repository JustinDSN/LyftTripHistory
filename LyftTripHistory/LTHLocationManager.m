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
    LTHTripLoggingStatus _tripLoggingStatus;
    LTHTrip *_trip;
    NSTimer *_timer;
    BOOL _userRequestedTripLogging;
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
        
        _tripLoggingStatus = [self loggingStatusForStatus:[CLLocationManager authorizationStatus] tripLogging:_userRequestedTripLogging];
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

- (LTHTripLoggingStatus)tripLoggingStatus
{
    return _tripLoggingStatus;
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
    _userRequestedTripLogging = enabled;
    [self changeAuthorizationToStatus:[CLLocationManager authorizationStatus] tripLogging:enabled];
}

#pragma mark Location Manager Delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    if ([self boolForLoggingStatus:_tripLoggingStatus]) {
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
    [self changeAuthorizationToStatus:status tripLogging:_userRequestedTripLogging];
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

- (BOOL)boolForLoggingStatus:(LTHTripLoggingStatus)status
{
    switch (status) {
        case LTHTripLoggingStatusAuthorizedOff:
        case LTHTripLoggingStatusDenied:
        case LTHTripLoggingStatusNotDetermined:
        case LTHTripLoggingStatusRequestRequired:
            return NO;
            break;
        case LTHTripLoggingStatusAuthorizedOn:
            return YES;
            break;
    }
}

- (LTHTripLoggingStatus)loggingStatusForStatus:(CLAuthorizationStatus)status tripLogging:(BOOL)tripLogging
{
    LTHTripLoggingStatus result = LTHTripLoggingStatusNotDetermined;
    
    if (tripLogging) {
        switch (status) {
            case kCLAuthorizationStatusAuthorizedAlways:
            case kCLAuthorizationStatusAuthorizedWhenInUse:
                result = LTHTripLoggingStatusAuthorizedOn;
                break;
            case kCLAuthorizationStatusDenied:
            case kCLAuthorizationStatusRestricted:
                result = LTHTripLoggingStatusDenied;
                break;
            case kCLAuthorizationStatusNotDetermined:
                result = LTHTripLoggingStatusRequestRequired;
                break;
        }
    } else {
        switch (status) {
            case kCLAuthorizationStatusAuthorizedAlways:
            case kCLAuthorizationStatusAuthorizedWhenInUse:
                result = LTHTripLoggingStatusAuthorizedOff;
                break;
            case kCLAuthorizationStatusDenied:
            case kCLAuthorizationStatusRestricted:
                result = LTHTripLoggingStatusDenied;
                break;
            case kCLAuthorizationStatusNotDetermined:
                result = LTHTripLoggingStatusNotDetermined;
                break;
        }
    }
    
    return result;
}

- (void)changeAuthorizationToStatus:(CLAuthorizationStatus)status tripLogging:(BOOL)tripLogging
{
    LTHTripLoggingStatus newTripLoggingStatus = [self loggingStatusForStatus:status tripLogging:tripLogging];
    
    switch (_tripLoggingStatus) {
        case LTHTripLoggingStatusAuthorizedOff:
            switch (newTripLoggingStatus) {
                case LTHTripLoggingStatusAuthorizedOff:
                    //Do nothing, no change.
                    break;
                case LTHTripLoggingStatusAuthorizedOn:
                    [self.manager startUpdatingLocation];
                    break;
                case LTHTripLoggingStatusDenied:
                    //Do nothing, no change.
                    //TODO Notify view controller
                    break;
                default:
                    NSLog(@"Unexpected newStatus of %d for LTHTripLoggingStatusAuthorizedOn", newTripLoggingStatus);
                    break;
            }
            break;
        case LTHTripLoggingStatusAuthorizedOn:
            switch (newTripLoggingStatus) {
                case LTHTripLoggingStatusAuthorizedOff:
                    [self.manager stopUpdatingLocation];
                    [self fireAndInvalidateTimer];
                    break;
                case LTHTripLoggingStatusAuthorizedOn:
                    [self.manager startUpdatingLocation];
                    break;
                case LTHTripLoggingStatusDenied:
                    [self.manager stopUpdatingLocation];
                    [self fireAndInvalidateTimer];
                    break;
                default:
                    NSLog(@"Unexpected newStatus of %d for LTHTripLoggingStatusAuthorizedOn", newTripLoggingStatus);
                    break;
            }
            break;
        case LTHTripLoggingStatusDenied:
            switch (newTripLoggingStatus) {
                case LTHTripLoggingStatusAuthorizedOff:
                    //Do nothing, user doesn't want to start logging.
                    break;
                case LTHTripLoggingStatusAuthorizedOn:
                    [self.manager startUpdatingLocation];
                    break;
                case LTHTripLoggingStatusDenied:
                    //TODO Notify view controller
                    break;
                default:
                    NSLog(@"Unexpected newStatus of %d for LTHTripLoggingStatusDenied", newTripLoggingStatus);
                    break;
            }
            break;
        case LTHTripLoggingStatusNotDetermined:
            switch (newTripLoggingStatus) {
                case LTHTripLoggingStatusRequestRequired:
                    [self.manager requestWhenInUseAuthorization];
                    break;
                default:
                    NSLog(@"Unexpected newStatus of %d for LTHTripLoggingStatusNotDetermined", newTripLoggingStatus);
                    break;
            }
            break;
        case LTHTripLoggingStatusRequestRequired:
            switch (newTripLoggingStatus) {
                case LTHTripLoggingStatusAuthorizedOn:
                    [self.manager startUpdatingLocation];
                    break;
                case LTHTripLoggingStatusDenied:
                    //Do nothing, no change.
                    //Alert view controller of denial
                    break;
                default:
                    NSLog(@"Unexpected newStatus of %d for LTHTripLoggingStatusRequestRequired", newTripLoggingStatus);
                    break;
            }
            break;
    }
    
    _tripLoggingStatus = newTripLoggingStatus;
    
    //Convert newLoggingStatus to bool
    BOOL loggingEnabled = [self boolForLoggingStatus:newTripLoggingStatus];
    
    //Save finalState to NSUserDefaults
//    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
//    [standardDefaults setBool:loggingEnabled forKey:LTHUserDefaultsKeyToggleSwitchEnabled];
    
    //Notify delegate
    [self.delegate trackingStatusDidUpdate:loggingEnabled];
}

- (void)fireAndInvalidateTimer
{
    //Invalidate timer if we had one
    if (_timer) {
        [_timer fire];
        [_timer invalidate];
        _timer = nil;
    }
}

@end
