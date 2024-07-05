//
//  SettingController.m
//  VIP-BMS
//
//  Created by goorume on 2020/5/6.
//  Copyright © 2020 goorume. All rights reserved.
//

#import "SettingController.h"
#import "BaseTabBarController.h"

#import "SettingCell.h"
#import "SettingFieldView.h"
#import "SettingPickerView.h"

@interface SettingController ()

@end

@implementation SettingController {
    NSArray *_configArray;
    
    NSArray *_opArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = InternationaString(@"Programación");
    
    [self loadDataSource];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [APP stopTimer];
    
    SettingFieldView *view = [[[NSBundle mainBundle] loadNibNamed:@"SettingFieldView" owner:nil options:nil] firstObject];
    view.titleLabel.text = InternationaString(@"Por favor, introduzca contraseña");
    view.textField.placeholder = InternationaString(@"  Longitud de contraseña: 6-15");
    view.allow = YES;
    view.bounds = CGRectMake(0, 0, SCREEN_WIDTH-32*2, 200);
    [GRMAlertManager showAlertView:view configClickEvent:^NSArray *(UIView *alert) {
        return @[view.cancelButton, view.okButton];
    } didSelectedBlock:^(NSInteger index, UIView *alert) {
        if (index == 1) {
            if ([view.textField.text isEqualToString:UserPassword]) {
                [UITools startLoading];
                [self read];
            }
            else {
                [UITools showError:InternationaString(@"Contraseña errónea.")];
                
                BaseTabBarController *tab = (BaseTabBarController *)self.navigationController.parentViewController;
                [tab toLastController];
            }
        }
        else {
            BaseTabBarController *tab = (BaseTabBarController *)self.navigationController.parentViewController;
            [tab toLastController];
        }
    }];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [APP startTimer];
}

#pragma mark - 读数据
- (void)read {
    
    NSString *numberString = [BluetoothHelper numberBattery];
    
    [BluetoothHelper number:numberString batchRead:_opArray index:0 result:^(NSString * _Nonnull sendHexString, OPERATION_ERROR code, NSString * _Nonnull msg, NSString * _Nullable recvDataString, NSString * _Nullable recvRegularExpression, OperationType type) {
        if (code == OPERATION_SUCCEEDED) {
            GRMDevice *device = [GRMBluetoothManager sharedGRMBluetoothManager].device;
            [BluetoothHelper setValueFromRecvHexString:recvDataString withType:type toDevice:device];
            
            if (type == OP_cd100dy) {
                [UITools stopLoading];
                [self loadDataSource];
                [self.tableView reloadData];
            }
        } else {
            [UITools stopLoading];
        }
    }];
}

#pragma mark - tableView delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _configArray.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0f;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *idfCell = @"idfCell";
    SettingCell *cell = [tableView dequeueReusableCellWithIdentifier:idfCell];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"SettingCell" owner:nil options:nil] firstObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSDictionary *rowDict = [_configArray objectAtIndex:indexPath.section];
    cell.titLabel.text = [rowDict stringForKey:@"title"];
    cell.valueLabel.text = [rowDict stringForKey:@"value"];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *rowDict = [_configArray objectAtIndex:indexPath.section];
    
    OperationType opType = (OperationType)[[rowDict numberForKey:@"type"] integerValue];
    
    if (opType == OP_yjglsjsj || opType == OP_dldlsjsj) {
        SettingPickerView *view = [[[NSBundle mainBundle] loadNibNamed:@"SettingPickerView" owner:nil options:nil] firstObject];
        view.titleLabel.text = [rowDict stringForKey:@"title"];
        view.valueArray = [BluetoothHelper valueArrayWithType:opType];
        [GRMAlertManager showAlertView:view configClickEvent:^NSArray *(UIView *alert) {
            return @[view.cancleButton, view.okButton];
        } didSelectedBlock:^(NSInteger index, UIView *alert) {
            if (index == 1) {
                NSInteger value = [view.valueString integerValue];
                value = roundf(value * [[rowDict stringForKey:@"ratio"] floatValue]);
                // 发送修改指令
                NSString *numberString = [BluetoothHelper numberBattery];
                [BluetoothHelper number:numberString write:opType value:value result:^(NSString * _Nonnull sendHexString, OPERATION_ERROR code, NSString * _Nonnull msg, NSString * _Nullable recvDataString, NSString * _Nullable recvRegularExpression, OperationType type) {
                    if (code == OPERATION_SUCCEEDED) {
                        [UITools showSuccess:InternationaString(@"Modificado correctamente")];
                        GRMDevice *device = [GRMBluetoothManager sharedGRMBluetoothManager].device;
                        [BluetoothHelper setValueFromRecvHexString:recvDataString withType:type toDevice:device];
                        
                        [self loadDataSource];
                        [self.tableView reloadData];
                    }
                    else {
                        [UITools showError:InternationaString(@"Modificación erronea")];
                    }
                }];

            }
        }];
    }
    else {
        SettingFieldView *view = [[[NSBundle mainBundle] loadNibNamed:@"SettingFieldView" owner:nil options:nil] firstObject];
        view.titleLabel.text = [rowDict stringForKey:@"title"];
        view.textField.placeholder = [rowDict stringForKey:@"placeholder"];
        view.allow = YES;
        view.bounds = CGRectMake(0, 0, SCREEN_WIDTH-32*2, 200);
        [GRMAlertManager showAlertView:view configClickEvent:^NSArray *(UIView *alert) {
            return @[view.cancelButton, view.okButton];
        } didSelectedBlock:^(NSInteger index, UIView *alert) {
            if (index == 1) {
                float value = [view.textField.text floatValue];
                if ([[rowDict stringForKey:@"min"] floatValue] <= value &&
                    value <= [[rowDict stringForKey:@"max"] floatValue]) {
                    value = roundf(value * [[rowDict stringForKey:@"ratio"] floatValue]);

                    // 发送修改指令
                    NSString *numberString = [BluetoothHelper numberBattery];
                    [BluetoothHelper number:numberString write:opType value:value result:^(NSString * _Nonnull sendHexString, OPERATION_ERROR code, NSString * _Nonnull msg, NSString * _Nullable recvDataString, NSString * _Nullable recvRegularExpression, OperationType type) {
                        if (code == OPERATION_SUCCEEDED) {
                            [UITools showSuccess:InternationaString(@"Modificado correctamente")];
                            GRMDevice *device = [GRMBluetoothManager sharedGRMBluetoothManager].device;
                            [BluetoothHelper setValueFromRecvHexString:recvDataString withType:type toDevice:device];
                            
                            [self loadDataSource];
                            [self.tableView reloadData];
                        }
                        else {
                            [UITools showError:InternationaString(@"Modificación erronea")];
                        }
                    }];
                    
                } else {
                    [UITools showError:InternationaString(@"Por favor, introduzca un rango correcto.")];
                }
            }
        }];
    }
    
}

