//
//  LTHTrip.h
//  LyftTripHistory
//
//  Created by Justin Steffen on 5/7/15.
//  Copyright (c) 2015 Justin Steffen. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreLocation;

@interface LTHTrip : NSObject

@property (nonatomic) CLLocation *firstLocation;
@property (nonatomic) CLLocation *lastLocation;

- (instancetype)initWithFirstLocation:(CLLocation *)location;

- (NSString *)durationDescription;

@end
