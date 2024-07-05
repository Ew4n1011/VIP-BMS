//
//  BluetoothHelper.m
//  GRMBluetooth
//
//  Created by goorume on 2019/12/29.
//  Copyright © 2019 goorume. All rights reserved.
//

#import "BluetoothHelper.h"
#import "InsConvertTools.h"
#import "GRMBluetoothManager.h"
#import "GRMDevice+Private.h"
#import "GRMBluetoothManager+Private.h"

@implementation BluetoothHelper

#pragma mark - 总则
/**
 0x3A(包头) + 电池编号(1B) + 指令(1B) + 数据字节数(1B) + 数据(?B) + SUM(电池编号从电池编号到数据末尾的和）2B  + 0x0D + 0x0A
 总字节数 = 数据字节数 + 8
 传输数据时，低字节在前
 电池地址： 0x16
 
 2.0版本协议包头为 0x3B，地址位为 2 Byte
*/

#pragma mark - 读取电压1-12S

/**
 读取电压1-12S
 0x3A(包头) + 电池编号(1B) + 0x24(指令) + 0x01(数据字节数) + 0x00(数据) + SUM(2B) + 0x0D + 0x0A
 0x3A(包头) + 电池编号(1B) + 0x24(指令) + 24(数据字节数) + 1-12S电压(24B) + SUM(2B) + 0x0D + 0x0A
 电压24B为 1S电压(2B)+2S电压(2B)....+12S电压(2B)     (MV)
 */
+ (void)number:(NSString *)number voltage12Resutl:(Result)block {
    GRMDevice *device = [GRMBluetoothManager sharedGRMBluetoothManager].device;
    NSString *hd = device.deviceType == Device_20 ? @"3B" : @"3A"; // 协议版本
    
    NSString *sj = @"00";   // 数据
    
    NSString *bh = number;  // 电池编号
    NSString *zl = @"24";   // 指令
    NSString *cd = [NSString stringWithFormat:@"%02X", sj.length/2];     // 数据长度
    
    NSString *tmp = [NSString stringWithFormat:@"%@%@%@%@", bh, zl, cd, sj];
    NSString *sum = [BluetoothHelper hexSum:tmp];     // SUM
    
    NSString *hexString = [NSString stringWithFormat:@"%@%@%@0D0A", hd, tmp, sum];
    NSString *recvRExpr = [NSString stringWithFormat:@"^%@%@%@[0-9a-zA-Z]{6,54}0D0A$", hd, bh, zl];
    NSString *desString = [NSString stringWithFormat:@"%@%@", @"读取电压1-12S", @""];
    
    [[GRMBluetoothManager sharedGRMBluetoothManager] sendDataWithHexString:hexString recvRegularExpression:recvRExpr description:desString result:^(NSString * _Nonnull registerID, OPERATION_ERROR code, NSString * _Nonnull msg, NSString * _Nullable recvDataString, NSString * _Nullable recvRegularExpression, NSString * _Nonnull sendHexString) {
        if (block) {
            block(sendHexString, code, msg, recvDataString, recvRegularExpression);
        }
    }];
}


#pragma mark - 读取电压13-24S
/**
 读取电压13-24S
 0x3A(包头) + 电池编号(1B) + 0x25(指令) + 0x01(数据字节数) + 0x00(数据) + SUM(2B) + 0x0D + 0x0A
 0x3A(包头) + 电池编号(1B) + 0x25(指令) + 24(数据字节数) + 13-24S电压(24B) + SUM(2B) + 0x0D + 0x0A
 电压24B为 13S电压(2B)+14S电压(2B)....+24S电压(2B)   (MV)
 */
+ (void)number:(NSString *)number voltage24Resutl:(Result)block {
    GRMDevice *device = [GRMBluetoothManager sharedGRMBluetoothManager].device;
    NSString *hd = device.deviceType == Device_20 ? @"3B" : @"3A"; // 协议版本
    
    NSString *sj = @"00";   // 数据
    
    NSString *bh = number;  // 电池编号
    NSString *zl = @"25";   // 指令
    NSString *cd = [NSString stringWithFormat:@"%02X", sj.length/2];     // 数据长度
    
    NSString *tmp = [NSString stringWithFormat:@"%@%@%@%@", bh, zl, cd, sj];
    NSString *sum = [BluetoothHelper hexSum:tmp];     // SUM
    
    NSString *hexString = [NSString stringWithFormat:@"%@%@%@0D0A", hd, tmp, sum];
    NSString *recvRExpr = [NSString stringWithFormat:@"^%@%@%@[0-9a-zA-Z]{6,54}0D0A$", hd, bh, zl];
    NSString *desString = [NSString stringWithFormat:@"%@%@", @"读取电压13-24S", @""];
    
    [[GRMBluetoothManager sharedGRMBluetoothManager] sendDataWithHexString:hexString recvRegularExpression:recvRExpr description:desString result:^(NSString * _Nonnull registerID, OPERATION_ERROR code, NSString * _Nonnull msg, NSString * _Nullable recvDataString, NSString * _Nullable recvRegularExpression, NSString * _Nonnull sendHexString) {
        if (block) {
            block(sendHexString, code, msg, recvDataString, recvRegularExpression);
        }
    }];
}

