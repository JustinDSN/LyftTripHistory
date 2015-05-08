//
//  LTHTrip.m
//  LyftTripHistory
//
//  Created by Justin Steffen on 5/7/15.
//  Copyright (c) 2015 Justin Steffen. All rights reserved.
//

#import "LTHTrip.h"

//Cache date formatter for efficiency
static NSDateFormatter *sDateFormatter;

@implementation LTHTrip

+ (void)initialize
{
    if (!sDateFormatter) {
        sDateFormatter = [[NSDateFormatter alloc] init];
        sDateFormatter.dateFormat = @"h:mma";
        sDateFormatter.AMSymbol = [sDateFormatter.AMSymbol lowercaseString];
        sDateFormatter.PMSymbol = [sDateFormatter.PMSymbol lowercaseString];
    }
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
    NSString *firstLocationTime = [sDateFormatter stringFromDate:self.firstLocation.timestamp];
    NSString *lastLocationTime = [sDateFormatter stringFromDate:self.lastLocation.timestamp];
    
//    NSTimeInterval timeInterval = [self.lastLocation.timestamp timeIntervalSinceDate:self.firstLocation.timestamp];
//    NSInteger hours = (int)interval / 3600;             // integer division to get the hours part
//    NSInteger minutes = (interval - (hours*3600)) / 60; // interval minus hours part (in seconds) divided by 60 yields minutes
//    NSString *timeDiff = [NSString stringWithFormat:@"%d:%02d", hours, minutes];
    
    NSString *durationDescription = [NSString stringWithFormat:@"%@-%@", firstLocationTime, lastLocationTime];
    
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
