//
//  LTHLocationManager.h
//  LyftTripHistory
//
//  Created by Justin Steffen on 5/7/15.
//  Copyright (c) 2015 Justin Steffen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LTHTripStore.h"

@class LTHLocationManager;

@protocol LTHLocationManagerDelegate <NSObject>

- (void)trackingStatusDidUpdate:(BOOL)status;

@end

@interface LTHLocationManager : NSObject

@property (nonatomic, readonly) BOOL isAuthorized;
@property (nonatomic) id<LTHLocationManagerDelegate> delegate;

- (instancetype)initWithTripStore:(LTHTripStore *)tripStore;

- (void)setTripLogging:(BOOL)enabled;

- (BOOL)currentState;


@end