#pragma mark - (仅2.0及以上)读取电压25-32S
/**
 读取电压25-32S
 0x3B(包头) + 电池编号(1B) + 0x26(指令) + 0x01(数据字节数) + 0x00(数据) + SUM(2B) + 0x0D + 0x0A
 0x3B(包头) + 电池编号(1B) + 0x26(指令) + 20(数据字节数) + 25-32S电压(16B) + 均衡状态（4B） + SUM(2B) + 0x0D + 0x0A
 电压16B为 25S电压(2B)+26S电压(2B)....+32S电压(2B)   (MV)
 均衡状态32位，代表了32个电池的均衡状态（11111111111111111111111111111111）
 */
+ (void)number:(NSString *)number voltage32Resutl:(Result)block {
    NSString *hd = @"3B"; // 协议版本
    
    NSString *sj = @"00";   // 数据
    
    NSString *bh = number;  // 电池编号
    NSString *zl = @"26";   // 指令
    NSString *cd = [NSString stringWithFormat:@"%02X", sj.length/2];     // 数据长度
    
    NSString *tmp = [NSString stringWithFormat:@"%@%@%@%@", bh, zl, cd, sj];
    NSString *sum = [BluetoothHelper hexSum:tmp];     // SUM
    
    NSString *hexString = [NSString stringWithFormat:@"%@%@%@0D0A", hd, tmp, sum];
    NSString *recvRExpr = [NSString stringWithFormat:@"^%@%@%@[0-9a-zA-Z]{6,46}0D0A$", hd, bh, zl];
    NSString *desString = [NSString stringWithFormat:@"%@%@", @"(仅2.0及以上)读取电压25-32S", @""];
    
    [[GRMBluetoothManager sharedGRMBluetoothManager] sendDataWithHexString:hexString recvRegularExpression:recvRExpr description:desString result:^(NSString * _Nonnull registerID, OPERATION_ERROR code, NSString * _Nonnull msg, NSString * _Nullable recvDataString, NSString * _Nullable recvRegularExpression, NSString * _Nonnull sendHexString) {
        if (block) {
            block(sendHexString, code, msg, recvDataString, recvRegularExpression);
        }
    }];
}

#pragma mark - 读取电流、容量、温度、状态
/**
 读取电流、容量、温度、状态
 0x3A(包头) + 电池编号(1B) + 0x2A(指令) + 0x01(数据字节数) + 0x00(数据) + SUM(2B) + 0x0D + 0x0A
  0x3A(包头) + 电池编号(1B) + 0x2A(指令) + 24(数据字节数) + 数据(24B) + SUM(2B) + 0x0D + 0x0A
 
 数据24B为 电流MA(4B)+总电压MV(4B)+温度1(1B)+温度2(1B)+温度3(1B)+温度4(1B)+剩余容量MAH(4B)+充电状态(1B)+放电状态(1B)+充电预警(1B)+放电预警(1B)+剩余容量%(1B)+留用(3B)
                         
 充电状态    0    过流保护                              充电状态     0    过流保护
         1    过温                                                         1    过温
         2    低温                                                         2    低温
         3    电芯过充                                                  3    电芯过放
         4    电池过充                                                  4    电池过放
         5    无                                                             5    短路保护
         6    无                                                             6    终止放电
         7    充电MOS已打开                                      7    放电MOS已打开
                         
 充电预警    0    过流                                     放电预警    0    过流
         1    过温                                                        1    过温
         2    低温                                                        2    低温
         3    压差                                                        3    压差
         4    无                                                            4    剩余时间<设定值
         5    无                                                            5    剩余容量<设定值
         6    无                                                            6    电芯过放
         7    充电充满                                                 7    电池过放
*/
+ (void)number:(NSString *)number infomation1Result:(Result)block {
    GRMDevice *device = [GRMBluetoothManager sharedGRMBluetoothManager].device;
    NSString *hd = device.deviceType == Device_20 ? @"3B" : @"3A"; // 协议版本
    
    NSString *sj = @"00";   // 数据
    
    NSString *bh = number;  // 电池编号
    NSString *zl = @"2A";   // 指令
    NSString *cd = [NSString stringWithFormat:@"%02X", sj.length/2];     // 数据长度
    
    NSString *tmp = [NSString stringWithFormat:@"%@%@%@%@", bh, zl, cd, sj];
    NSString *sum = [BluetoothHelper hexSum:tmp];     // SUM
    
    NSString *hexString = [NSString stringWithFormat:@"%@%@%@0D0A", hd, tmp, sum];
    NSString *recvRExpr = [NSString stringWithFormat:@"^%@%@%@[0-9a-zA-Z]{6,54}0D0A$", hd, bh, zl];
    NSString *desString = [NSString stringWithFormat:@"%@%@", @"读取电流、容量、温度、状态", @""];
    
    [[GRMBluetoothManager sharedGRMBluetoothManager] sendDataWithHexString:hexString recvRegularExpression:recvRExpr description:desString result:^(NSString * _Nonnull registerID, OPERATION_ERROR code, NSString * _Nonnull msg, NSString * _Nullable recvDataString, NSString * _Nullable recvRegularExpression, NSString * _Nonnull sendHexString) {
        if (block) {
            block(sendHexString, code, msg, recvDataString, recvRegularExpression);
        }
    }];
}

#pragma mark - 读取设计容量等
/**
 读取设计容量等
 0x3A(包头) + 电池编号(1B) + 0x2B(指令) + 0x01(数据字节数) + 0x00(数据) + SUM(2B) + 0x0D + 0x0A
 0x3A(包头) + 电池编号(1B) + 0x2B(指令) + 24(数据字节数) + 数据(24B) + SUM(2B) + 0x0D + 0x0A
 数据24B为 设计容量MAH(4B)+设计电压MV(4B)+满充容量MAH(4B)+充电电压MV(4B)+充电电流MA(2B)+电池生产序列号(2B) + 电池生产日期(2B) + 电池放电次数(2B)

 int i16temp = 电池生产日期; int day = i16temp & (int)31; int month = (i16temp>>5) & (int)15; int year = ((i16temp>>9) & (int)127) + 1980;*/
