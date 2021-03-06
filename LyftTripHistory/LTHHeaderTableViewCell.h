//
//  LTHHeaderTableViewCell.h
//  LyftTripHistory
//
//  Created by Justin Steffen on 5/7/15.
//  Copyright (c) 2015 Justin Steffen. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LTHHeaderTableViewCell;

@protocol LTHHeaderTableViewCellDelegate <NSObject>

- (void)headerTableViewCell:(LTHHeaderTableViewCell *)cell didChangeToggleSwitch:(UISwitch *)toggleSwitch;

@end

@interface LTHHeaderTableViewCell : UITableViewCell

@property (nonatomic, weak) id<LTHHeaderTableViewCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UISwitch *toggleSwitch;

@end
