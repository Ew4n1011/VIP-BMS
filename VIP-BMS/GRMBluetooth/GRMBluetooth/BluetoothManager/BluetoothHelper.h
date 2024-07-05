//
//  BluetoothHelper.h
//  GRMBluetooth
//
//  Created by goorume on 2019/12/29.
//  Copyright © 2019 goorume. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GRMBluetoothManager.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^Result)(NSString *sendHexString, OPERATION_ERROR code, NSString *msg, NSString * __nullable recvDataString, NSString * __nullable recvRegularExpression); // 发指令结果回调

typedef NS_ENUM(NSUInteger, OperationType) {
    OP_sjrl,    //    设计容量（mAH） 0x00 - 0x03
    OP_sjdy,    //    设计电压（mV）  0x04 - 0x07
    OP_mcrl,    //    满充容量（mAH） 0x08 - 0x0B
    OP_kscddy,  //    快速充电电压（mV）  0x0C - 0x0F
    OP_kscddl,  //    快速充电电流（mA）  0x10 - 0x11
    OP_dccs,    //    主芯片电池串数      0x1D
    OP_dccs2,    //   副芯片电池串数      0x1C
    OP_cd100dl, //    充到100%时的电流（MA)   0x1E - 0x1F
    OP_cd100dy, //    充到100%时的电压（mV）  0x20 - 0x23
    OP_f0dy,    //    放0%时的电压（mV）      0x24 - 0x27
    OP_efv2_7dy,//    EDV2 7%时的电压    0x28 - 0x2B
    OP_edv1_3dy,//    EDV1 3%时的电压    0x2C - 0x2F
    OP_edv1_0dy,//    EDV0 0%时的电压    0x30 - 0x33
    OP_cdbhdl,  //    充电保护电流        0x6C - 0x6F
    OP_fdbhdl,  //    放电保护电流        0x74 - 0x77
    OP_dxgcdyz, //    电芯过充电压值        0x80 - 0x81
    OP_dxgcsf,  //    电芯过充释放        0x82 - 0x83
    OP_dxqdyz,  //    电芯欠电压值        0x84 - 0x85
    OP_dxgfsf,  //    电芯过放释放        0x86 - 0x87
    OP_dcgcdyz, //    电池过充电压值      0x88 - 0x8B
    OP_dcgcsf,  //    电池过充释放        0x8C - 0x8F
    OP_dcgfdyz, //    电池过放电压值      0x90 - 0x93
    OP_dcgfsf,  //    电池过放释放        0x94 - 0x97
    OP_dldlsjsj,//    短路电流/时间数据    0x62
    OP_yjglsjsj,//    硬件过流/时间数据    0x63
    OP_dxcdgw,  //    电芯充电过温        0x98
    OP_dxcdgwsf,//    电芯充电过温释放     0x99
    OP_dxcddwz, //    电芯充电低温值      0x9A
    OP_dxcddwsf,//    电芯充电低温释放     0x9B
    OP_dxfdgw,  //    电芯放电过温        0x9C
    OP_dxfdgwsf,//    电芯放电过温释放     0x9D
    OP_dxfddwz, //    电芯放电低温值      0x9E
    OP_dxfddwsf,//    电芯放电低温释放     0x9F
    OP_dlxz,    //    电流校准           0xBA - 0xBB  ；新的校准值=(填入的值/读出来的值)*原校准值
    OP_mcuState,  //     (仅2.0及以上)MCU_STATE       0x11D
    
    OP_None,    // 无
};

@interface BluetoothHelper : NSObject

#pragma mark - 总则
/**
 0x3A(包头) + 电池编号(1B) + 指令(1B) + 数据字节数(1B) + 数据(?B) + SUM(电池编号从电池编号到数据末尾的和）2B  + 0x0D + 0x0A
 总字节数 = 数据字节数 + 8
 传输数据时，低字节在前
 电池地址： 0x16
*/

#pragma mark - 读取电压1-12S
/**
 读取电压1-12S
 0x3A(包头) + 电池编号(1B) + 0x24(指令) + 0x01(数据字节数) + 0x00(数据) + SUM(2B) + 0x0D + 0x0A
 0x3A(包头) + 电池编号(1B) + 0x24(指令) + 24(数据字节数) + 1-12S电压(24B) + SUM(2B) + 0x0D + 0x0A
 电压24B为 1S电压(2B)+2S电压(2B)....+12S电压(2B)     (MV)
 */
+ (void)number:(NSString *)number voltage12Resutl:(Result)block;

#pragma mark - 读取电压13-24S
/**
 读取电压13-24S
 0x3A(包头) + 电池编号(1B) + 0x25(指令) + 0x01(数据字节数) + 0x00(数据) + SUM(2B) + 0x0D + 0x0A
 0x3A(包头) + 电池编号(1B) + 0x25(指令) + 24(数据字节数) + 13-24S电压(24B) + SUM(2B) + 0x0D + 0x0A
 电压24B为 13S电压(2B)+14S电压(2B)....+24S电压(2B)   (MV)
 */
+ (void)number:(NSString *)number voltage24Resutl:(Result)block;