+ (void)number:(NSString *)number infomation2Result:(Result)block {
    GRMDevice *device = [GRMBluetoothManager sharedGRMBluetoothManager].device;
    NSString *hd = device.deviceType == Device_20 ? @"3B" : @"3A"; // 协议版本
    
    NSString *sj = @"00";   // 数据
    
    NSString *bh = number;  // 电池编号
    NSString *zl = @"2B";   // 指令
    NSString *cd = [NSString stringWithFormat:@"%02X", sj.length/2];     // 数据长度
    
    NSString *tmp = [NSString stringWithFormat:@"%@%@%@%@", bh, zl, cd, sj];
    NSString *sum = [BluetoothHelper hexSum:tmp];     // SUM
    
    NSString *hexString = [NSString stringWithFormat:@"%@%@%@0D0A", hd, tmp, sum];
    NSString *recvRExpr = [NSString stringWithFormat:@"^%@%@%@[0-9a-zA-Z]{12,54}0D0A$", hd, bh, zl];
    NSString *desString = [NSString stringWithFormat:@"%@%@", @"读取设计容量等", @""];
    
    [[GRMBluetoothManager sharedGRMBluetoothManager] sendDataWithHexString:hexString recvRegularExpression:recvRExpr description:desString result:^(NSString * _Nonnull registerID, OPERATION_ERROR code, NSString * _Nonnull msg, NSString * _Nullable recvDataString, NSString * _Nullable recvRegularExpression, NSString * _Nonnull sendHexString) {
        if (block) {
            block(sendHexString, code, msg, recvDataString, recvRegularExpression);
        }
    }];
}

#pragma mark - (仅2.0及以上)读取保护板IC的数据
/**
 读取保护板IC的数据
 0x3B(包头) + 电池编号(1B) + 0x27(指令) + 0x01(数据字节数) + 0x00(数据) + SUM(2B) + 0x0D + 0x0A
 0x3B(包头) + 电池编号(1B) + 0x27(指令) + 16(数据字节数) + 保护板IC状态(8B)+温度（8B）+ SUM(2B) + 0x0D + 0x0A
 
 保护板IC状态
 数据1    CONF
 数据2    BSTATUS1
 数据3    BSTATUS2
 数据4    BSTATUS3
 数据5    BFLAG1
 数据6    BFLAG2
 数据7    RSTSTAT
 数据8    eeprom（0x00-写入中颖eeprom成功，0x01-写入失败）
 
 温度     数据9-数据16(温度1-温度8)
 数据9-数据12为保护板的温度探头（温度1-温度4），数据13-数据16为保护板的温度探头（温度5-温度8）
 
 目前2.0协议只需要读取 温度1和温度5
 */
+ (void)number:(NSString *)number infomation3Result:(Result)block {
    NSString *hd = @"3B"; // 协议版本
    
    NSString *sj = @"00";   // 数据
    
    NSString *bh = number;  // 电池编号
    NSString *zl = @"27";   // 指令
    NSString *cd = [NSString stringWithFormat:@"%02X", sj.length/2];     // 数据长度
    
    NSString *tmp = [NSString stringWithFormat:@"%@%@%@%@", bh, zl, cd, sj];
    NSString *sum = [BluetoothHelper hexSum:tmp];     // SUM
    
    NSString *hexString = [NSString stringWithFormat:@"%@%@%@0D0A", hd, tmp, sum];
    NSString *recvRExpr = [NSString stringWithFormat:@"^%@%@%@[0-9a-zA-Z]{12,38}0D0A$", hd, bh, zl];
    NSString *desString = [NSString stringWithFormat:@"%@%@", @"(仅2.0及以上)读取保护板IC的数据", @""];
    
    [[GRMBluetoothManager sharedGRMBluetoothManager] sendDataWithHexString:hexString recvRegularExpression:recvRExpr description:desString result:^(NSString * _Nonnull registerID, OPERATION_ERROR code, NSString * _Nonnull msg, NSString * _Nullable recvDataString, NSString * _Nullable recvRegularExpression, NSString * _Nonnull sendHexString) {
        if (block) {
            block(sendHexString, code, msg, recvDataString, recvRegularExpression);
        }
    }];
}

#pragma mark - (仅2.0及以上)读取软件版本的数据
/**
 读取软件版本的数据
 0x3B(包头) + 电池编号(1B) + 0x28(指令) + 0x01(数据字节数) + 0x00(数据) + SUM(2B) + 0x0D + 0x0A
 0x3B(包头) + 电池编号(1B) + 0x28(指令) + 16(数据字节数) + DATA(16B) + SUM(2B) + 0x0D + 0x0A
 DAT:第一字节是长度
 */
