//
//  LTHTrip.m
//  LyftTripHistory
//
//  Created by Justin Steffen on 5/7/15.
//  Copyright (c) 2015 Justin Steffen. All rights reserved.
//

#import "LTHTrip.h"

static float kMPHRatio = 2.23694;
static int kMinMPH = 10;

//Cache date formatter for efficiency
static NSDateFormatter *sDateFormatter;

static NSString * const kLTHTripFirstLocationAddressKey = @"firstLocationAddress";
static NSString * const kLTHTripFirstLocationKey = @"firstLocation";
static NSString * const kLTHTripLastLocationAddressKey = @"lastLocationAddress";
static NSString * const kLTHTripLastLocationKey = @"lastLocation";

@interface LTHTrip ()

@property (nonatomic, readonly, getter=isInProgress) BOOL inProgress;

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
    
    if (self.isInProgress) {
        lastLocationTime = NSLocalizedString(@"trip_in_progress_string", @"In Progress");
        
        return [NSString stringWithFormat:@"%@-%@", firstLocationTime, lastLocationTime];
    } else {
        lastLocationTime = [sDateFormatter stringFromDate:self.lastLocation.timestamp];
        
        return [NSString stringWithFormat:@"%@-%@ %@", firstLocationTime, lastLocationTime, [self durationComponents]];
    }
}

- (BOOL)isInProgress
{
    return self.lastLocationAddress == nil;
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

#pragma mark Instance Methods

- (NSString *)description
{
    NSString *description = [NSString stringWithFormat:@"%@ - %@", self.titleDescription, self.durationDescription];
    
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

#pragma mark NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.firstLocationAddress forKey:kLTHTripFirstLocationAddressKey];
    [aCoder encodeObject:self.firstLocation forKey:kLTHTripFirstLocationKey];
    [aCoder encodeObject:self.lastLocationAddress forKey:kLTHTripLastLocationAddressKey];
    [aCoder encodeObject:self.lastLocation forKey:kLTHTripLastLocationKey];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self) {
        _firstLocationAddress = [aDecoder decodeObjectForKey:kLTHTripFirstLocationAddressKey];
        _firstLocation = [aDecoder decodeObjectOfClass:[CLLocation class] forKey:kLTHTripFirstLocationKey];
        _lastLocationAddress = [aDecoder decodeObjectForKey:kLTHTripLastLocationAddressKey];
        _lastLocation = [aDecoder decodeObjectOfClass:[CLLocation class] forKey:kLTHTripLastLocationKey];
    }
    
    return self;
}


@end
