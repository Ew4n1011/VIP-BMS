//
//  HomeController.m
//  VIP-BMS
//
//  Created by goorume on 2020/4/23.
//  Copyright © 2020 goorume. All rights reserved.
//

#import "HomeController.h"
#import "BatterysController.h"
#import "DetailController.h"
#import "SettingController.h"
#import "SearchController.h"
#import "BaseNavigationController.h"

#import "YBPopupMenu.h"
#import "SettingFieldView.h"

@interface HomeController ()<YBPopupMenuDelegate>

@property (nonatomic, strong) UIView *menuView;

@property (weak, nonatomic) IBOutlet UIImageView *roundImageView_w;
@property (weak, nonatomic) IBOutlet UIImageView *roundImageView_n;

@property (weak, nonatomic) IBOutlet UILabel *syrl_pLabel;

@property (weak, nonatomic) IBOutlet UILabel *ntc1Lb;
@property (weak, nonatomic) IBOutlet UILabel *ntc1Label;

@property (weak, nonatomic) IBOutlet UILabel *zdyLb;
@property (weak, nonatomic) IBOutlet UILabel *zdyLabel;

@property (weak, nonatomic) IBOutlet UILabel *zdlLb;
@property (weak, nonatomic) IBOutlet UILabel *zdlLabel;

@property (weak, nonatomic) IBOutlet UILabel *xhcsLb;
@property (weak, nonatomic) IBOutlet UILabel *xhcsLabel;

@property (weak, nonatomic) IBOutlet UILabel *syrlLb;
@property (weak, nonatomic) IBOutlet UILabel *syrlLabel;

@property (weak, nonatomic) IBOutlet UILabel *cdmosLb;
@property (weak, nonatomic) IBOutlet UILabel *fdmosLb;
@property (weak, nonatomic) IBOutlet UIButton *cdmosButton;
@property (weak, nonatomic) IBOutlet UIButton *fdmosButton;

@end

@implementation HomeController {
    NSArray *_configArray;
    
    NSTimer *_timer;
    
    BOOL _hadDraw;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:InternationaString(@"Me Energy") style:UIBarButtonItemStylePlain target:nil action:nil];
    
    UIButton *rightButton = [[UIButton alloc] init];
    rightButton.titleLabel.font = [UIFont systemFontOfSize:13.0f];
    [rightButton setTitle:InternationaString(@"Calibración corriente") forState:UIControlStateNormal];
    [rightButton setImage:ImageNamed(@"A_normal") forState:UIControlStateNormal];
    [rightButton setImage:ImageNamed(@"A_highlighted") forState:UIControlStateHighlighted];
    [rightButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [rightButton setTitleColor:UIColor.whiteColor forState:UIControlStateHighlighted];
    [rightButton setImageEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
    [rightButton addTarget:self action:@selector(xzAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    
    [self setUI];

    [self loadDataSource];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDevice:) name:NotificationUpdateDevice object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disconnect:) name:NotificationBlueToothDisconnect object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!_hadDraw) {
        _hadDraw = YES;
        
        self.roundImageView_w.backgroundColor = UIColorFromRGB(0xF4F4F4);
        self.roundImageView_w.layer.cornerRadius = self.roundImageView_w.bounds.size.height/2.0;
        self.roundImageView_w.layer.borderWidth = 0.5f;
        self.roundImageView_w.layer.borderColor = UIColorFromRGB(0xCCCCCC).CGColor;
        
        self.roundImageView_n.backgroundColor = UIColorFromRGB(0xCBCBCB);
        self.roundImageView_n.layer.cornerRadius = self.roundImageView_n.bounds.size.height/2.0;
    }
    
    [self readInitConfiguretionIfNeed];
}

