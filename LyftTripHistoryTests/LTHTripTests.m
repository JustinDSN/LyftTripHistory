//
//  LTHTripTests.m
//  LyftTripHistory
//
//  Created by Justin Steffen on 5/8/15.
//  Copyright (c) 2015 Justin Steffen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "LTHTrip.h"

@interface LTHTripTests : XCTestCase {
    NSString *_inProgressString;
}

@end

@implementation LTHTripTests

- (void)setUp
{
    _inProgressString = NSLocalizedString(@"trip_in_progress_string", @"In Progress");
}

- (void)testTitleDescriptionWhenFirstLocationAddressIsNil
{
    LTHTrip *trip = [[LTHTrip alloc] init];
    
    XCTAssertEqualObjects([trip titleDescription], _inProgressString);
}

- (void)testTitleDescriptionWhenFirstLocationAddressIsNotNil
{
    LTHTrip *trip = [[LTHTrip alloc] init];
    
    trip.firstLocationAddress = @"asdf";
    
    NSString *expected = [NSString stringWithFormat:@"%@ > %@\n", trip.firstLocationAddress, _inProgressString];
    
    XCTAssertEqualObjects([trip titleDescription], expected);
}

- (void)testTitleDescriptionWhenBothAddressesAreNotNil
{
    LTHTrip *trip = [[LTHTrip alloc] init];
    
    trip.firstLocationAddress = @"asdf";
    trip.lastLocationAddress = @"qwerty";
    
    NSString *expected = [NSString stringWithFormat:@"%@ > %@\n", trip.firstLocationAddress, trip.lastLocationAddress];
    
    XCTAssertEqualObjects([trip titleDescription], expected);
}



@end
