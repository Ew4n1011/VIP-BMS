//
//  DeviceCell.m
//  VIP-BMS
//
//  Created by goorume on 2020/4/26.
//  Copyright © 2020 goorume. All rights reserved.
//

#import "DeviceCell.h"

@implementation DeviceCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.bgView.layer.masksToBounds = YES;
    self.bgView.layer.cornerRadius = 8.0f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
