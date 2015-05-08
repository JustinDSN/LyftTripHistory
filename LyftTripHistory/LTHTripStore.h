//
//  LTHTripStore.h
//  LyftTripHistory
//
//  Created by Justin Steffen on 5/7/15.
//  Copyright (c) 2015 Justin Steffen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LTHTrip.h"

@interface LTHTripStore : NSObject

@property (nonatomic, readonly) NSArray *allItems;

+ (instancetype)sharedStore;

- (LTHTrip *)createItem;

@end
