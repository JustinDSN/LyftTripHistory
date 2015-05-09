//
//  LTHLocationManager.h
//  LyftTripHistory
//
//  Created by Justin Steffen on 5/7/15.
//  Copyright (c) 2015 Justin Steffen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LTHTripStore.h"

typedef NS_ENUM(int, LTHTripLoggingStatus) {
    LTHTripLoggingStatusNotDetermined = 0,
    LTHTripLoggingStatusDenied,
    LTHTripLoggingStatusRequestRequired,
    LTHTripLoggingStatusAuthorizedOn,
    LTHTripLoggingStatusAuthorizedOff
};

@class LTHLocationManager;

@protocol LTHLocationManagerDelegate <NSObject>

- (void)trackingStatusDidUpdate:(BOOL)status;

@end

@interface LTHLocationManager : NSObject

@property (nonatomic) id<LTHLocationManagerDelegate> delegate;
@property (nonatomic, readonly) LTHTripLoggingStatus tripLoggingStatus;

- (instancetype)initWithTripStore:(LTHTripStore *)tripStore;

- (void)setTripLogging:(BOOL)enabled;

@end
