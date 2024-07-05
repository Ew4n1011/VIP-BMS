//
//  DeviceCell.h
//  VIP-BMS
//
//  Created by goorume on 2020/4/26.
//  Copyright © 2020 goorume. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DeviceCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *bgView;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *idfLabel;
@property (weak, nonatomic) IBOutlet UILabel *rssiLabel;

@end

NS_ASSUME_NONNULL_END