+ (void)number:(NSString *)number getVersionResult:(Result)block {
    NSString *hd = @"3B"; // 协议版本
    
    NSString *sj = @"00";   // 数据
    
    NSString *bh = number;  // 电池编号
    NSString *zl = @"28";   // 指令
    NSString *cd = [NSString stringWithFormat:@"%02X", sj.length/2];     // 数据长度
    
    NSString *tmp = [NSString stringWithFormat:@"%@%@%@%@", bh, zl, cd, sj];
    NSString *sum = [BluetoothHelper hexSum:tmp];     // SUM
    
    NSString *hexString = [NSString stringWithFormat:@"%@%@%@0D0A", hd, tmp, sum];
    NSString *recvRExpr = [NSString stringWithFormat:@"^%@%@%@[0-9a-zA-Z]{12,38}0D0A$", hd, bh, zl];
    NSString *desString = [NSString stringWithFormat:@"%@%@", @"读取保护板IC的数据", @""];
    
    [[GRMBluetoothManager sharedGRMBluetoothManager] sendDataWithHexString:hexString recvRegularExpression:recvRExpr description:desString result:^(NSString * _Nonnull registerID, OPERATION_ERROR code, NSString * _Nonnull msg, NSString * _Nullable recvDataString, NSString * _Nullable recvRegularExpression, NSString * _Nonnull sendHexString) {
        if (block) {
            block(sendHexString, code, msg, recvDataString, recvRegularExpression);
        }
    }];
}

#pragma mark - 读取EEPROM
/**
 读取EEPROM
 0x3A(包头) + 电池编号(1B) + 0xE8(指令) + 0x01(数据字节数) + 地址(数据) + SUM(2B) + 0x0D + 0x0A
 0x3A(包头) + 电池编号(1B) + 0xE8(指令) + 16(数据字节数) + DATA(16B) + SUM(2B) + 0x0D + 0x0A
*/
+ (void)number:(NSString *)number read:(OperationType)type result:(Result)block {
    GRMDevice *device = [GRMBluetoothManager sharedGRMBluetoothManager].device;
    NSString *hd = device.deviceType == Device_20 ? @"3B" : @"3A"; // 协议版本
    
    NSString *dz = [BluetoothHelper addressWithOprationType:type];   // 地址
    
    NSString *bh = number;  // 电池编号
    NSString *zl = device.deviceType == Device_20 ? @"EA" : @"E8";   // 指令
    NSString *cd = [NSString stringWithFormat:@"%02X", dz.length/2];     // 数据长度
    
    NSString *tmp = [NSString stringWithFormat:@"%@%@%@%@", bh, zl, cd, dz];
    NSString *sum = [BluetoothHelper hexSum:tmp];     // SUM
    
    NSString *hexString = [NSString stringWithFormat:@"%@%@%@0D0A", hd, tmp, sum];
    NSString *recvRExpr = [NSString stringWithFormat:@"^%@%@%@[0-9a-zA-Z]{6,54}0D0A$", hd, bh, zl];
    NSString *desString = [NSString stringWithFormat:@"%@(%@)", @"读取EEPROM", [BluetoothHelper descriptionWithOprationType:type]];
    
    [[GRMBluetoothManager sharedGRMBluetoothManager] sendDataWithHexString:hexString recvRegularExpression:recvRExpr description:desString result:^(NSString * _Nonnull registerID, OPERATION_ERROR code, NSString * _Nonnull msg, NSString * _Nullable recvDataString, NSString * _Nullable recvRegularExpression, NSString * _Nonnull sendHexString) {
        if (block) {
            block(sendHexString, code, msg, recvDataString, recvRegularExpression);
        }
    }];
}

#pragma mark - 读取设备版本，对应新旧协议
/**
 读取设备类型，对应新旧协议。连接成功后，第一个要发送的指令
 设备不支持读取设备类型，只能尝试发送旧版本协议，有应答则为旧版本设备；无应答再发新版本协议，有应答则为新版本设备
 使用『读取电压1-12S』指令的返回情况来判断设备类型
 */