- (void)dealloc {
    [APP stopTimer];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 校准
- (IBAction)xzAction:(UIButton *)sender {
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
                NSDictionary *config = @{@"title":InternationaString(@"Calibración Corriente"), @"value":@"0", @"type":@(OP_dlxz),
                                         @"placeholder":InternationaString(@"-100A~100A"), @"min":@"-100", @"max":@"100", @"ratio":@"1000"};
                OperationType opType = (OperationType)[[config numberForKey:@"type"] integerValue];
                
                SettingFieldView *view = [[[NSBundle mainBundle] loadNibNamed:@"SettingFieldView" owner:nil options:nil] firstObject];
                view.titleLabel.text = config[@"title"];
                view.textField.placeholder = config[@"placeholder"];
                view.allow = YES;
                view.bounds = CGRectMake(0, 0, SCREEN_WIDTH-32*2, 200);
                [GRMAlertManager showAlertView:view configClickEvent:^NSArray *(UIView *alert) {
                    return @[view.cancelButton, view.okButton];
                } didSelectedBlock:^(NSInteger index, UIView *alert) {
                    if (index == 1) {
                        float value = [view.textField.text floatValue];
                        if ([[config stringForKey:@"min"] floatValue] <= value &&
                            value <= [[config stringForKey:@"max"] floatValue]) {
                            value = value * [[config stringForKey:@"ratio"] integerValue];
                            
                            GRMDevice *device = [GRMBluetoothManager sharedGRMBluetoothManager].device;
                            NSTimeInterval timeInterval = device.deviceType == Device_20 ? 1.5 : 0.8;
                            
                            [APP stopTimer];
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                // 读电流
                                NSString *numberString = [BluetoothHelper numberBattery];
                                [BluetoothHelper number:numberString infomation1Result:^(NSString * _Nonnull sendHexString, OPERATION_ERROR code, NSString * _Nonnull msg, NSString * _Nullable recvDataString, NSString * _Nullable recvRegularExpression) {
                                    if (code == OPERATION_SUCCEEDED) {
                                        NSLog(@"infomation1Result ~~ %@", recvDataString);
                                        GRMDevice *device = [GRMBluetoothManager sharedGRMBluetoothManager].device;
                                        [device getInfomation1FromRecvHexString:recvDataString];
                                        
                                        // 重新读取电流校准值
                                        [BluetoothHelper number:numberString read:OP_dlxz result:^(NSString * _Nonnull sendHexString, OPERATION_ERROR code, NSString * _Nonnull msg, NSString * _Nullable recvDataString, NSString * _Nullable recvRegularExpression) {
                                            if (code == OPERATION_SUCCEEDED) {
                                                NSLog(@"校准值 ~~ %@", recvDataString);
                                                GRMDevice *device = [GRMBluetoothManager sharedGRMBluetoothManager].device;
                                                [BluetoothHelper setValueFromRecvHexString:recvDataString withType:OP_dlxz toDevice:device];
                                                
                                                NSInteger dlxz = 0;
                                                if (BTM.device.dlxz.length) {
                                                    CGFloat tmpv = [BTM.device.dlxz floatValue]*(fabsf(value)/(fabsf([BTM.device.dlMA floatValue])*1000));
                                                    NSString *dlxzString = [NSString stringWithFormat:@"%.0f", tmpv];
                                                    dlxz = [dlxzString integerValue];
                                                }
                                                
                                                // 注意：根据计算公式，新的校准值可能超出2字节的取值范围，超过时将取值修复为ED80（由龙工给出，采样电阻的RD值）
                                                if (dlxz > 0xFFFF) {
                                                    dlxz = 0xED80;
                                                }
                                                
        //                                        NSInteger dlxz = [BTM.device.dlxz integerValue];
                                                // 发送修改指令
                                                [BluetoothHelper number:numberString write:opType value:dlxz result:^(NSString * _Nonnull sendHexString, OPERATION_ERROR code, NSString * _Nonnull msg, NSString * _Nullable recvDataString, NSString * _Nullable recvRegularExpression, OperationType type) {
                                                    if (code == OPERATION_SUCCEEDED) {
                                                        [UITools showSuccess:InternationaString(@"Modificado correctamente")];
                                                        [APP startTimer];
                                                    }
                                                    else {
                                                        [UITools showError:InternationaString(@"Modificación erronea")];
                                                        [APP startTimer];
                                                    }
                                                }];
                                                
                                            } else {
                                                [UITools showError:InternationaString(@"Modificación erronea")];
                                                [APP startTimer];
                                            }
                                        }];
                                    }
                                }];
                            });
                            
                        } else {
                            [UITools showError:InternationaString(@"Por favor, introduzca un rango correcto.")];
                        }
                    }
                }];
                
            } else {
                [UITools showError:InternationaString(@"Contraseña errónea.")];
            }
        }
    }];
}

