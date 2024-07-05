//
//  SettingFieldView.h
//  VIP-BMS
//
//  Created by goorume on 2020/5/9.
//  Copyright © 2020 goorume. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VIP-BMS-pch.h"

NS_ASSUME_NONNULL_BEGIN

@interface SettingFieldView : UIView <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextField *textField;


@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *okButton;


@property (nonatomic, assign) BOOL allow;

@end

NS_ASSUME_NONNULL_END
