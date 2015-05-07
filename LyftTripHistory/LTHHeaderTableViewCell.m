//
//  LTHHeaderTableViewCell.m
//  LyftTripHistory
//
//  Created by Justin Steffen on 5/7/15.
//  Copyright (c) 2015 Justin Steffen. All rights reserved.
//

#import "LTHHeaderTableViewCell.h"

@implementation LTHHeaderTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)tripLoggingSwitchChanged:(UISwitch *)sender {
    if (self.delegate) {
        [self.delegate headerTableViewCell:self didEnableToggleTripLogging:sender.on];
    }
}

@end
