//
//  LTHLocationManager.h
//  LyftTripHistory
//
//  Created by Justin Steffen on 5/7/15.
//  Copyright (c) 2015 Justin Steffen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LTHTripStore.h"

@interface LTHLocationManager : NSObject

@property (nonatomic, readonly) BOOL isAuthorized;

- (instancetype)initWithTripStore:(LTHTripStore *)tripStore;

- (BOOL)requestPermission;
- (void)startStandardUpdates;
- (void)stopStandardUpdates;

@end
