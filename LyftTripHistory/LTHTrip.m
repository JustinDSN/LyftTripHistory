//
//  LTHTrip.m
//  LyftTripHistory
//
//  Created by Justin Steffen on 5/7/15.
//  Copyright (c) 2015 Justin Steffen. All rights reserved.
//

#import "LTHTrip.h"

@implementation LTHTrip

- (instancetype)initWithFirstLocation:(CLLocation *)location
{
    self = [super init];
    
    if (self) {
        self.firstLocation = location;
    }
    
    return self;
}

- (NSString *)description
{
    NSMutableString *description = [[NSMutableString alloc] init];
    [description appendFormat:@"%@\n", self.titleDescription];
    [description appendFormat:@"%@\n", self.durationDescription];
    
    return description;
}

- (NSString *)durationDescription
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterNoStyle;
    dateFormatter.timeStyle = NSDateFormatterMediumStyle;
    
    NSString *firstLocationTime = [dateFormatter stringFromDate:self.firstLocation.timestamp];
    NSString *lastLocationTime = [dateFormatter stringFromDate:self.lastLocation.timestamp];
    
//    NSTimeInterval timeInterval = [self.lastLocation.timestamp timeIntervalSinceDate:self.firstLocation.timestamp];
//    NSInteger hours = (int)interval / 3600;             // integer division to get the hours part
//    NSInteger minutes = (interval - (hours*3600)) / 60; // interval minus hours part (in seconds) divided by 60 yields minutes
//    NSString *timeDiff = [NSString stringWithFormat:@"%d:%02d", hours, minutes];
    
    NSString *durationDescription = [NSString stringWithFormat:@"%@ - %@", firstLocationTime, lastLocationTime];
    
    return durationDescription;
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

@end
