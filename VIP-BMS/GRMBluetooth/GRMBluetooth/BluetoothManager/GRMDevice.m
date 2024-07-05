//
//  GRMDevice.m
//  TheKoran
//
//  Created by _G.R.M. on 2019/12/19.
//  Copyright © 2019 goorume. All rights reserved.
//

#import "GRMDevice.h"
#import "GRMDevice+Private.h"

#import "InsConvertTools.h"

@implementation GRMDevice

- (instancetype)initWithName:(NSString *)name {
    self = [super init];
    if (self) {
        _name = name;
        _realName = @"GQ 8861";
    }
    return self;
}

- (instancetype)initWithPerpheral:(CBPeripheral *)peripheral {
    self = [super init];
    if (self) {
        _peripheral = peripheral;
        
        _name = peripheral.name;
        _realName = @"GQ 8861";
        
//        NSString *mac = peripheral.name;
//        if (mac.length == 12) {
//            mac = [mac uppercaseString];
//            _mac = [NSString stringWithFormat:@"%@:%@:%@:%@:%@:%@",
//                    [mac substringWithRange:NSMakeRange(0, 2)],
//                    [mac substringWithRange:NSMakeRange(2, 2)],
//                    [mac substringWithRange:NSMakeRange(4, 2)],
//                    [mac substringWithRange:NSMakeRange(6, 2)],
//                    [mac substringWithRange:NSMakeRange(8, 2)],
//                    [mac substringWithRange:NSMakeRange(10, 2)]];
//        } else {
//            NSLog(@"蓝牙MAC长度不合法");
//        }
        _uuidIdentifier = peripheral.identifier.UUIDString;
        
    }
    return self;
}
- (NSString *)description {
    return [NSString stringWithFormat:@"<%@>%@", _name, _uuidIdentifier];
}

/** 是否已经存在数组中 */
- (GRMDevice *)matchFromArray:(NSArray<GRMDevice *> *)devicesArray {
    
    GRMDevice *matchDevice = nil;
    
    for (int i = 0; i < devicesArray.count; i++) {
        
        GRMDevice *device = [devicesArray objectAtIndex:i];
        
        if ([device.name isEqualToString:self.name]) {
            
            matchDevice = device;
            
            break;
        }
    }
    
    return matchDevice;
}
+ (GRMDevice *)match:(NSString *)name formArray:(NSArray<GRMDevice *> *)devicesArray {
    
    GRMDevice *matchDevice = [[GRMDevice alloc] initWithName:name];
    return [matchDevice matchFromArray:devicesArray];
}

/** 按门锁的距离小到大排序数组，返回应插入的index -73近于-74 */
- (NSInteger)indexFromArray:(NSArray<GRMDevice *> *)deviceArray {
    
    NSInteger index = 0;
    for (NSInteger i = 0; i < deviceArray.count; i++) {
        GRMDevice *device = [deviceArray objectAtIndex:i];
        if (labs(self.RSSI) < labs(device.RSSI)) {
            break;
        } else {
            index += 1;
        }
    }
    
    return index;
}



#pragma mark - private
- (void)writeDataWithString:(NSString *)insString {
    NSAssert(insString.length%2 == 0, @"指令有误!");
    
    NSData *insData = [InsConvertTools dataFromHexString:insString];
    
    [self writeData:insData];
}

- (void)writeData:(NSData *)insData {
//    NSLog(@"[BlueTooth]Send Value == %@", insData);
//    [self.peripheral setNotifyValue:YES forCharacteristic:self.characteristicFA01];
    [self.peripheral writeValue:insData forCharacteristic:self.characteristicFA02 type:CBCharacteristicWriteWithoutResponse];
}


#pragma mark - 业务
- (void)getVoltage12FromRecvHexString:(NSString *)recvHexString {
    if (recvHexString.length < 56) {
        return;
    }
    
    NSString *dataString = [recvHexString substringWithRange:NSMakeRange(8, recvHexString.length-2*8)];
    
    NSMutableArray *values = [NSMutableArray array];
    NSInteger count = dataString.length/4;
    for (int i = 0; i < count; i++) {
        NSString *tmp = [dataString substringWithRange:NSMakeRange(i*4, 4)];
        NSNumber *value = [NSNumber numberWithUnsignedInteger:[InsConvertTools intFrom_Low2Height_HexString:tmp]];
        if ([value unsignedIntegerValue] > 0) {
            [values addObject:value];
        }
    }
    
    _voltage12Array = values;
}

