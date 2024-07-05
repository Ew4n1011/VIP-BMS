//
//  SearchController.m
//  VIP-BMS
//
//  Created by goorume on 2020/4/26.
//  Copyright © 2020 goorume. All rights reserved.
//

#import "SearchController.h"

#import "WKWebViewController.h"
#import "HomeController.h"

#import "DeviceCell.h"

@interface SearchController ()

@property (nonatomic, strong) UIButton *connectButton;

@end

@implementation SearchController {
    NSMutableArray *_dataSource;
    
    NSString *_theBTName;
    
    NSNumber *_selectedIndex;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = InternationaString(@"Me Energy");
    
    [self setUI];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
//    [APP stopTimer];
//
//    [[GRMBluetoothManager sharedGRMBluetoothManager] disconnect];
//
    [self startScan];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self stopScan];
}

- (void)connectAction:(UIButton *)sender {
    if (_selectedIndex) {
        [APP stopTimer];
        
        [[GRMBluetoothManager sharedGRMBluetoothManager] disconnect];
        
        GRMDevice *device = [_dataSource objectAtIndex:[_selectedIndex integerValue]];
        [UITools startLoading];
        [[GRMBluetoothManager sharedGRMBluetoothManager] connectWithDevice:device result:^(NSArray<GRMDevice *> * _Nonnull devices, OPERATION_ERROR code, NSString * _Nonnull msg) {
            if (code == OPERATION_SUCCEEDED) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self read];
                });
            }
        }];
    }
}

#pragma mark - 搜索
- (void)scanAction:(UIButton *)sender {
//    HomeController *vc = [[HomeController alloc] init];
//    [self.navigationController pushViewController:vc animated:YES];
    
    sender.backgroundColor = UIColor.lightGrayColor;
    [UIView animateWithDuration:.25 animations:^{
        sender.backgroundColor = UIColor.clearColor;
    }];

    [self stopScan];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
       [self startScan];
    });
}

- (void)startScan {
    
//    HomeController *vc = [[HomeController alloc] init];
//    [self.navigationController pushViewController:vc animated:YES];
    
    if (_dataSource.count) {
        [_dataSource removeAllObjects];
        [self.tableView reloadData];
    }
    
    WEAKSELF(self);
    [[GRMBluetoothManager sharedGRMBluetoothManager] scanDevices:@"^(.)*" result:^(NSArray<GRMDevice *> * _Nonnull devices, OPERATION_ERROR code, NSString * _Nonnull msg) {
        if (code == OPERATION_SUCCEEDED) {
            STRONGSELF(self);
            if (self) {
                NSMutableArray *arr = [NSMutableArray array];
                for (GRMDevice *device in devices) {
                    if (!([device.name hasPrefix:@"CJ"] || [device.name hasPrefix:@"cj"])) {
                        [arr addObject:device];
                    }
                }
                self->_dataSource = [NSMutableArray arrayWithArray:arr];
                [self.tableView reloadData];
            }
        }
    }];
}

- (void)stopScan {
    [GRMBluetoothManager sharedGRMBluetoothManager].cancelScan = YES;
    [[GRMBluetoothManager sharedGRMBluetoothManager] stopScan];
}

