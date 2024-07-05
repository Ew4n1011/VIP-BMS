//
//  GRMBluetoothManager.h
//  TheKoran
//
//  Created by _G.R.M. on 2019/12/18.
//  Copyright © 2019 goorume. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#import "GRMDevice.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, OPERATION_ERROR) {
    
    OPERATION_SUCCEEDED      = 0,
    
    DISCONNECT_ERROR    = 50,   // 未连接
    
    CONNECT_ERROR       = 101,  // 连接失败
    REPLY_ERROR,                // 应答失败
    
    
    INS_FORMAT_ERROR    = 201,  // 指令格式错误
    
    
    CANCEL_ERROR        = 301,  // 用户取消
    TIME_OUT_ERROR,             // 操作超时
    
    
    UNKNOWN_ERROR       = 999   // 未知错误
};


/** 蓝牙变化通知 */
static NSString *NotificationBlueToothStateChange = @"_BlueToothStateChange";
/** 蓝牙断开通知 */
static NSString *NotificationBlueToothDisconnect  = @"_BlueToothDisconnect";
/** 接收到未注册指令 */
static NSString *NotificationBlueToothUnkowRecv   = @"_BlueToothUnkowRecv";



typedef void (^DiscoverDevicesBlock)(NSArray<GRMDevice *> *devices, OPERATION_ERROR code, NSString *msg);  // 发现设备回调
typedef void (^ConnecteDevicesBlock)(NSArray<GRMDevice *> *devices, OPERATION_ERROR code, NSString *msg);  // 连接设备回调



@interface GRMBluetoothManager : NSObject

@property (readonly, nonatomic, assign) BOOL isOpen;        // 蓝牙是否打开
@property (readonly, nonatomic, assign) BOOL isScaning;     // 正在搜索

@property (readonly, nonatomic, assign) BOOL isConnected;   // 是否已连接一个蓝牙设备
@property (nonatomic, strong) GRMDevice *device;    // 当前连接的设备

@property (nonatomic, assign) BOOL cancel;  // 取消发送指令
@property (nonatomic, assign) BOOL cancelScan;  // 取消连接、搜索


+ (GRMBluetoothManager *)sharedGRMBluetoothManager;


#pragma mark - 搜索
/** 搜索指定设备
 *  搜索到第一台，1秒后回调结果
 */
- (void)scanDevice:(NSString *)name timeout:(NSTimeInterval)timeout result:(DiscoverDevicesBlock)block;

/** 搜索一类名称规则的设备
 *  搜索到第一台，1秒后回调结果
 */
- (void)scanDevices:(NSString *)regularExpression timeout:(NSTimeInterval)timeout result:(DiscoverDevicesBlock)block;

/** 保持搜索，搜索一类名称规则的设备
 *  每搜索到一台设备，回调一次block
 */
- (void)scanDevices:(NSString *)regularExpression result:(DiscoverDevicesBlock)block;

/** 保持搜索
 *  每搜索到一台设备，回调一次block
 *  注意：自行关闭搜索
 */
- (void)scaningResult:(DiscoverDevicesBlock)block;

/** 搜索
 *  搜索到第一台，1秒后回调结果
 */
- (void)scanWithTimeout:(NSTimeInterval)timeout result:(DiscoverDevicesBlock)block;

/** 搜索 */
- (void)startScan;

/** 停止搜索 */
- (void)stopScan;


#pragma mark - 连接
/** 连接指定名称的设备 */
- (void)connectWithName:(NSString *)name timeout:(NSTimeInterval)timeout result:(ConnecteDevicesBlock)block;

/** 连接已发现的设备 */
- (void)connectWithDevice:(GRMDevice *)device result:(ConnecteDevicesBlock)block;

/** 连接设备 */
- (void)connectWithDevice:(GRMDevice *)device;


#pragma mark - 断开连接
/** 断开连接 */
- (void)disconnect;



@end

NS_ASSUME_NONNULL_END
