//
//  BatteryInfoView.h
//  VIP-BMS
//
//  Created by _G.R.M. on 2021/3/4.
//  Copyright © 2021 goorume. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BatteryInfoView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;



@property (weak, nonatomic) IBOutlet UILabel *titLabel;

@end

NS_ASSUME_NONNULL_END