#pragma mark - 充电MOS
- (IBAction)cdmosAction:(UIButton *)sender {
    GRMDevice *device = [GRMBluetoothManager sharedGRMBluetoothManager].device;
    if (device.deviceType == Device_10) {
        NSLog(@"不支持1.0的协议");
        [UITools showError:InternationaString(@"Sin soporte")];
        return;
    }
    
    NSString *numberString = [BluetoothHelper numberBattery];
    [BluetoothHelper number:numberString read:OP_mcuState result:^(NSString * _Nonnull sendHexString, OPERATION_ERROR code, NSString * _Nonnull msg, NSString * _Nullable recvDataString, NSString * _Nullable recvRegularExpression) {
        if (code == OPERATION_SUCCEEDED) {
            [BluetoothHelper setValueFromRecvHexString:recvDataString withType:OP_mcuState toDevice:device];
            
            // OP_mcuState  8bit,0-开关充电MOS; 1-开关放电MOS; 2-开关预充电MOS; 3-开关预放电MOS; 4-无; 5-无; 6-无; 7-无
            NSInteger mcuState = [device.mcuState integerValue];
            NSInteger toValue  = 0;
            if (self.cdmosButton.selected) {
                // 将要关闭
                toValue = mcuState & 0b11111110;
            }
            else {
                // 将要打开
                toValue = mcuState | 0b00000001;
            }
            [BluetoothHelper number:numberString write:OP_mcuState value:toValue result:^(NSString * _Nonnull sendHexString, OPERATION_ERROR code, NSString * _Nonnull msg, NSString * _Nullable recvDataString, NSString * _Nullable recvRegularExpression, OperationType type) {
                if (code == OPERATION_SUCCEEDED) {
                    self.cdmosButton.selected = !self.cdmosButton.selected;
                }
            }];
        }
    }];
    
}

#pragma mark - 放电MOS
- (IBAction)fdmosAction:(UIButton *)sender {
    GRMDevice *device = [GRMBluetoothManager sharedGRMBluetoothManager].device;
    if (device.deviceType == Device_10) {
        NSLog(@"不支持1.0的协议");
        [UITools showError:InternationaString(@"Sin soporte")];
        return;
    }
    
    NSString *numberString = [BluetoothHelper numberBattery];
    [BluetoothHelper number:numberString read:OP_mcuState result:^(NSString * _Nonnull sendHexString, OPERATION_ERROR code, NSString * _Nonnull msg, NSString * _Nullable recvDataString, NSString * _Nullable recvRegularExpression) {
        if (code == OPERATION_SUCCEEDED) {
            [BluetoothHelper setValueFromRecvHexString:recvDataString withType:OP_mcuState toDevice:device];
            
            // OP_mcuState  8bit,0-开关充电MOS; 1-开关放电MOS; 2-开关预充电MOS; 3-开关预放电MOS; 4-无; 5-无; 6-无; 7-无
            NSInteger mcuState = [device.mcuState integerValue];
            NSInteger toValue  = 0;
            if (self.fdmosButton.selected) {
                // 将要关闭
                toValue = mcuState & 0b11111101;
            }
            else {
                // 将要打开
                toValue = mcuState | 0b00000010;
            }
            [BluetoothHelper number:numberString write:OP_mcuState value:toValue result:^(NSString * _Nonnull sendHexString, OPERATION_ERROR code, NSString * _Nonnull msg, NSString * _Nullable recvDataString, NSString * _Nullable recvRegularExpression, OperationType type) {
                if (code == OPERATION_SUCCEEDED) {
                    self.fdmosButton.selected = !self.fdmosButton.selected;
                }
            }];
        }
    }];
}