+ (void)number:(NSString *)number readDeviceTypeWithResult:(Result)block {
    GRMDevice *device = [GRMBluetoothManager sharedGRMBluetoothManager].device;
    
    device.deviceType = Device_20;
    [BluetoothHelper number:number voltage12Resutl:^(NSString * _Nonnull sendHexString, OPERATION_ERROR code, NSString * _Nonnull msg, NSString * _Nullable recvDataString, NSString * _Nullable recvRegularExpression) {
        if (code == OPERATION_SUCCEEDED) {
            if (block) {
                block(sendHexString, code, msg, recvDataString, recvRegularExpression);
            }
        }
        else if (code == TIME_OUT_ERROR) {
            
            device.deviceType = Device_10;
            [BluetoothHelper number:number voltage12Resutl:^(NSString * _Nonnull sendHexString, OPERATION_ERROR code, NSString * _Nonnull msg, NSString * _Nullable recvDataString, NSString * _Nullable recvRegularExpression) {
                if (code == OPERATION_SUCCEEDED) {
                    if (block) {
                        block(sendHexString, code, msg, recvDataString, recvRegularExpression);
                    }
                }
                else if (code == TIME_OUT_ERROR) {
                    if (block) {
                        block(sendHexString, code, msg, recvDataString, recvRegularExpression);
                    }
                }
            }];
        }
    }];
    
//    NSString *hd = device.deviceType == Device_20 ? @"3B" : @"3A"; // 协议版本
//
//    NSString *sj = @"00";   // 数据
//
//    NSString *bh = number;  // 电池编号
//    NSString *zl = @"24";   // 指令
//    NSString *cd = [NSString stringWithFormat:@"%02X", sj.length/2];     // 数据长度
//
//    NSString *tmp = [NSString stringWithFormat:@"%@%@%@%@", bh, zl, cd, sj];
//    NSString *sum = [BluetoothHelper hexSum:tmp];     // SUM
//
//    NSString *hexString = [NSString stringWithFormat:@"%@%@%@0D0A", hd, tmp, sum];
//    NSString *recvRExpr = [NSString stringWithFormat:@"^%@%@%@[0-9a-zA-Z]{6,54}0D0A$", hd, bh, zl];
//    NSString *desString = [NSString stringWithFormat:@"%@%@", @"读取电压1-12S", @""];
//
//    [[GRMBluetoothManager sharedGRMBluetoothManager] sendDataWithHexString:hexString recvRegularExpression:recvRExpr registerID:recvRExpr description:desString withSingleTimeout:2 timeoutRepeatsCount:3 result:^(NSString * _Nonnull registerID, OPERATION_ERROR code, NSString * _Nonnull msg, NSString * _Nullable recvDataString, NSString * _Nullable recvRegularExpression, NSString * _Nullable sendHexString) {
//        if (code == OPERATION_SUCCEEDED) {
//            if (block) {
//                block(sendHexString, code, msg, recvDataString, recvRegularExpression);
//            }
//        }
//        else if (code == TIME_OUT_ERROR) {
//            device.deviceType = Device_10;
//
//            NSString *hd = device.deviceType == Device_20 ? @"3B" : @"3A"; // 协议版本
//
//            NSString *sj = @"00";   // 数据
//
//            NSString *bh = number;  // 电池编号
//            NSString *zl = @"24";   // 指令
//            NSString *cd = [NSString stringWithFormat:@"%02X", sj.length/2];     // 数据长度
//
//            NSString *tmp = [NSString stringWithFormat:@"%@%@%@%@", bh, zl, cd, sj];
//            NSString *sum = [BluetoothHelper hexSum:tmp];     // SUM
//
//            NSString *hexString = [NSString stringWithFormat:@"%@%@%@0D0A", hd, tmp, sum];
//            NSString *recvRExpr = [NSString stringWithFormat:@"^%@%@%@[0-9a-zA-Z]{6,54}0D0A$", hd, bh, zl];
//            NSString *desString = [NSString stringWithFormat:@"%@%@", @"读取电压1-12S", @""];
//
//            [[GRMBluetoothManager sharedGRMBluetoothManager] sendDataWithHexString:hexString recvRegularExpression:recvRExpr registerID:recvRExpr description:desString withSingleTimeout:2 timeoutRepeatsCount:3 result:^(NSString * _Nonnull registerID, OPERATION_ERROR code, NSString * _Nonnull msg, NSString * _Nullable recvDataString, NSString * _Nullable recvRegularExpression, NSString * _Nullable sendHexString) {
//                if (code == OPERATION_SUCCEEDED) {
//                    if (block) {
//                        block(sendHexString, code, msg, recvDataString, recvRegularExpression);
//                    }
//                }
//                else if (code == TIME_OUT_ERROR) {
//                    if (block) {
//                        block(sendHexString, code, msg, recvDataString, recvRegularExpression);
//                    }
//                }
//            }];
//        }
//
//    }];
}

#pragma mark - 批量取读EEPROM
+ (void)number:(NSString *)number batchRead:(NSArray <NSNumber *> *)types index:(NSInteger)index result:(void (^)(NSString *sendHexString, OPERATION_ERROR code, NSString *msg, NSString * __nullable recvDataString, NSString * __nullable recvRegularExpression, OperationType type))block {
    OperationType operation = (OperationType)[[types objectAtIndex:index] integerValue];
    
    [BluetoothHelper number:number read:operation result:^(NSString * _Nonnull sendHexString, OPERATION_ERROR code, NSString * _Nonnull msg, NSString * _Nullable recvDataString, NSString * _Nullable recvRegularExpression) {
        
        block(sendHexString, code, msg, recvDataString, recvRegularExpression, operation);
        
        if (code == OPERATION_SUCCEEDED && index < types.count - 1) {
            [BluetoothHelper number:number batchRead:types index:index+1 result:block];
        }
    }];
}

