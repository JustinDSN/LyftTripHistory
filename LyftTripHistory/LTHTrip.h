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
@property (nonatomic, copy) NSString *firstLocationAddress;
@property (nonatomic) CLLocation *lastLocation;
@property (nonatomic, copy) NSString *lastLocationAddress;

- (instancetype)initWithFirstLocation:(CLLocation *)location;

- (NSString *)durationDescription;
- (NSString *)titleDescription;

@end
