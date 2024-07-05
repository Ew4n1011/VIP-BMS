//
//  SettingFieldView.m
//  VIP-BMS
//
//  Created by goorume on 2020/5/9.
//  Copyright © 2020 goorume. All rights reserved.
//

#import "SettingFieldView.h"
#import "Utils.h"

@implementation SettingFieldView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 10.0f;

    self.textField.delegate = self;
    
    [self.okButton setTitleColor:kMAINCOLOR_FRONT forState:UIControlStateNormal];
    [self.okButton setTitle:InternationaString(@"OK") forState:UIControlStateNormal];
    [self.cancelButton setTitle:InternationaString(@"Cancelar") forState:UIControlStateNormal];
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (!self.allow) {
        NSString *tmp = [NSString stringWithFormat:@"%@%@", textField.text, string];
        return [Utils valideLFNumber:tmp];
    }
    return YES;
}





/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
