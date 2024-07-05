//
//  DetailCell.m
//  VIP-BMS
//
//  Created by goorume on 2020/4/27.
//  Copyright © 2020 goorume. All rights reserved.
//

#import "DetailCell.h"

@implementation DetailCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    if ([self.reuseIdentifier isEqualToString:@"idfCell1"]) {
        self.labelArrayCell1 = @[self.lb0, self.lb1, self.lb2,
                                 self.lb3, self.lb4, self.lb5];
        
        for (UILabel *lb in self.labelArrayCell1) {
            lb.layer.masksToBounds = YES;
            lb.layer.cornerRadius = 4.0f;
            lb.textColor = UIColor.darkGrayColor;
            lb.backgroundColor = UIColor.groupTableViewBackgroundColor;
        }
    }
    
    if ([self.reuseIdentifier isEqualToString:@"idfCell2"]) {
        self.labelArrayCell2 = @[self.lb0, self.lb1, self.lb2,
                                 self.lb3, self.lb4];
        
        for (UILabel *lb in self.labelArrayCell2) {
            lb.layer.masksToBounds = YES;
            lb.layer.cornerRadius = 4.0f;
            lb.textColor = UIColor.darkGrayColor;
            lb.backgroundColor = UIColor.groupTableViewBackgroundColor;
        }
    }
    
    if ([self.reuseIdentifier isEqualToString:@"idfCell3"]) {
        self.labelArrayCell3 = @[self.lb0, self.lb1, self.lb2,
                                 self.lb3, self.lb4, self.lb5,
                                 self.lb6];
        
        for (UILabel *lb in self.labelArrayCell3) {
            lb.layer.masksToBounds = YES;
            lb.layer.cornerRadius = 4.0f;
            lb.textColor = UIColor.darkGrayColor;
            lb.backgroundColor = UIColor.groupTableViewBackgroundColor;
        }
    }

    if ([self.reuseIdentifier isEqualToString:@"idfCell4"]) {
        self.labelArrayCell4 = @[self.lb0, self.lb1, self.lb2,
                                 self.lb3, self.lb4,
                                 self.lb5, self.lb6,
                                 self.lb7];
        
        for (UILabel *lb in self.labelArrayCell4) {
            lb.layer.masksToBounds = YES;
            lb.layer.cornerRadius = 4.0f;
            lb.textColor = UIColor.darkGrayColor;
            lb.backgroundColor = UIColor.groupTableViewBackgroundColor;
        }
    }
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
