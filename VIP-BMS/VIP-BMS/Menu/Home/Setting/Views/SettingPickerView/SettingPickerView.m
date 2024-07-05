//
//  SettingPickerView.m
//  VIP-BMS
//
//  Created by goorume on 2020/5/10.
//  Copyright © 2020 goorume. All rights reserved.
//

#import "SettingPickerView.h"

@implementation SettingPickerView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 10.0f;
    
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    
    [self.okButton setTitle:InternationaString(@"OK") forState:UIControlStateNormal];
    [self.cancleButton setTitle:InternationaString(@" Cancelar") forState:UIControlStateNormal];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.valueArray.count;
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [self.valueArray objectAtIndex:row];
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.valueString = [self.valueArray objectAtIndex:row];
}

- (void)setValueArray:(NSArray *)valueArray {
    _valueArray = valueArray;
    
    if (valueArray.count) {
        _valueString = [valueArray objectAtIndex:0];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