- (void)getVoltage24FromRecvHexString:(NSString *)recvHexString {
    if (recvHexString.length < 56) {
        return;
    }
    
    NSString *dataString = [recvHexString substringWithRange:NSMakeRange(8, recvHexString.length-2*8)];
    
    NSMutableArray *values = [NSMutableArray array];
    NSInteger count = dataString.length/4;
    for (int i = 0; i < count; i++) {
        NSString *tmp = [dataString substringWithRange:NSMakeRange(i*4, 4)];
        NSNumber *value = [NSNumber numberWithUnsignedInteger:[InsConvertTools intFrom_Low2Height_HexString:tmp]];
        if ([value unsignedIntegerValue] > 0) {
            [values addObject:value];
        }
    }
    
    _voltage24Array = values;
}

- (void)getVoltage32FromRecvHexString:(NSString *)recvHexString {
    if (recvHexString.length < 48) {
        return;
    }
    // 0x3B(包头) + 电池编号(1B) + 0x26(指令) + 20(数据字节数) + 25-32S电压(16B) + 均衡状态（4B） + SUM(2B) + 0x0D + 0x0A
    
    NSString *dataString = [recvHexString substringWithRange:NSMakeRange(8, recvHexString.length-2*8-8)];
    
    NSMutableArray *values = [NSMutableArray array];
    NSInteger count = dataString.length/4;
    for (int i = 0; i < count; i++) {
        NSString *tmp = [dataString substringWithRange:NSMakeRange(i*4, 4)];
        NSNumber *value = [NSNumber numberWithUnsignedInteger:[InsConvertTools intFrom_Low2Height_HexString:tmp]];
        if ([value unsignedIntegerValue] > 0) {
            [values addObject:value];
        }
    }
    
    _voltage32Array = values;
    
    // 均衡状态
    NSString *jhztString = [recvHexString substringWithRange:NSMakeRange(40, 8)];
    _jhzt = [NSString stringWithFormat:@"%ld", strtol([jhztString UTF8String], 0, 16)];
}

- (void)getInfomation1FromRecvHexString:(NSString *)recvHexString {
    if (recvHexString.length < 56) {
        return;
    }
    // 数据24B为 电流MA(4B)+总电压MV(4B)+温度1(1B)+温度2(1B)+温度3(1B)+温度4(1B)+剩余容量MAH(4B)+充电状态(1B)+放电状态(1B)+充电预警(1B)+放电预警(1B)+剩余容量%(1B)+留用(3B)
    NSString *dataString = [recvHexString substringWithRange:NSMakeRange(8, recvHexString.length-2*8)];
    
    NSInteger value = 0;
    NSString *temp = @"0";
    
    value = [InsConvertTools intFrom_Low2Height_HexString:[dataString substringWithRange:NSMakeRange(0, 8)]];
    temp = [NSString stringWithFormat:@"%.3f", value/1000.0];
    _dlMA = [NSString stringWithFormat:@"%@A", @([temp floatValue])];
    
    value = [InsConvertTools intFrom_Low2Height_HexString:[dataString substringWithRange:NSMakeRange(8, 8)]];
    temp = [NSString stringWithFormat:@"%.3f", value/1000.0];
    _dyMV = [NSString stringWithFormat:@"%@V", @([temp floatValue])];
    
    value = [InsConvertTools intFrom_Low2Height_HexString:[dataString substringWithRange:NSMakeRange(16, 2)]];
    _wd1 = [NSString stringWithFormat:@"%ld℃", value];
    
    value = [InsConvertTools intFrom_Low2Height_HexString:[dataString substringWithRange:NSMakeRange(18, 2)]];
    _wd2 = [NSString stringWithFormat:@"%ld℃", value];
    
    value = [InsConvertTools intFrom_Low2Height_HexString:[dataString substringWithRange:NSMakeRange(20, 2)]];
    _wd3 = [NSString stringWithFormat:@"%ld℃", value];
    
    value = [InsConvertTools intFrom_Low2Height_HexString:[dataString substringWithRange:NSMakeRange(22, 2)]];
    _wd4 = [NSString stringWithFormat:@"%ld℃", value];
    
    value = [InsConvertTools intFrom_Low2Height_HexString:[dataString substringWithRange:NSMakeRange(24, 8)]];
    temp = [NSString stringWithFormat:@"%.3f", value/1000.0];
    _syrl = [NSString stringWithFormat:@"%@Ah", @([temp floatValue])];
    
    value = [InsConvertTools intFrom_Low2Height_HexString:[dataString substringWithRange:NSMakeRange(32, 2)]];
    _cdzt = [NSString stringWithFormat:@"%ld", value];
    
    value = [InsConvertTools intFrom_Low2Height_HexString:[dataString substringWithRange:NSMakeRange(34, 2)]];
    _fdzt = [NSString stringWithFormat:@"%ld", value];
    
    value = [InsConvertTools intFrom_Low2Height_HexString:[dataString substringWithRange:NSMakeRange(36, 2)]];
    _cdyj = [NSString stringWithFormat:@"%ld", value];
    
    value = [InsConvertTools intFrom_Low2Height_HexString:[dataString substringWithRange:NSMakeRange(38, 2)]];
    _fdyj = [NSString stringWithFormat:@"%ld", value];
    
    value = [InsConvertTools intFrom_Low2Height_HexString:[dataString substringWithRange:NSMakeRange(40, 2)]];
    _syrl_p = [NSString stringWithFormat:@"%ld%%", value];
}