- (void)updateDevice:(NSNotification *)aNotification {
    if (![GRMBluetoothManager sharedGRMBluetoothManager].isConnected) {
        return;
    }
    if (APP.stop) {
        return;
    }
    
    NSString *numberString = [BluetoothHelper numberBattery];
    [BluetoothHelper number:numberString voltage12Resutl:^(NSString * _Nonnull sendHexString, OPERATION_ERROR code, NSString * _Nonnull msg, NSString * _Nullable recvDataString, NSString * _Nullable recvRegularExpression) {
        [UITools stopLoading];
        if (code == OPERATION_SUCCEEDED) {
            NSLog(@"voltage12Resutl ~~ %@", recvDataString);
            GRMDevice *device = [GRMBluetoothManager sharedGRMBluetoothManager].device;
            [device getVoltage12FromRecvHexString:recvDataString];
            
            if (APP.stop) {
                return;
            }
            
            [BluetoothHelper number:numberString voltage24Resutl:^(NSString * _Nonnull sendHexString, OPERATION_ERROR code, NSString * _Nonnull msg, NSString * _Nullable recvDataString, NSString * _Nullable recvRegularExpression) {
                if (code == OPERATION_SUCCEEDED) {
                    NSLog(@"voltage24Resutl ~~ %@", recvDataString);
                    GRMDevice *device = [GRMBluetoothManager sharedGRMBluetoothManager].device;
                    [device getVoltage24FromRecvHexString:recvDataString];
                    
                    if (APP.stop) {
                        return;
                    }
                    
                    [BluetoothHelper number:numberString infomation2Result:^(NSString * _Nonnull sendHexString, OPERATION_ERROR code, NSString * _Nonnull msg, NSString * _Nullable recvDataString, NSString * _Nullable recvRegularExpression) {
                        if (code == OPERATION_SUCCEEDED) {
                            NSLog(@"infomation2Result ~~ %@", recvDataString);
                            GRMDevice *device = [GRMBluetoothManager sharedGRMBluetoothManager].device;
                            [device getInfomation2FromRecvHexString:recvDataString];
                            
                            if (APP.stop) {
                                return;
                            }
                            
                            [BluetoothHelper number:numberString infomation1Result:^(NSString * _Nonnull sendHexString, OPERATION_ERROR code, NSString * _Nonnull msg, NSString * _Nullable recvDataString, NSString * _Nullable recvRegularExpression) {
                                if (code == OPERATION_SUCCEEDED) {
                                    NSLog(@"infomation1Result ~~ %@", recvDataString);
                                    GRMDevice *device = [GRMBluetoothManager sharedGRMBluetoothManager].device;
                                    [device getInfomation1FromRecvHexString:recvDataString];
                                    
                                    // 2.0版本协议
                                    if (device.deviceType == Device_20) {
                                        if (APP.stop) {
                                            return;
                                        }
                                        
                                        [BluetoothHelper number:numberString voltage32Resutl:^(NSString * _Nonnull sendHexString, OPERATION_ERROR code, NSString * _Nonnull msg, NSString * _Nullable recvDataString, NSString * _Nullable recvRegularExpression) {
                                            if (code == OPERATION_SUCCEEDED) {
                                                NSLog(@"voltage32Resutl ~~ %@", recvDataString);
                                                GRMDevice *device = [GRMBluetoothManager sharedGRMBluetoothManager].device;
                                                [device getVoltage32FromRecvHexString:recvDataString];
                                                
                                                if (APP.stop) {
                                                    return;
                                                }
                                                
                                                [BluetoothHelper number:numberString infomation3Result:^(NSString * _Nonnull sendHexString, OPERATION_ERROR code, NSString * _Nonnull msg, NSString * _Nullable recvDataString, NSString * _Nullable recvRegularExpression) {
                                                    if (code == OPERATION_SUCCEEDED) {
                                                        NSLog(@"infomation3Result ~~ %@", recvDataString);
                                                        GRMDevice *device = [GRMBluetoothManager sharedGRMBluetoothManager].device;
                                                        [device getInfomation3FromRecvHexString:recvDataString];
                                                        
                                                        [self loadDataSource];
                                                    }
                                                }];
                                            }
                                        }];
                                    }
                                    else {
                                        [self loadDataSource];
                                    }
                                }
                            }];
                        }
                    }];
                }
            }];
        }
    }];
}