#pragma mark - 写入EEPROM
/**
 写入EEPROM
 0x3A(包头) + 电池编号(1B) + 0xE9(指令) + [0x02+n(数据字节数)] + 0x86 + 地址(数据) + DATA(n) + SUM(2B) + 0x0D + 0x0A
 0x3A(包头) + 电池编号(1B) + 0xE9(指令) + 16(数据字节数) + DATA(16B) + SUM(2B) + 0x0D + 0x0A
 
 传地址时，只需要传首地址。 传输数据时，低字节在前    一次最多可以写入16个字节
 设计容量（mAH）                0x00 - 0x03           充电保护电流        0x6C - 0x6F           电芯充电过温           0x98
 设计电压（mV）                   0x04 - 0x07           放电保护电流        0x74 - 0x77           电芯充电过温释放    0x99
 满充容量（mAH）                0x08 - 0x0B           电芯过电压值        0x80 - 0x81           电芯充电低温值        0x9A
 快速充电电压（mV）           0x0C - 0x0F           电芯过充释放        0x82 - 0x83           电芯充电低温释放     0x9B
 快速充电电流（mA）           0x10 - 0x11            电芯欠电压值         0x84 - 0x85
 电池串数                               0x1D                      电芯过放释放        0x86 - 0x87           电芯放电过温            0x9C
 充到100%时的电流（MA)    0x1E - 0x1F           电池过充电压值     0x88 - 0x8B           电芯放电过温释放    0x9D
 充到100%时的电压（mV）  0x20 - 0x23           电池过充释放         0x8C - 0x8F          电芯放电低温值        0x9E
 放0%时的电压（mV）         0x24 - 0x27            电池过放电压值      0x90 - 0x93          电芯放电低温释放    0x9F
 EDV2 7%时的电压               0x28 - 0x2B           电池过放释放         0x94 - 0x97
 EDV1 3%时的电压               0x2C - 0x2F           短路电流/时间数据        0X62
 EDV0 0%时的电压               0x30 - 0x33            硬件过流/时间数据        0X63
*/
+ (void)number:(NSString *)number write:(OperationType)type value:(NSInteger)value result:(void (^)(NSString *sendHexString, OPERATION_ERROR code, NSString *msg, NSString * __nullable recvDataString, NSString * __nullable recvRegularExpression, OperationType type))block {
    GRMDevice *device = [GRMBluetoothManager sharedGRMBluetoothManager].device;
    NSString *hd = device.deviceType == Device_20 ? @"3B" : @"3A"; // 协议版本
    
    NSString *dz = [BluetoothHelper addressWithOprationType:type];   // 地址
    NSString *sj = [InsConvertTools low2Height_HexStringFromValue:value];   // 数据
    
    NSString *bh = number;  // 电池编号
    NSString *zl = device.deviceType == Device_20 ? @"EB" : @"E9";   // 指令
    NSString *cd = [NSString stringWithFormat:@"%02X", 1 + dz.length/2 + sj.length/2];     // 数据长度
    
    NSString *tmp = [NSString stringWithFormat:@"%@%@%@86%@%@", bh, zl, cd, dz, sj];
    NSString *sum = [BluetoothHelper hexSum:tmp];     // SUM
    
    NSString *hexString = [NSString stringWithFormat:@"%@%@%@0D0A", hd, tmp, sum];
    NSString *recvRExpr = [NSString stringWithFormat:@"^%@%@%@[0-9a-zA-Z]{6,54}0D0A$", hd, bh, zl];
    NSString *desString = [NSString stringWithFormat:@"%@(%@)", @"写入EEPROM", [BluetoothHelper descriptionWithOprationType:type]];
    
    [[GRMBluetoothManager sharedGRMBluetoothManager] sendDataWithHexString:hexString recvRegularExpression:recvRExpr description:desString result:^(NSString * _Nonnull registerID, OPERATION_ERROR code, NSString * _Nonnull msg, NSString * _Nullable recvDataString, NSString * _Nullable recvRegularExpression, NSString * _Nonnull sendHexString) {
        if (block) {
            block(sendHexString, code, msg, recvDataString, recvRegularExpression, type);
        }
    }];
}

#pragma mark - private
+ (NSString *)hexSum:(NSString *)hexString {
    if (hexString.length%2 != 0) {
        NSLog(@"指令长度错误");
        return @"0000";
    }
    
    NSInteger sum = 0;
    NSInteger count = hexString.length/2;
    for (int i = 0; i < count; i++) {
        
        unsigned int anInt;
        NSString * hexCharStr = [hexString substringWithRange:NSMakeRange(2*i, 2)];
        NSScanner * scanner = [[NSScanner alloc] initWithString:hexCharStr];
        [scanner scanHexInt:&anInt];
        
        sum += anInt;
    }
    
    NSString *tmpString = [NSString stringWithFormat:@"%04X", sum];
    tmpString = [InsConvertTools reversalHexString:tmpString];
    
    return tmpString;
}

+ (NSString *)numberBattery {
    return @"16";
}