- (void)getInfomation2FromRecvHexString:(NSString *)recvHexString {
    if (recvHexString.length < 56) {
            return;
    }
    // 数据24B为 设计容量MAH(4B)+设计电压MV(4B)+满充容量MAH(4B)+充电电压MV(4B)+充电电流MA(2B)+电池生产序列号(2B) + 电池生产日期(2B) + 电池放电次数(2B)
    // int i16temp = 电池生产日期; int day = i16temp & (int)31; int month = (i16temp>>5) & (int)15; int year = ((i16temp>>9) & (int)127) + 1980;
    NSString *dataString = [recvHexString substringWithRange:NSMakeRange(8, recvHexString.length-2*8)];
    
    NSInteger value = 0;
    NSString *temp = @"0";
    
    value = [InsConvertTools intFrom_Low2Height_HexString:[dataString substringWithRange:NSMakeRange(0, 8)]];
    _sjrl = [NSString stringWithFormat:@"%ldmAh", value];
    
    value = [InsConvertTools intFrom_Low2Height_HexString:[dataString substringWithRange:NSMakeRange(8, 8)]];
    temp = [NSString stringWithFormat:@"%.3f", value/1000.0];
    _sjdy = [NSString stringWithFormat:@"%@V", @([temp floatValue])];
    
    value = [InsConvertTools intFrom_Low2Height_HexString:[dataString substringWithRange:NSMakeRange(16, 8)]];
    _mcrl = [NSString stringWithFormat:@"%ldmAh", value];
    
    value = [InsConvertTools intFrom_Low2Height_HexString:[dataString substringWithRange:NSMakeRange(24, 8)]];
    _cddyMV = [NSString stringWithFormat:@"%ld", value];
    
    value = [InsConvertTools intFrom_Low2Height_HexString:[dataString substringWithRange:NSMakeRange(32, 4)]];
    _cddlMA = [NSString stringWithFormat:@"%ld", value];
    
    value = [InsConvertTools intFrom_Low2Height_HexString:[dataString substringWithRange:NSMakeRange(36, 4)]];
    _scxlh = [NSString stringWithFormat:@"%ld", value];
    
    value = [InsConvertTools intFrom_Low2Height_HexString:[dataString substringWithRange:NSMakeRange(40, 4)]];
    NSUInteger dd = (int)value & 31;
    NSUInteger MM = ((int)value>>5) & 15;
    NSUInteger yy = (((int)value>>9) & 127) + 1980;
    _scrq = [NSString stringWithFormat:@"%04ld.%02ld.%02ld", yy, MM, dd];
    
    value = [InsConvertTools intFrom_Low2Height_HexString:[dataString substringWithRange:NSMakeRange(44, 4)]];
    _fdcs = [NSString stringWithFormat:@"%ld", value];
    
}

- (void)getInfomation3FromRecvHexString:(NSString *)recvHexString {
    if (recvHexString.length < 40) {
        return;
    }
    
    // 0x3B(包头) + 电池编号(1B) + 0x27(指令) + 16(数据字节数) + 保护板IC状态(8B)+温度（8B）+ SUM(2B) + 0x0D + 0x0A
    NSString *dataString = [recvHexString substringWithRange:NSMakeRange(8, recvHexString.length-2*8)];
    
    NSInteger value = 0;
    
    value = [InsConvertTools intFrom_Low2Height_HexString:[dataString substringWithRange:NSMakeRange(16, 2)]];
    _wd1 = [NSString stringWithFormat:@"%ld℃", value];
    
    value = [InsConvertTools intFrom_Low2Height_HexString:[dataString substringWithRange:NSMakeRange(24, 2)]];
    _wd5 = [NSString stringWithFormat:@"%ld℃", value];
}

+ (NSUInteger)getValueFromRecvHexString:(NSString *)recvHexString {
    if (recvHexString.length < 16) {
            return 0;
    }
    
    NSString *dataString = [recvHexString substringWithRange:NSMakeRange(8, recvHexString.length-2*8)];
    
    if (dataString.length < 48) {
        return 0;
    }
    
    return [InsConvertTools intFrom_Low2Height_HexString:dataString];
}

@end


