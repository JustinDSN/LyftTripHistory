//
//  LTHTripStore.m
//  LyftTripHistory
//
//  Created by Justin Steffen on 5/7/15.
//  Copyright (c) 2015 Justin Steffen. All rights reserved.
//

#import "LTHTripStore.h"

@interface LTHTripStore ()

@property (nonatomic) NSMutableArray *privateItems;

@end

@implementation LTHTripStore

+ (instancetype)sharedStore
{
    static LTHTripStore *_sharedStore = nil;
    
    if (!_sharedStore) {
        _sharedStore = [[LTHTripStore alloc] initPrivate];
    }
    
    return _sharedStore;
}

- (instancetype)init
{
    @throw [NSException exceptionWithName:@"Singleton" reason:@"Use + [LTHTripStore sharedStore]" userInfo:nil];
    
    return nil;
}

- (instancetype)initPrivate
{
    self = [super init];
    
    if (self) {
        _privateItems = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (NSArray *)allItems
{
    return self.privateItems;
}

- (LTHTrip *)createItem
{
    LTHTrip *item = [[LTHTrip alloc] init];
    
    [self.privateItems addObject:item];
    
    return item;
}

@end