+ (NSDictionary *)typeInfoWithOprationType:(OperationType)type {
    GRMDevice *device = [GRMBluetoothManager sharedGRMBluetoothManager].device;
    BOOL isDevice_20 = device.deviceType == Device_20;
    NSArray *typeArray = @[@{@"address":isDevice_20 ? @"0000" : @"00", @"length":@(4), @"description":@"设计容量（mAH） 0x00 - 0x03"},
                           @{@"address":isDevice_20 ? @"0400" : @"04", @"length":@(4), @"description":@"设计电压（mV）  0x04 - 0x07"},
                           @{@"address":isDevice_20 ? @"0800" : @"08", @"length":@(4), @"description":@"满充容量（mAH） 0x08 - 0x0B"},
                           @{@"address":isDevice_20 ? @"0C00" : @"0C", @"length":@(4), @"description":@"快速充电电压（mV）  0x0C - 0x0F"},
                           @{@"address":isDevice_20 ? @"1000" : @"10", @"length":@(2), @"description":@"快速充电电流（mA）  0x10 - 0x11"},
                           @{@"address":isDevice_20 ? @"1D00" : @"1D", @"length":@(1), @"description":@"主芯片电池串数      0x1D"},
                           @{@"address":isDevice_20 ? @"1C00" : @"1C", @"length":@(1), @"description":@"副芯片电池串数      0x1C"},
                           @{@"address":isDevice_20 ? @"1E00" : @"1E", @"length":@(2), @"description":@"充到100%时的电流（MA)   0x1E - 0x1F"},
                           @{@"address":isDevice_20 ? @"2000" : @"20", @"length":@(4), @"description":@"充到100%时的电压（mV）  0x20 - 0x23"},
                           @{@"address":isDevice_20 ? @"2400" : @"24", @"length":@(4), @"description":@"放0%时的电压（mV）      0x24 - 0x27"},
                           @{@"address":isDevice_20 ? @"2800" : @"28", @"length":@(4), @"description":@"EDV2 7%时的电压    0x28 - 0x2B"},
                           @{@"address":isDevice_20 ? @"2C00" : @"2C", @"length":@(4), @"description":@"EDV1 3%时的电压    0x2C - 0x2F"},
                           @{@"address":isDevice_20 ? @"3000" : @"30", @"length":@(4), @"description":@"EDV0 0%时的电压    0x30 - 0x33"},
                           @{@"address":isDevice_20 ? @"6C00" : @"6C", @"length":@(4), @"description":@"充电保护电流        0x6C - 0x6F"},
                           @{@"address":isDevice_20 ? @"7400" : @"74", @"length":@(4), @"description":@"放电保护电流        0x74 - 0x77"},
                           @{@"address":isDevice_20 ? @"8000" : @"80", @"length":@(2), @"description":@"电芯过充电压值      0x80 - 0x81"},
                           @{@"address":isDevice_20 ? @"8200" : @"82", @"length":@(2), @"description":@"电芯过充释放        0x82 - 0x83"},
                           @{@"address":isDevice_20 ? @"8400" : @"84", @"length":@(2), @"description":@"电芯欠电压值        0x84 - 0x85"},
                           @{@"address":isDevice_20 ? @"8600" : @"86", @"length":@(2), @"description":@"电芯过放释放        0x86 - 0x87"},
                           @{@"address":isDevice_20 ? @"8800" : @"88", @"length":@(4), @"description":@"电池过充电压值      0x88 - 0x8B"},
                           @{@"address":isDevice_20 ? @"8C00" : @"8C", @"length":@(4), @"description":@"电池过充释放        0x8C - 0x8F"},
                           @{@"address":isDevice_20 ? @"9000" : @"90", @"length":@(4), @"description":@"电池过放电压值      0x90 - 0x93"},
                           @{@"address":isDevice_20 ? @"9400" : @"94", @"length":@(4), @"description":@"电池过放释放        0x94 - 0x97"},
                           @{@"address":isDevice_20 ? @"6200" : @"62", @"length":@(1), @"description":@"短路电流/时间数据    0x62"},
                           @{@"address":isDevice_20 ? @"6300" : @"63", @"length":@(1), @"description":@"硬件过流/时间数据    0x63"},
                           @{@"address":isDevice_20 ? @"9800" : @"98", @"length":@(1), @"description":@"电芯充电过温        0x98"},
                           @{@"address":isDevice_20 ? @"9900" : @"99", @"length":@(1), @"description":@"电芯充电过温释放     0x99"},
                           @{@"address":isDevice_20 ? @"9A00" : @"9A", @"length":@(1), @"description":@"电芯充电低温值      0x9A"},
                           @{@"address":isDevice_20 ? @"9B00" : @"9B", @"length":@(1), @"description":@"电芯充电低温释放     0x9B"},
                           @{@"address":isDevice_20 ? @"9C00" : @"9C", @"length":@(1), @"description":@"电芯放电过温        0x9C"},
                           @{@"address":isDevice_20 ? @"9D00" : @"9D", @"length":@(1), @"description":@"电芯放电过温释放     0x9D"},
                           @{@"address":isDevice_20 ? @"9E00" : @"9E", @"length":@(1), @"description":@"电芯放电低温值      0x9E"},
                           @{@"address":isDevice_20 ? @"9F00" : @"9F", @"length":@(1), @"description":@"电芯放电低温释放     0x9F"},
                           @{@"address":isDevice_20 ? @"BA00" : @"BA", @"length":@(2), @"description":@"电流校准           0xBA - 0xBB  ；新的校准值=(填入的值/读出来的值)*原校准值"},
                           @{@"address":@"1D01", @"length":@(1), @"description":@"(仅2.0及以上)MCU_STATE       0x11D"},
                          ];
    
    NSDictionary *typeInfo = [typeArray objectAtIndex:type];
    return typeInfo;
}

