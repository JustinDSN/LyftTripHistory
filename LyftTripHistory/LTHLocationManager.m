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

@interface LTHLocationManager () <CLLocationManagerDelegate> {
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
        
        _timer = [NSTimer scheduledTimerWithTimeInterval:kTimerInterval
                                                  target:self
                                                selector:@selector(endTrip)
                                                userInfo:nil
                                                 repeats:YES];
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
}

- (void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager
{
    NSLog(@"locationManagerDidPauseLocationUpdates");
}

- (void)locationManagerDidResumeLocationUpdates:(CLLocationManager *)manager
{
    NSLog(@"locationManagerDidResumeLocationUpdates");
}

#pragma mark - Helper Methods

- (void)endTrip
{
    NSLog(@"Timer Fired");
    
    if (_trip) {
        NSTimeInterval intervalSinceLastUpdate = [[NSDate date] timeIntervalSinceDate:_trip.lastLocation.timestamp];
        
        if (intervalSinceLastUpdate > kDeviceIdleTime) {
            NSLog(@"The device has been still for %f seconds.", intervalSinceLastUpdate);
            
            if (!_trip.lastLocationAddress) {
                [self.geocoder reverseGeocodeLocation:_trip.lastLocation completionHandler:^(NSArray *placemarks, NSError *error) {
                    if (error) {
                        NSLog(@"Error: %@, UserInfo: %@", error.localizedDescription, error.userInfo);
                    }
                    
                    CLPlacemark *placemark = [placemarks firstObject];
                    _trip.lastLocationAddress = placemark.addressDictionary[kStreetKey];
                    
                    NSLog(@"Trip has been completed. Trip %@", _trip);
                    _trip = nil;
                }];
            }
        }
    }
}
@end
