//
//  LTHTrip.h
//  LyftTripHistory
//
//  Created by Justin Steffen on 5/7/15.
//  Copyright (c) 2015 Justin Steffen. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreLocation;

@interface LTHTrip : NSObject <NSCoding>

@property (nonatomic, readonly) NSString *durationDescription;
@property (nonatomic) CLLocation *firstLocation;
@property (nonatomic, copy) NSString *firstLocationAddress;
@property (nonatomic) CLLocation *lastLocation;
@property (nonatomic, copy) NSString *lastLocationAddress;
@property (nonatomic, readonly) NSString *titleDescription;

+ (BOOL)tripShouldBeginWithLocation:(CLLocation *)location;

@end