+ (NSString *)addressWithOprationType:(OperationType)type {
    NSDictionary *typeInfo = [BluetoothHelper typeInfoWithOprationType:type];
    NSString *address = [typeInfo objectForKey:@"address"];
    return address;
}
+ (NSString *)descriptionWithOprationType:(OperationType)type {
    NSDictionary *typeInfo = [BluetoothHelper typeInfoWithOprationType:type];
    NSString *description = [typeInfo objectForKey:@"description"];
    return description;
}
+ (NSUInteger)lengthWithOprationType:(OperationType)type {
    NSDictionary *typeInfo = [BluetoothHelper typeInfoWithOprationType:type];
    NSInteger length = [[typeInfo objectForKey:@"length"] integerValue];
    return length;
}
+ (void)setValueFromRecvHexString:(NSString *)hexString withType:(OperationType)type toDevice:(GRMDevice *)device {
    if (hexString.length < 16) {
        return;
    }
    
    NSInteger length = [BluetoothHelper lengthWithOprationType:type] * 2;
    NSString *dataString  = [hexString substringWithRange:NSMakeRange(8, hexString.length-2*8)];
    NSString *valueString = [dataString substringWithRange:NSMakeRange(0, length)];
    
    NSInteger value = [InsConvertTools intFrom_Low2Height_HexString:valueString];
    NSString *tmp = @"0";
    switch (type) {
        case OP_sjrl:
        {
            value = [InsConvertTools zintFrom_Low2Height_HexString:valueString];
            tmp = [NSString stringWithFormat:@"%.3f", value/1000.0];
            device.sjrl = [NSString stringWithFormat:@"%@AH", @([tmp floatValue])];
        }
        break;
            
        case OP_mcrl:
        {
            value = [InsConvertTools zintFrom_Low2Height_HexString:valueString];
            tmp = [NSString stringWithFormat:@"%.3f", value/1000.0];
            device.mcrl = [NSString stringWithFormat:@"%@AH", @([tmp floatValue])];
        }
        break;
            
        case OP_cd100dl:
        {
            tmp = [NSString stringWithFormat:@"%.3f", value/1000.0];
            device.cd100dl = [NSString stringWithFormat:@"%@A", @([tmp floatValue])];
        }
        break;
            
        case OP_sjdy:
        {
            tmp = [NSString stringWithFormat:@"%.3f", value/1000.0];
            device.sjdy = [NSString stringWithFormat:@"%@V", @([tmp floatValue])];
        }
        break;
            
        case OP_f0dy:
        {
            tmp = [NSString stringWithFormat:@"%.3f", value/1000.0];
            device.fd0dy = [NSString stringWithFormat:@"%@V", @([tmp floatValue])];
        }
        break;
            
        case OP_cd100dy:
        {
            tmp = [NSString stringWithFormat:@"%.3f", value/1000.0];
            device.cd100dy = [NSString stringWithFormat:@"%@V", @([tmp floatValue])];
        }
        break;
            
        case OP_dccs:
        {
            device.dccs = [NSString stringWithFormat:@"%ld", value];
        }
        break;
            
        case OP_dccs2:
        {
            device.dccs2 = [NSString stringWithFormat:@"%ld", value];
        }
        break;
        
        case OP_dxgcdyz:
        {
            tmp = [NSString stringWithFormat:@"%.3f", value/1000.0];
            device.dxgcdyz = [NSString stringWithFormat:@"%@V", @([tmp floatValue])];
        }
        break;
        
        case OP_dxgcsf:
        {
            tmp = [NSString stringWithFormat:@"%.3f", value/1000.0];
            device.dxgcsf = [NSString stringWithFormat:@"%@V", @([tmp floatValue])];
        }
        break;
        
        case OP_dxqdyz:
        {
            tmp = [NSString stringWithFormat:@"%.3f", value/1000.0];
            device.dxqdyz = [NSString stringWithFormat:@"%@V", @([tmp floatValue])];
        }
        break;
        
        case OP_dxgfsf:
        {
            tmp = [NSString stringWithFormat:@"%.3f", value/1000.0];
            device.dxgfsf = [NSString stringWithFormat:@"%@V", @([tmp floatValue])];
        }
        break;
        
        case OP_dcgcdyz:
        {
            tmp = [NSString stringWithFormat:@"%.3f", value/1000.0];
            device.dcgcdyz = [NSString stringWithFormat:@"%@V", @([tmp floatValue])];
        }
        break;
        
        case OP_dcgcsf:
        {
            tmp = [NSString stringWithFormat:@"%.3f", value/1000.0];
            device.dcgcsf = [NSString stringWithFormat:@"%@V", @([tmp floatValue])];
        }
        break;
        
        case OP_dcgfdyz:
        {
            tmp = [NSString stringWithFormat:@"%.3f", value/1000.0];
            device.dcgfdyz = [NSString stringWithFormat:@"%@V", @([tmp floatValue])];
        }
        break;
        
        case OP_dcgfsf:
        {
            tmp = [NSString stringWithFormat:@"%.3f", value/1000.0];
            device.dcgfsf = [NSString stringWithFormat:@"%@V", @([tmp floatValue])];
        }
        break;
        
        case OP_dxcdgw:
        {
            device.dxcdgw = [NSString stringWithFormat:@"%ld℃", value];
        }
        break;
        
        case OP_dxcdgwsf:
        {
            device.dxcdgwsf = [NSString stringWithFormat:@"%ld℃", value];
        }
        break;
        
        case OP_dxcddwz:
        {
            device.dxcddwz = [NSString stringWithFormat:@"%ld℃", value];
        }
        break;
        
        case OP_dxcddwsf:
        {
            device.dxcddwsf = [NSString stringWithFormat:@"%ld℃", value];
        }
        break;
        
        case OP_dxfdgw:
        {
            device.dxfdgw = [NSString stringWithFormat:@"%ld℃", value];
        }
        break;
        
        case OP_dxfdgwsf:
        {
            device.dxfdgwsf = [NSString stringWithFormat:@"%ld℃", value];
        }
        break;
        
        case OP_dxfddwz:
        {
            device.dxfddwz = [NSString stringWithFormat:@"%ld℃", value];
        }
        break;
        
        case OP_dxfddwsf:
        {
            device.dxfddwsf = [NSString stringWithFormat:@"%ld℃", value];
        }
        break;
            
        case OP_dlxz:
        {
            value = [InsConvertTools zintFrom_Low2Height_HexString:valueString];
            device.dlxz = [NSString stringWithFormat:@"%ld", value];
        }
        break;
            
        case OP_mcuState:
        {
            device.mcuState = [NSString stringWithFormat:@"%ld", value];
        }
            
        default:
            break;
    }
}

+ (NSArray *)valueArrayWithType:(OperationType)type {
    if (type == OP_yjglsjsj) {
        return @[@"17", @"22", @"28", @"33", @"39", @"44", @"50", @"56", @"61", @"67", @"72", @"78", @"83", @"89", @"94", @"100"];
    }
    
    if (type == OP_dldlsjsj) {
        return @[@"44", @"67", @"89", @"111", @"133", @"155", @"178", @"200"];
    }
    
    return @[];
}

@end
