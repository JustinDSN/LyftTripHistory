//
//  LTHTrip.m
//  LyftTripHistory
//
//  Created by Justin Steffen on 5/7/15.
//  Copyright (c) 2015 Justin Steffen. All rights reserved.
//

@import CoreLocation;
#import "LTHTrip.h"

static NSDateFormatter *sDateFormatter;
static CLGeocoder * sGeocoder;

static const float kMPHRatio = 2.23694;
static const int kMinMPH = 10;
static NSString * const kStreetKey = @"Street";
static NSString * const kLTHTripCompletedKey = @"completed";
static NSString * const kLTHTripFirstLocationAddressKey = @"firstLocationAddress";
static NSString * const kLTHTripFirstLocationKey = @"firstLocation";
static NSString * const kLTHTripLastLocationAddressKey = @"lastLocationAddress";
static NSString * const kLTHTripLastLocationKey = @"lastLocation";

@interface LTHTrip ()

@end

@implementation LTHTrip

#pragma mark Class Methods

+ (BOOL)tripShouldBeginWithLocation:(CLLocation *)location
{
    NSInteger mph = location.speed * kMPHRatio;
    return (mph >= kMinMPH);
}

#pragma mark Properties

- (NSString *)durationDescription
{
    if (!sDateFormatter) {
        sDateFormatter = [[NSDateFormatter alloc] init];
        sDateFormatter.dateFormat = @"h:mma";
        sDateFormatter.AMSymbol = [sDateFormatter.AMSymbol lowercaseString];
        sDateFormatter.PMSymbol = [sDateFormatter.PMSymbol lowercaseString];
    }
    
    NSString *firstLocationTime = [sDateFormatter stringFromDate:self.firstLocation.timestamp];
    NSString *lastLocationTime;
    
    if (!self.isCompleted) {
        lastLocationTime = NSLocalizedString(@"trip_in_progress_string", @"In Progress");
        
        return [NSString stringWithFormat:@"%@-%@", firstLocationTime, lastLocationTime];
    } else {
        lastLocationTime = [sDateFormatter stringFromDate:self.lastLocation.timestamp];
        
        return [NSString stringWithFormat:@"%@-%@ %@", firstLocationTime, lastLocationTime, [self durationComponents]];
    }
}

- (NSString *)titleDescription
{
    NSString *inProgressString = NSLocalizedString(@"trip_in_progress_string", @"In Progress");
    
    NSString *formattedFirstLocationAddress = self.firstLocationAddress ?: inProgressString;
    NSString *formattedSecondLocationAddress = self.lastLocationAddress ?: inProgressString;
    
    if ([formattedFirstLocationAddress isEqualToString:inProgressString]) {
        return formattedFirstLocationAddress;
    } else {
        return [NSString stringWithFormat:@"%@ > %@\n", formattedFirstLocationAddress, formattedSecondLocationAddress];
    }
}

- (void)setCompleted:(BOOL)completed
{
    _completed = completed;
    
    [self reverseGeocodeLastLocation];
}

- (void)setFirstLocation:(CLLocation *)firstLocation
{
    _firstLocation = firstLocation;
    
    [self reverseGeocodeFirstLocation];
}

#pragma mark Instance Methods

- (NSString *)description
{
    NSString *description = [NSString stringWithFormat:@"Trip (Completed: %@)", self.isCompleted ? @"YES" : @"NO"];
    
    return description;
}

- (NSString *)durationComponents
{
    //Calcualate the difference between two dates and build something like (1 hr, 15 min, 25 sec)
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond
                                                                   fromDate:self.firstLocation.timestamp
                                                                     toDate:self.lastLocation.timestamp
                                                                    options:0];
    
    NSMutableArray *componentsArray = [[NSMutableArray alloc] initWithCapacity:3];
    if (components.hour > 0) {
        [componentsArray addObject:[NSString stringWithFormat:@"%ld hr", components.hour]];
    }
    
    if (components.minute > 0) {
        [componentsArray addObject:[NSString stringWithFormat:@"%ld min", components.minute]];
    }
    
    if (components.second > 0) {
        [componentsArray addObject:[NSString stringWithFormat:@"%ld sec", components.second]];
    }
    if (componentsArray.count) {
        return [NSString stringWithFormat:@"(%@)", [componentsArray componentsJoinedByString:@", "]];
    } else {
        return @"";
    }
}

- (void)reverseGeocodeFirstLocation
{
    if (!sGeocoder) {
        sGeocoder = [[CLGeocoder alloc] init];
    }
    
    //Reverse geocode the first location.
    [sGeocoder reverseGeocodeLocation:self.firstLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error) {
            NSLog(@"Error reverse geocoding first location: %@, UserInfo: %@", error.localizedDescription, error.userInfo);
            self.firstLocationAddress = NSLocalizedString(@"error_reverse_geocoding_location", @"Error reverse geocoding location.");
            return;
        }
        
        CLPlacemark *placemark = [placemarks firstObject];
        self.firstLocationAddress = placemark.addressDictionary[kStreetKey];
    }];
}

- (void)reverseGeocodeLastLocation
{
    if (!sGeocoder) {
        sGeocoder = [[CLGeocoder alloc] init];
    }
    
    [sGeocoder reverseGeocodeLocation:self.lastLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error) {
            NSLog(@"Error reverse geocoding last location: %@, UserInfo: %@", error.localizedDescription, error.userInfo);
            self.lastLocationAddress = NSLocalizedString(@"error_reverse_geocoding_location", @"Error reverse geocoding location.");
            return;
        }
        
        CLPlacemark *placemark = [placemarks firstObject];
        self.lastLocationAddress = placemark.addressDictionary[kStreetKey];
    }];
}


#pragma mark NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeBool:self.completed forKey:kLTHTripCompletedKey];
    [aCoder encodeObject:self.firstLocationAddress forKey:kLTHTripFirstLocationAddressKey];
    [aCoder encodeObject:self.firstLocation forKey:kLTHTripFirstLocationKey];
    [aCoder encodeObject:self.lastLocationAddress forKey:kLTHTripLastLocationAddressKey];
    [aCoder encodeObject:self.lastLocation forKey:kLTHTripLastLocationKey];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self) {
        _completed = [aDecoder decodeBoolForKey:kLTHTripCompletedKey];
        _firstLocationAddress = [aDecoder decodeObjectForKey:kLTHTripFirstLocationAddressKey];
        _firstLocation = [aDecoder decodeObjectOfClass:[CLLocation class] forKey:kLTHTripFirstLocationKey];
        _lastLocationAddress = [aDecoder decodeObjectForKey:kLTHTripLastLocationAddressKey];
        _lastLocation = [aDecoder decodeObjectOfClass:[CLLocation class] forKey:kLTHTripLastLocationKey];
    }
    
    return self;
}


@end
