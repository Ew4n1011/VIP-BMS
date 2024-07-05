//
//  BatteryView.h
//  VIP-BMS
//
//  Created by goorume on 2020/4/26.
//  Copyright © 2020 goorume. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BatteryView : UIView

@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIImageView *jhztImageView; // 均衡状态

@end

NS_ASSUME_NONNULL_END
