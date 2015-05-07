//
//  LTHLocationManager.h
//  LyftTripHistory
//
//  Created by Justin Steffen on 5/7/15.
//  Copyright (c) 2015 Justin Steffen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LTHLocationManager : NSObject

@property (nonatomic, readonly) BOOL isAuthorized;

- (BOOL)requestPermission;

@end
