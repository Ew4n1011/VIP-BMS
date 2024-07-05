//
//  SettingPickerView.h
//  VIP-BMS
//
//  Created by goorume on 2020/5/10.
//  Copyright © 2020 goorume. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VIP-BMS-pch.h"

NS_ASSUME_NONNULL_BEGIN

@interface SettingPickerView : UIView<UIPickerViewDelegate, UIPickerViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;

@property (weak, nonatomic) IBOutlet UIButton *cancleButton;
@property (weak, nonatomic) IBOutlet UIButton *okButton;


@property (nonatomic, strong) NSArray *valueArray;
@property (nonatomic, copy) NSString *valueString;

@end

NS_ASSUME_NONNULL_END
