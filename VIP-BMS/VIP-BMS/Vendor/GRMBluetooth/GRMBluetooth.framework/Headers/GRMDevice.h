//
//  GRMDevice.h
//  TheKoran
//
//  Created by _G.R.M. on 2019/12/19.
//  Copyright © 2019 goorume. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, DeviceType) {
    Device_UN,
    
    Device_10 = 1,  // 旧版本协议
    Device_20,      // 新版本协议, 同时存在 3A 和 3B 协议
};

@interface GRMDevice : NSObject

/*====  硬件基本信息  =====*/
@property (nonatomic, assign) DeviceType deviceType;
@property (nonatomic, copy, readonly) NSString *name;  // 设备名称（蓝牙的名称）
@property (nonatomic, copy, readonly) NSString *mac;   // 蓝牙的MAC地址
@property (nonatomic, copy, readonly) NSString *uuidIdentifier;
@property (nonatomic, assign) NSInteger RSSI;    // RSSI

@property (nonatomic, copy, readonly) NSString *realName;

@property (nonatomic, assign) BOOL isConnected;


#pragma mark - 业务
- (void)getVoltage12FromRecvHexString:(NSString *)recvHexString;
@property (nonatomic, strong, readonly) NSArray<NSNumber *> *voltage12Array;


- (void)getVoltage24FromRecvHexString:(NSString *)recvHexString;
@property (nonatomic, strong, readonly) NSArray<NSNumber *> *voltage24Array;


// (仅2.0及以上)25-32S电压(16B) + 均衡状态（4B）
- (void)getVoltage32FromRecvHexString:(NSString *)recvHexString;
@property (nonatomic, strong, readonly) NSArray<NSNumber *> *voltage32Array;
@property (nonatomic, copy, readonly) NSString *jhzt; // 均衡状态, 已转 10 进制数


// 数据24B为 电流MA(4B)+总电压MV(4B)+温度1(1B)+温度2(1B)+温度3(1B)+温度4(1B)+剩余容量MAH(4B)+充电状态(1B)+放电状态(1B)+充电预警(1B)+放电预警(1B)+剩余容量%(1B)+留用(3B)
- (void)getInfomation1FromRecvHexString:(NSString *)recvHexString;
@property (nonatomic, copy, readonly) NSString *dlMA;
@property (nonatomic, copy, readonly) NSString *dyMV;
@property (nonatomic, copy, readonly) NSString *wd1;
@property (nonatomic, copy, readonly) NSString *wd2;
@property (nonatomic, copy, readonly) NSString *wd3;
@property (nonatomic, copy, readonly) NSString *wd4;
@property (nonatomic, copy, readonly) NSString *syrl;
@property (nonatomic, copy, readonly) NSString *cdzt;
@property (nonatomic, copy, readonly) NSString *fdzt;
@property (nonatomic, copy, readonly) NSString *cdyj;
@property (nonatomic, copy, readonly) NSString *fdyj;
@property (nonatomic, copy, readonly) NSString *syrl_p; // 剩余容量百分比


// 数据24B为 设计容量MAH(4B)+设计电压MV(4B)+满充容量MAH(4B)+充电电压MV(4B)+充电电流MA(2B)+电池生产序列号(2B) + 电池生产日期(2B) + 电池放电次数(2B)
- (void)getInfomation2FromRecvHexString:(NSString *)recvHexString;
@property (nonatomic, copy) NSString *sjrl;
@property (nonatomic, copy) NSString *sjdy;
@property (nonatomic, copy) NSString *mcrl;
@property (nonatomic, copy, readonly) NSString *cddyMV;
@property (nonatomic, copy, readonly) NSString *cddlMA;
@property (nonatomic, copy, readonly) NSString *scxlh;  // 生产序列号
@property (nonatomic, copy, readonly) NSString *scrq;
@property (nonatomic, copy, readonly) NSString *fdcs;


// (仅2.0及以上)保护板IC状态(8B)+温度（8B），可读出温度1-温度8，目前2.0协议只需要读取 温度1和温度5
- (void)getInfomation3FromRecvHexString:(NSString *)recvHexString;
@property (nonatomic, copy, readonly) NSString *wd5;
@property (nonatomic, copy, readonly) NSString *wd6;
@property (nonatomic, copy, readonly) NSString *wd7;
@property (nonatomic, copy, readonly) NSString *wd8;


+ (NSUInteger)getValueFromRecvHexString:(NSString *)recvHexString;
@property (nonatomic, copy) NSString *dccs;    // 主芯片电池串数
@property (nonatomic, copy) NSString *dccs2;   // 副芯片电池串数

@property (nonatomic, copy) NSString *cd100dl;    // 充到100电流
@property (nonatomic, copy) NSString *cd100dy;    // 充到100电压
@property (nonatomic, copy) NSString *fd0dy;      // 放0的电压

@property (nonatomic, copy) NSString *dxgcdyz;    // 电芯过充电压值
@property (nonatomic, copy) NSString *dxgcsf;     // 电芯过充释放
@property (nonatomic, copy) NSString *dxqdyz;     // 电芯欠电压值
@property (nonatomic, copy) NSString *dxgfsf;     // 电芯过放释放

@property (nonatomic, copy) NSString *cdbhdl;     // 充电保护电流
@property (nonatomic, copy) NSString *fdbhdl;     // 放电保护电流
@property (nonatomic, copy) NSString *yjglsjsj;   // 硬件过流/时间数据

@property (nonatomic, copy) NSString *dldlsjsj;   // 短路电流/时间数据

@property (nonatomic, copy) NSString *dxcdgw;     // 电芯充电过温
@property (nonatomic, copy) NSString *dxcdgwsf;   // 电芯充电过温释放

@property (nonatomic, copy) NSString *dxcddwz;    // 电芯充电低温值
@property (nonatomic, copy) NSString *dxcddwsf;   // 电芯充电低温释放

@property (nonatomic, copy) NSString *dxfdgw;     // 电芯放电过温
@property (nonatomic, copy) NSString *dxfdgwsf;   // 电芯放电过温释放

@property (nonatomic, copy) NSString *dxfddwz;    // 电芯放电低温值
@property (nonatomic, copy) NSString *dxfddwsf;   // 电芯放电低温释放

@property (nonatomic, copy) NSString *dcgcdyz;    // 电池过充电压值
@property (nonatomic, copy) NSString *dcgcsf;     // 电池过充释放
@property (nonatomic, copy) NSString *dcgfdyz;    // 电池过放电压值
@property (nonatomic, copy) NSString *dcgfsf;     // 电池过放释放

@property (nonatomic, copy) NSString *dlxz;       // 电流校准

// (仅2.0及以上) OP_mcuState  8bit,0-开关充电MOS; 1-开关放电MOS; 2-开关预充电MOS; 3-开关预放电MOS; 4-无; 5-无; 6-无; 7-无
@property (nonatomic, copy) NSString *mcuState;

@end


NS_ASSUME_NONNULL_END