- (void)readInitConfiguretionIfNeed {
    GRMDevice *device = [GRMBluetoothManager sharedGRMBluetoothManager].device;
    if (device && !device.dlxz.length) {
        // 读校准值
        NSString *numberString = [BluetoothHelper numberBattery];
        [BluetoothHelper number:numberString read:OP_dlxz result:^(NSString * _Nonnull sendHexString, OPERATION_ERROR code, NSString * _Nonnull msg, NSString * _Nullable recvDataString, NSString * _Nullable recvRegularExpression) {
            if (code == OPERATION_SUCCEEDED) {
                NSLog(@"校准值 ~~ %@", recvDataString);
                GRMDevice *device = [GRMBluetoothManager sharedGRMBluetoothManager].device;
                [BluetoothHelper setValueFromRecvHexString:recvDataString withType:OP_dlxz toDevice:device];
                
                // 读电池串数1
                [BluetoothHelper number:numberString read:OP_dccs result:^(NSString * _Nonnull sendHexString, OPERATION_ERROR code, NSString * _Nonnull msg, NSString * _Nullable recvDataString, NSString * _Nullable recvRegularExpression) {
                    if (code == OPERATION_SUCCEEDED) {
                        NSLog(@"电池串数1 ~~ %@", recvDataString);
                        GRMDevice *device = [GRMBluetoothManager sharedGRMBluetoothManager].device;
                        [BluetoothHelper setValueFromRecvHexString:recvDataString withType:OP_dccs toDevice:device];
                        
                        // 读电池串数2
                        [BluetoothHelper number:numberString read:OP_dccs2 result:^(NSString * _Nonnull sendHexString, OPERATION_ERROR code, NSString * _Nonnull msg, NSString * _Nullable recvDataString, NSString * _Nullable recvRegularExpression) {
                            if (code == OPERATION_SUCCEEDED) {
                                NSLog(@"电池串数2 ~~ %@", recvDataString);
                                GRMDevice *device = [GRMBluetoothManager sharedGRMBluetoothManager].device;
                                [BluetoothHelper setValueFromRecvHexString:recvDataString withType:OP_dccs2 toDevice:device];
                            }
                            
                            [APP startTimer];
                        }];
                    } else {
                        [APP startTimer];
                    }
                }];
            } else {
                [APP startTimer];
            }
        }];
    }
}

#pragma mark - 蓝牙断开
- (void)disconnect:(NSNotification *)aNotification {
    [APP stopTimer];
    [UITools showError:InternationaString(@"Bluetooth desconectado")];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.navigationController popToRootViewControllerAnimated:YES];
    });
}

- (void)loadDataSource {
    GRMDevice *device = [GRMBluetoothManager sharedGRMBluetoothManager].device;
    
    self.syrl_pLabel.text = device.syrl_p ?: @"0%";
    
    self.zdyLabel.text = device.dyMV ?: @"";
    self.zdlLabel.text = device.dlMA ?: @"";
    self.xhcsLabel.text = device.fdcs ?: @"";
    self.syrlLabel.text = device.syrl ?: @"";
    
    if (device.deviceType == Device_20) {
        self.ntc1Label.text = device.wd1 ?: @"";
    }
    else {
        NSUInteger allCount = [BTM.device.dccs integerValue] + [BTM.device.dccs2 integerValue]; // 总串数
        if (allCount <= 5) {
            self.ntc1Label.text = device.wd1 ?: @"";
        } else if (allCount <= 10) {
            self.ntc1Label.text = device.wd1 ?: @"";
        } else {
            self.ntc1Label.text = device.wd1 ?: @"";
        }
    }
    
    int cdValue = [device.cdzt intValue];
    if ((cdValue & (1<<7)) == (1<<7)) {
        self.cdmosButton.selected = YES;
    } else {
        self.cdmosButton.selected = NO;
    }
    
    int fdValue = [device.fdzt intValue];
    if ((fdValue & (1<<7)) == (1<<7)) {
        self.fdmosButton.selected = YES;
    } else {
        self.fdmosButton.selected = NO;
    }
}

- (void)setUI {
    self.zdyLb.text = InternationaString(@"Voltaje :");
    self.zdlLb.text = InternationaString(@"Corriente :");
    self.xhcsLb.text = InternationaString(@"Ciclos de vida :");
    self.syrlLb.text = InternationaString(@"Capacidad nomianal :");
    self.ntc1Lb.text = InternationaString(@"Temperatura :");
    
    self.cdmosLb.text = InternationaString(@"Carga :");
    self.fdmosLb.text = InternationaString(@"Descarga :");
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