- (void)read {
    
    NSString *numberString = [BluetoothHelper numberBattery];
    [BluetoothHelper number:numberString readDeviceTypeWithResult:^(NSString * _Nonnull sendHexString, OPERATION_ERROR code, NSString * _Nonnull msg, NSString * _Nullable recvDataString, NSString * _Nullable recvRegularExpression) {
        if (code == OPERATION_SUCCEEDED) {
            NSLog(@"读设备类型，协议版本 ~~ ");
            [BluetoothHelper number:numberString voltage12Resutl:^(NSString * _Nonnull sendHexString, OPERATION_ERROR code, NSString * _Nonnull msg, NSString * _Nullable recvDataString, NSString * _Nullable recvRegularExpression) {
                [UITools stopLoading];
                if (code == OPERATION_SUCCEEDED) {
                    NSLog(@"voltage12Resutl ~~ %@", recvDataString);
                    GRMDevice *device = [GRMBluetoothManager sharedGRMBluetoothManager].device;
                    [device getVoltage12FromRecvHexString:recvDataString];
                    
                    [BluetoothHelper number:numberString voltage24Resutl:^(NSString * _Nonnull sendHexString, OPERATION_ERROR code, NSString * _Nonnull msg, NSString * _Nullable recvDataString, NSString * _Nullable recvRegularExpression) {
                        if (code == OPERATION_SUCCEEDED) {
                            NSLog(@"voltage24Resutl ~~ %@", recvDataString);
                            GRMDevice *device = [GRMBluetoothManager sharedGRMBluetoothManager].device;
                            [device getVoltage24FromRecvHexString:recvDataString];
                            
                            [BluetoothHelper number:numberString infomation2Result:^(NSString * _Nonnull sendHexString, OPERATION_ERROR code, NSString * _Nonnull msg, NSString * _Nullable recvDataString, NSString * _Nullable recvRegularExpression) {
                                if (code == OPERATION_SUCCEEDED) {
                                    NSLog(@"infomation2Result ~~ %@", recvDataString);
                                    GRMDevice *device = [GRMBluetoothManager sharedGRMBluetoothManager].device;
                                    [device getInfomation2FromRecvHexString:recvDataString];
                                    
                                    [BluetoothHelper number:numberString infomation1Result:^(NSString * _Nonnull sendHexString, OPERATION_ERROR code, NSString * _Nonnull msg, NSString * _Nullable recvDataString, NSString * _Nullable recvRegularExpression) {
                                        if (code == OPERATION_SUCCEEDED) {
                                            NSLog(@"infomation1Result ~~ %@", recvDataString);
                                            GRMDevice *device = [GRMBluetoothManager sharedGRMBluetoothManager].device;
                                            [device getInfomation1FromRecvHexString:recvDataString];
                                            
                                            if (device.deviceType == Device_20) {
                                                // 2.0版本协议
                                                [BluetoothHelper number:numberString voltage32Resutl:^(NSString * _Nonnull sendHexString, OPERATION_ERROR code, NSString * _Nonnull msg, NSString * _Nullable recvDataString, NSString * _Nullable recvRegularExpression) {
                                                    if (code == OPERATION_SUCCEEDED) {
                                                        NSLog(@"voltage32Resutl ~~ %@", recvDataString);
                                                        GRMDevice *device = [GRMBluetoothManager sharedGRMBluetoothManager].device;
                                                        [device getVoltage32FromRecvHexString:recvDataString];
                                                        
                                                        [BluetoothHelper number:numberString infomation3Result:^(NSString * _Nonnull sendHexString, OPERATION_ERROR code, NSString * _Nonnull msg, NSString * _Nullable recvDataString, NSString * _Nullable recvRegularExpression) {
                                                            if (code == OPERATION_SUCCEEDED) {
                                                                NSLog(@"infomation3Result ~~ %@", recvDataString);
                                                                GRMDevice *device = [GRMBluetoothManager sharedGRMBluetoothManager].device;
                                                                [device getInfomation3FromRecvHexString:recvDataString];
                                                                
                                                                if (self.tabBarController.viewControllers.count > 1) {
                                                                    [self.tabBarController setSelectedIndex:1];
                                                                }
                                                            }
                                                        }];
                                                    }
                                                }];
                                            }
                                            else {
                                                if (self.tabBarController.viewControllers.count > 1) {
                                                    [self.tabBarController setSelectedIndex:1];
                                                }
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
        else {
            NSLog(@"读设备类型失败");
        }
    }];
}

#pragma mark - tableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    self.tableView.backgroundView = _dataSource.count ? [UIView new] : [self noDevices];
    return _dataSource.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_theBTName.length) {
        GRMDevice *device = [_dataSource objectAtIndex:indexPath.row];
        if ([device.name isEqualToString:_theBTName]) {
            return 70;
        } else {
            return 0;
        }
    }
    return 70;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *idfCell = @"idfCell";
    
    DeviceCell *cell = [tableView dequeueReusableCellWithIdentifier:idfCell];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"DeviceCell" owner:nil options:nil] firstObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    GRMDevice *device = [_dataSource objectAtIndex:indexPath.row];
    
    cell.nameLabel.text = device.name ?: @"";
    cell.idfLabel.text = device.uuidIdentifier ?: @"";
    cell.rssiLabel.text = [NSString stringWithFormat:@"%ld", device.RSSI];
    
    if (_selectedIndex) {
        if ([_selectedIndex integerValue] == indexPath.row) {
            cell.nameLabel.textColor = kMAINCOLOR_FRONT;
        } else {
            cell.nameLabel.textColor = UIColor.blackColor;
        }
    } else {
        cell.nameLabel.textColor = UIColor.blackColor;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_selectedIndex && [_selectedIndex integerValue] == indexPath.row) {
        _selectedIndex = nil;
        self.connectButton.hidden = YES;
    } else {
        _selectedIndex = @(indexPath.row);
        self.connectButton.hidden = NO;
    }
    
    [self.tableView reloadData];
}

- (void)setUI {
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.alwaysBounceVertical = YES;
    
    _connectButton = [[UIButton alloc] init];
    _connectButton.hidden = YES;
    [_connectButton setImage:ImageNamed(@"BUSCAR") forState:UIControlStateNormal];
    [_connectButton addTarget:self action:@selector(connectAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_connectButton];
    [_connectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.offset(80);
        make.centerX.offset(0);
    }];
}

- (UIView *)noDevices {
    UIView *v = [[UIView alloc] init];
    v.backgroundColor = kMAINCOLOR_BG;
    
    UIImageView *imgView = [[UIImageView alloc] init];
    imgView.image = ImageNamed(@"ssly");
    
    UILabel *lb = [[UILabel alloc] init];
    lb.font = [UIFont systemFontOfSize:15.0f];
    lb.text = InternationaString(@"No se encuentran equipos en este momento.");
    lb.textColor = UIColor.lightGrayColor;
    
//    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
//    btn.titleLabel.font = [UIFont systemFontOfSize:15.0f];
//    btn.layer.cornerRadius = 20.0f;
//    btn.layer.borderWidth = 2.0f;
//    btn.layer.borderColor = kMAINCOLOR_GREEN.CGColor;
//    [btn setTitle:InternationaString(@"继续搜索") forState:UIControlStateNormal];
//    [btn setTitleColor:kMAINCOLOR_GREEN forState:UIControlStateNormal];
//    [btn addTarget:self action:@selector(scanAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [v addSubview:imgView];
    [v addSubview:lb];
//    [v addSubview:btn];
    [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.offset(-80);
        make.centerX.offset(0);
    }];
    [lb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imgView.mas_bottom).with.offset(10);
        make.centerX.offset(0);
    }];
//    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(lb.mas_bottom).with.offset(60);
//        make.centerX.offset(0);
//        make.size.mas_equalTo(CGSizeMake(150, 40));
//    }];
    return v;
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