- (void)loadDataSource {
    
    _opArray = @[@(OP_sjrl), @(OP_mcrl),
                 @(OP_dxgcdyz), @(OP_dxgcsf), @(OP_dxqdyz), @(OP_dxgfsf),
                 @(OP_dcgcdyz),  @(OP_dcgcsf), @(OP_dcgfdyz),@(OP_dcgfsf),
                 @(OP_dxcdgw),  @(OP_dxcdgwsf),
                 @(OP_dxcddwz), @(OP_dxcddwsf),
                 @(OP_dxfdgw),  @(OP_dxfdgwsf),
                 @(OP_dxfddwz), @(OP_dxfddwsf),
                 @(OP_cd100dl), @(OP_sjdy),
                 @(OP_f0dy), @(OP_cd100dy)];
    
    GRMDevice *device = [GRMBluetoothManager sharedGRMBluetoothManager].device;
    if (!device.cd100dy) {
        device = [[GRMDevice alloc] init];
    }
    _configArray = @[@{@"title":InternationaString(@"Capacidad batería"), @"value":device.sjrl?:@"0", @"type":@(OP_sjrl),
                       @"placeholder":InternationaString(@"1AH~999AH"), @"min":@"1", @"max":@"999", @"ratio":@"1000"},
                     @{@"title":InternationaString(@"Capacidad total de la batería"), @"value":device.mcrl?:@"0", @"type":@(OP_mcrl),
                       @"placeholder":InternationaString(@"1AH~999AH"), @"min":@"1", @"max":@"999", @"ratio":@"1000"},
                     
                     @{@"title":InternationaString(@"Voltaje de proteccionó por sobre carga"), @"value":device.dxgcdyz?:@"0", @"type":@(OP_dxgcdyz),
                       @"placeholder":InternationaString(@"1V~5V"), @"min":@"1", @"max":@"5", @"ratio":@"1000"},
                     @{@"title":InternationaString(@"Voltaje de rearme tras sobre carga"), @"value":device.dxgcsf?:@"0", @"type":@(OP_dxgcsf),
                       @"placeholder":InternationaString(@"1V~5V"), @"min":@"1", @"max":@"5", @"ratio":@"1000"},
                     @{@"title":InternationaString(@"Voltaje de protección por sobre descarga"), @"value":device.dxqdyz?:@"0", @"type":@(OP_dxqdyz),
                       @"placeholder":InternationaString(@"1V~5V"), @"min":@"1", @"max":@"5", @"ratio":@"1000"},
                     @{@"title":InternationaString(@"Voltaje de rearme tras sobre descarga"), @"value":device.dxgfsf?:@"0", @"type":@(OP_dxgfsf),
                       @"placeholder":InternationaString(@"1V~5V"), @"min":@"1", @"max":@"5", @"ratio":@"1000"},
    
                     @{@"title":InternationaString(@"Voltaje de protección por sobre carga"), @"value":device.dcgcdyz?:@"0", @"type":@(OP_dcgcdyz),
                       @"placeholder":InternationaString(@"2V~110V"), @"min":@"2", @"max":@"110", @"ratio":@"1000"},
                     @{@"title":InternationaString(@"Voltaje de rearme tras sobre carga"), @"value":device.dcgcsf?:@"0", @"type":@(OP_dcgcsf),
                       @"placeholder":InternationaString(@"2V~110V"), @"min":@"2", @"max":@"110", @"ratio":@"1000"},
                     @{@"title":InternationaString(@"Voltaje de protección por sobre descarga"), @"value":device.dcgfdyz?:@"0", @"type":@(OP_dcgfdyz),
                       @"placeholder":InternationaString(@"2V~110V"), @"min":@"2", @"max":@"110", @"ratio":@"1000"},
                     @{@"title":InternationaString(@"Voltaje de rearme tras sobre descarga"), @"value":device.dcgfsf?:@"0", @"type":@(OP_dcgfsf),
                       @"placeholder":InternationaString(@"2V~110V"), @"min":@"2", @"max":@"110", @"ratio":@"1000"},
                     
                     @{@"title":InternationaString(@"Protección por alta temperatura en carga"), @"value":device.dxcdgw?:@"0", @"type":@(OP_dxcdgw),
                       @"placeholder":InternationaString(@"20℃~100℃"), @"min":@"20", @"max":@"100", @"ratio":@"1"},
                     @{@"title":InternationaString(@"Rearme tras alta temperatura en carga"), @"value":device.dxcdgwsf?:@"0", @"type":@(OP_dxcdgwsf),
                       @"placeholder":InternationaString(@"20℃~100℃"), @"min":@"20", @"max":@"100", @"ratio":@"1"},
                     
                     @{@"title":InternationaString(@"Protección por baja temperatura en carga"), @"value":device.dxcddwz?:@"0", @"type":@(OP_dxcddwz),
                       @"placeholder":InternationaString(@"-20℃~40℃"), @"min":@"-20", @"max":@"40", @"ratio":@"1"},
                     @{@"title":InternationaString(@"Rearme tras baja temperatura en carga"), @"value":device.dxcddwsf?:@"0", @"type":@(OP_dxcddwsf),
                       @"placeholder":InternationaString(@"-20℃~40℃"), @"min":@"-20", @"max":@"40", @"ratio":@"1"},
                     
                     @{@"title":InternationaString(@"Protección por alta temperatura en descarga"), @"value":device.dxfdgw?:@"0", @"type":@(OP_dxfdgw),
                       @"placeholder":InternationaString(@"20℃~100℃"), @"min":@"20", @"max":@"100", @"ratio":@"1"},
                     @{@"title":InternationaString(@"Rearme tras alta temperatura en descarga"), @"value":device.dxfdgwsf?:@"0", @"type":@(OP_dxfdgwsf),
                       @"placeholder":InternationaString(@"20℃~100℃"), @"min":@"20", @"max":@"100", @"ratio":@"1"},
                     
                     @{@"title":InternationaString(@"Protección por baja temperature en descarga"), @"value":device.dxfddwz?:@"0", @"type":@(OP_dxfddwz),
                       @"placeholder":InternationaString(@"-20℃~40℃"), @"min":@"-20", @"max":@"40", @"ratio":@"1"},
                     @{@"title":InternationaString(@"Rearme tras baja temperatura en descarga"), @"value":device.dxfddwsf?:@"0", @"type":@(OP_dxfddwsf),
                       @"placeholder":InternationaString(@"-20℃~40℃"), @"min":@"-20", @"max":@"40", @"ratio":@"1"},
                     
                     @{@"title":InternationaString(@"Valor Voltaje total de la batería"), @"value":device.sjdy?:@"0", @"type":@(OP_sjdy),
                       @"placeholder":InternationaString(@"6V~200V"), @"min":@"6", @"max":@"200", @"ratio":@"1000"},
                     @{@"title":InternationaString(@"Corriente cuando la capacidad es del 100%"), @"value":device.cd100dl?:@"0", @"type":@(OP_cd100dl),
                       @"placeholder":InternationaString(@"1A~9A"), @"min":@"1", @"max":@"9", @"ratio":@"1000"},
                     @{@"title":InternationaString(@"Voltaje cuando la capacidad es del 100%"), @"value":device.cd100dy?:@"0", @"type":@(OP_cd100dy),
                       @"placeholder":InternationaString(@"6V~200V"), @"min":@"6", @"max":@"200", @"ratio":@"1000"},
                     @{@"title":InternationaString(@"Voltaje cuando la capacidad es del 0%"), @"value":device.fd0dy?:@"0", @"type":@(OP_f0dy),
                       @"placeholder":InternationaString(@"6V~200V"), @"min":@"6", @"max":@"200", @"ratio":@"1000"}];
}

- (void)setUI {
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