#pragma mark - (仅2.0及以上)读取电压25-32S
/**
 读取电压25-32S
 0x3B(包头) + 电池编号(1B) + 0x26(指令) + 0x01(数据字节数) + 0x00(数据) + SUM(2B) + 0x0D + 0x0A
 0x3B(包头) + 电池编号(1B) + 0x26(指令) + 20(数据字节数) + 25-32S电压(16B) + 均衡状态（4B） + SUM(2B) + 0x0D + 0x0A
 电压16B为 25S电压(2B)+26S电压(2B)....+32S电压(2B)   (MV)
 均衡状态32位，代表了32个电池的均衡状态（11111111111111111111111111111111）
 */
+ (void)number:(NSString *)number voltage32Resutl:(Result)block;

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
+ (void)number:(NSString *)number infomation1Result:(Result)block;

#pragma mark - 读取设计容量等
/**
 读取设计容量等
 0x3A(包头) + 电池编号(1B) + 0x2B(指令) + 0x01(数据字节数) + 0x00(数据) + SUM(2B) + 0x0D + 0x0A
 0x3A(包头) + 电池编号(1B) + 0x2B(指令) + 24(数据字节数) + 数据(24B) + SUM(2B) + 0x0D + 0x0A
 数据24B为 设计容量MAH(4B)+设计电压MV(4B)+满充容量MAH(4B)+充电电压MV(4B)+充电电流MA(2B)+电池生产序列号(2B) + 电池生产日期(2B) + 电池放电次数(2B)

 int i16temp = 电池生产日期; int day = i16temp & (int)31; int month = (i16temp>>5) & (int)15; int year = ((i16temp>>9) & (int)127) + 1980;*/
+ (void)number:(NSString *)number infomation2Result:(Result)block;

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
 */
+ (void)number:(NSString *)number infomation3Result:(Result)block;

#pragma mark - (仅2.0及以上)读取软件版本的数据
/**
 读取保护板IC的数据
 0x3B(包头) + 电池编号(1B) + 0x28(指令) + 0x01(数据字节数) + 0x00(数据) + SUM(2B) + 0x0D + 0x0A
 0x3B(包头) + 电池编号(1B) + 0x28(指令) + 16(数据字节数) + DATA(16B) + SUM(2B) + 0x0D + 0x0A
 DAT:第一字节是长度
 */
+ (void)number:(NSString *)number getVersionResult:(Result)block;

#pragma mark - 读取EEPROM
/**
 读取EEPROM
 0x3A(包头) + 电池编号(1B) + 0xE8(指令) + 0x01(数据字节数) + 地址(数据) + SUM(2B) + 0x0D + 0x0A
 0x3A(包头) + 电池编号(1B) + 0xE8(指令) + 16(数据字节数) + DATA(16B) + SUM(2B) + 0x0D + 0x0A
*/
+ (void)number:(NSString *)number read:(OperationType)type result:(Result)block;

#pragma mark - 读取设备版本，对应新旧协议
/**
 读取设备类型，对应新旧协议。连接成功后，第一个要发送的指令
 设备不支持读取设备类型，只能尝试发送旧版本协议，有应答则为旧版本设备；无应答再发新版本协议，有应答则为新版本设备
 使用『读取电压1-12S』指令的返回情况来判断设备类型
 */
+ (void)number:(NSString *)number readDeviceTypeWithResult:(Result)block;

#pragma mark - 批量取读EEPROM
+ (void)number:(NSString *)number batchRead:(NSArray <NSNumber *> *)types index:(NSInteger)index result:(void (^)(NSString *sendHexString, OPERATION_ERROR code, NSString *msg, NSString * __nullable recvDataString, NSString * __nullable recvRegularExpression, OperationType type))block;

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
 副芯片电池串数               0x1C
 主芯片电池串数               0x1D                    电芯过放释放        0x86 - 0x87           电芯放电过温            0x9C
 充到100%时的电流（MA)    0x1E - 0x1F           电池过充电压值     0x88 - 0x8B           电芯放电过温释放    0x9D
 充到100%时的电压（mV）  0x20 - 0x23           电池过充释放         0x8C - 0x8F          电芯放电低温值        0x9E
 放0%时的电压（mV）         0x24 - 0x27            电池过放电压值      0x90 - 0x93          电芯放电低温释放    0x9F
 EDV2 7%时的电压               0x28 - 0x2B           电池过放释放         0x94 - 0x97
 EDV1 3%时的电压               0x2C - 0x2F           短路电流/时间数据        0X62
 EDV0 0%时的电压               0x30 - 0x33            硬件过流/时间数据        0X63
 MCU_STATE位(仅2.0及以上)        0x11D
*/
+ (void)number:(NSString *)number write:(OperationType)type value:(NSInteger)value result:(void (^)(NSString *sendHexString, OPERATION_ERROR code, NSString *msg, NSString * __nullable recvDataString, NSString * __nullable recvRegularExpression, OperationType type))block;


+ (void)setValueFromRecvHexString:(NSString *)hexString withType:(OperationType)type toDevice:(GRMDevice *)device;


+ (NSString *)numberBattery;
+ (NSArray *)valueArrayWithType:(OperationType)type;


@end

NS_ASSUME_NONNULL_END
