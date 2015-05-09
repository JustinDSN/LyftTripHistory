//
//  LTHTripStore.h
//  LyftTripHistory
//
//  Created by Justin Steffen on 5/7/15.
//  Copyright (c) 2015 Justin Steffen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LTHTrip.h"

@class LTHTripStore;

@protocol LTHTripStoreDelegate <NSObject>

- (void)tripStore:(LTHTripStore *)tripStore didCreateItem:(LTHTrip *)item;
- (void)tripStore:(LTHTripStore *)tripStore didUpdateItem:(LTHTrip *)item;

@end

@interface LTHTripStore : NSObject

@property (nonatomic, readonly) NSArray *allItems;
@property (nonatomic, weak) id<LTHTripStoreDelegate> delegate;

+ (instancetype)sharedStore;

- (LTHTrip *)createItem;

- (BOOL)saveChanges;

@end
