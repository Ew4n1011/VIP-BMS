//
//  GRMBluetoothManager.m
//  TheKoran
//
//  Created by _G.R.M. on 2019/12/18.
//  Copyright © 2019 goorume. All rights reserved.
//

#import "GRMBluetoothManager.h"

#import "GRMDevice+Private.h"
#import "GRMBluetoothManager+Private.h"

#import "InsConvertTools.h"

#define GRMWEAKSELF(object) __weak __typeof__(object) weak##_##object = object
#define GRMSTRONGSELF(object) __typeof__(object) object = weak##_##object


#define BTSleepTime         0.1  // 线程阻塞查询的周期

#define BTDefaultTimeout    2   // 蓝牙默认超时 2 秒
#define BTDefaultRepeats    3   // 蓝牙指令默认超时重复次数


static NSString *TaskSendDataHexStringKey       = @"TaskSendDataHexString";
static NSString *TaskRecvDataHexStringKey       = @"TaskRecvDataHexString";
static NSString *TaskRecvRegularExpressionKey   = @"TaskRecvRegularExpression";
static NSString *TaskDescriptionKey             = @"TaskDescription";
static NSString *TaskResultBlockKey             = @"TaskResultBlock";

static NSString *TaskRecvGroupFlagKey           = @"TaskRecvGroupFlag";
static NSString *TaskRecvGroupHexStringKey      = @"TaskRecvGroupHexString";

@interface GRMBluetoothManager ()<CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic, copy) DiscoverDevicesBlock discoverDeviceBlock;  // 发现设备
@property (nonatomic, copy) ConnecteDevicesBlock connecteDeviceBlock;  // 连接设备

@end

@implementation GRMBluetoothManager {
    CBCentralManager *_cbCentralManager;
    
    NSString *_deviceNameRegularExpression;     // 设备的名称正则
    
    GRMDevice *_tempDevice;    // 指定搜索的设备
    NSMutableArray<GRMDevice *> *_matchDeviceArray;   // 匹配上的设备
    
    
    BOOL _keepScaning;  // 保持搜索状态
    
    
    NSMutableDictionary *_taskQueue;
    
    
    NSString *_tmpRecvInsHexString; // 暂存未注册的返回指令
}

static GRMBluetoothManager *sharedGRMBluetoothManager = nil;

+ (GRMBluetoothManager *)sharedGRMBluetoothManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        sharedGRMBluetoothManager = [[self alloc] init];
    });
    return sharedGRMBluetoothManager;
}
+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedGRMBluetoothManager == nil)
        {
            sharedGRMBluetoothManager = [super allocWithZone:zone];
            return sharedGRMBluetoothManager;
        }
    }
    return nil;
}
- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],CBCentralManagerOptionShowPowerAlertKey, nil];
        _cbCentralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:options];
        
    }
    return self;
}

#pragma mark - 搜索
/** 搜索指定设备
 *  搜索到第一台，1秒后回调结果
 */
- (void)scanDevice:(NSString *)name timeout:(NSTimeInterval)timeout result:(DiscoverDevicesBlock)block {
    
    if (name.length) {
        _tempDevice = [[GRMDevice alloc] initWithName:name];
        _deviceNameRegularExpression = [NSString stringWithFormat:@"^%@$", name];
    }
    
    _keepScaning = NO;

    [self scanWithTimeout:timeout result:block];
    
}
/** 搜索一类名称规则的设备
 *  搜索到第一台，1秒后回调结果
 */
- (void)scanDevices:(NSString *)regularExpression timeout:(NSTimeInterval)timeout result:(DiscoverDevicesBlock)block {
    
    if (regularExpression.length) {
        _tempDevice = nil;
        _deviceNameRegularExpression = regularExpression;
    }
    
    _keepScaning = NO;

    [self scanWithTimeout:timeout result:block];
    
}

/** 保持搜索，搜索一类名称规则的设备
 *  每搜索到一台设备，回调一次block
 */
- (void)scanDevices:(NSString *)regularExpression result:(DiscoverDevicesBlock)block {
    if (regularExpression.length) {
        _tempDevice = nil;
        _deviceNameRegularExpression = regularExpression;
    }
    
    _keepScaning = YES;

    [self scanWithTimeout:-1 result:block];
}

/** 保持搜索
 *  每搜索到一台设备，回调一次block
 */
- (void)scaningResult:(DiscoverDevicesBlock)block {
    
    _keepScaning = YES;
    
    [self scanWithTimeout:-1 result:block];
}
/** 搜索
 *  搜索到第一台，1秒后回调结果
 */
- (void)scanWithTimeout:(NSTimeInterval)timeout result:(DiscoverDevicesBlock)block {
    
    _cancelScan = NO;
    
    _matchDeviceArray = [NSMutableArray array];
    
    _discoverDeviceBlock = block;
    
    [self startScan];
    
    if (timeout < 0) {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSDate *scanDuration = [NSDate dateWithTimeIntervalSinceNow:timeout];
        while ([scanDuration timeIntervalSinceNow] > 0) {
            
            [NSThread sleepForTimeInterval:BTSleepTime];
            
            if (self->_cancelScan) break;
        }
        
        
        if ([scanDuration timeIntervalSinceNow] <= 0 && !self->_cancelScan) {
            
            self->_cancelScan = YES;
            
            [self stopScan];
            dispatch_async(dispatch_get_main_queue(), ^{
                block(self->_matchDeviceArray, TIME_OUT_ERROR, @"超时，未找到指定设备");
            });
            
        }
        
    });
    
}

/** 搜索 */
- (void)startScan {
//    [_cbCentralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:SERVICE_UUID_HF_DATA_TRANSMISSION]] options:nil];
    [_cbCentralManager scanForPeripheralsWithServices:nil options:nil];
}

/** 停止搜索 */
- (void)stopScan {
    [_cbCentralManager stopScan];
}


#pragma mark - 连接
/** 连接指定名称的设备 */
- (void)connectWithName:(NSString *)name timeout:(NSTimeInterval)timeout result:(ConnecteDevicesBlock)block {
    
    [self scanDevice:name timeout:timeout result:^(NSArray<GRMDevice *> * _Nonnull devices, OPERATION_ERROR code, NSString * _Nonnull msg) {
        if (code == OPERATION_SUCCEEDED) {
            
            GRMDevice *device = nil;
            if (name.length) {
                device = [GRMDevice match:name formArray:devices];
            }
            else {
                device = devices.count ? [devices objectAtIndex:0] : nil;
            }
            
            [self connectWithDevice:device result:block];
        }
        else {
            block(@[], code , msg);
        }
    }];
    
}
/** 连接已发现的设备 */
- (void)connectWithDevice:(GRMDevice *)device result:(ConnecteDevicesBlock)block {
    
    self.connecteDeviceBlock = block;
    
    [self connectWithDevice:device];
}

/** 连接设备 */
- (void)connectWithDevice:(GRMDevice *)device {
    
    if (_isConnected) {
//        [self disconnect];
    }
    
    _cancelScan = NO;
    
    if (device.peripheral) {
        
        [_cbCentralManager connectPeripheral:device.peripheral options:nil];
    }
    
}

#pragma mark - 发指令
/**
 *  3.发送数据，并接收返回
 */
- (void)sendDataWithHexString:(NSString *)hexString recvRegularExpression:(NSString *)regularExpression result:(ResutlBlock)block {
    [self sendDataWithHexString:hexString recvRegularExpression:regularExpression description:@"" result:block];
}
- (void)sendDataWithHexString:(NSString *)hexString isRecvGroup:(BOOL)isRecvGroup recvRegularExpression:(NSString *)regularExpression result:(ResutlBlock)block {
    [self sendDataWithHexString:hexString isRecvGroup:isRecvGroup recvRegularExpression:regularExpression description:@"" result:block];
}

/**
 *  2.发送数据，并接收返回
 */
- (void)sendDataWithHexString:(NSString *)hexString recvRegularExpression:(NSString *)regularExpression description:(NSString *)description result:(ResutlBlock)block {
    NSString *des = @"";
    if (description.length) {
        des = description;
    }
    [self sendDataWithHexString:hexString recvRegularExpression:regularExpression registerID:regularExpression description:des withSingleTimeout:BTDefaultTimeout timeoutRepeatsCount:BTDefaultRepeats result:block];
}
- (void)sendDataWithHexString:(NSString *)hexString isRecvGroup:(BOOL)isRecvGroup recvRegularExpression:(NSString *)regularExpression description:(NSString *)description result:(ResutlBlock)block {
    NSString *des = @"";
    if (description.length) {
        des = description;
    }
    [self sendDataWithHexString:hexString isRecvGroup:isRecvGroup recvRegularExpression:regularExpression registerID:regularExpression description:des withSingleTimeout:BTDefaultTimeout timeoutRepeatsCount:1 result:block];
}

/**
 *  1.发送数据，并接收返回
 */
- (void)sendDataWithHexString:(NSString *)hexString
        recvRegularExpression:(NSString *)regularExpression
                   registerID:(NSString *)registerID
                  description:(NSString *)description
            withSingleTimeout:(NSTimeInterval)timeout
          timeoutRepeatsCount:(NSUInteger)repeatsCount result:(ResutlBlock)block {
    
    [self sendDataWithHexString:hexString isRecvGroup:NO
          recvRegularExpression:regularExpression
                     registerID:registerID
                    description:description
              withSingleTimeout:timeout
            timeoutRepeatsCount:repeatsCount result:block];
}
- (void)sendDataWithHexString:(NSString *)hexString isRecvGroup:(BOOL)isRecvGroup
        recvRegularExpression:(NSString *)regularExpression
                   registerID:(NSString *)registerID
                  description:(NSString *)description
            withSingleTimeout:(NSTimeInterval)timeout
          timeoutRepeatsCount:(NSUInteger)repeatsCount result:(ResutlBlock)block {
    if (!self.isConnected) {
        block(registerID, DISCONNECT_ERROR, @"设备未连接", nil, nil, nil);
        return;
    }
    
    _cancel = NO;
    
    if (!_taskQueue) {
        @synchronized (_taskQueue) {
            _taskQueue = [NSMutableDictionary dictionary];
        }
    }
    
    if (!hexString || !hexString.length) {
        NSLog(@"没有要发送的指令, recvRES = %@", regularExpression);
        return ;
    }
    
    if (!regularExpression || !regularExpression.length) {
        NSLog(@"接收正则为空, 将不考虑应答直接下发指令, sendIns = %@", hexString);
        [self.device writeDataWithString:hexString];
        
        return ;
    }
    
    GRMWEAKSELF(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        GRMSTRONGSELF(self);
        
        BOOL isSuccess = NO;
        
        NSUInteger repeatsCount_temp = repeatsCount; // 超时重复次数
        while (repeatsCount_temp && !self->_cancel) {
            
            NSInteger timeout_temp = timeout ?: BTDefaultTimeout;
            
            [self addTaskWithHexString:hexString isRecvGroup:isRecvGroup recvRegularExpression:regularExpression registerID:registerID description:description];
            [self.device writeDataWithString:hexString];
            
            NSLog(@"send(%lu): %@", repeatsCount - repeatsCount_temp, hexString);
            
            // 阻塞等待
            NSDate *date = [NSDate dateWithTimeIntervalSinceNow:timeout_temp];
            while ([date timeIntervalSinceNow] > 0 && !self->_cancel) {
                
                NSString *recvDataSring = [self getRecvDataWithRegisterID:registerID];
                if (recvDataSring.length) {
                    
                    isSuccess = YES;
                    break;
                    
                } else {
                    
                    [NSThread sleepForTimeInterval:BTSleepTime];
                }
                
            }
            
            // 成功或超时
            if (isSuccess) {
                
                break;
                
            } else {
                self->_tmpRecvInsHexString = nil;
                repeatsCount_temp --;
            }
            
        }
        
        
        // 成功或失败
        if (isSuccess) {
            
            if (block && !self->_cancel) {
                
                NSString *recvDataSring = [self getRecvDataWithRegisterID:registerID];
                NSString *regularExpressionString = regularExpression;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    block(registerID, OPERATION_SUCCEEDED, @"应答成功", recvDataSring, regularExpressionString, hexString);
                    
                    [self removeTaskWithRegisterID:registerID];
                });
                
            }
            
        } else {
            self->_tmpRecvInsHexString = nil;
            
            if (block && !self->_cancel) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    block(registerID, TIME_OUT_ERROR, @"应答超时", nil, regularExpression, hexString);
                    
                    [self removeTaskWithRegisterID:registerID];
                });
                
            }
            
        }
        
    });
}

/**
 *  3.不回调主线程，发送数据，并接收返回
 */
- (void)nm_sendDataWithHexString:(NSString *)hexString recvRegularExpression:(NSString *)regularExpression result:(ResutlBlock)block {
    [self nm_sendDataWithHexString:hexString recvRegularExpression:regularExpression description:@"" result:block];
}

/**
 *  2.不回调主线程，发送数据，并接收返回
 */
- (void)nm_sendDataWithHexString:(NSString *)hexString recvRegularExpression:(NSString *)regularExpression description:(NSString *)description result:(ResutlBlock)block {
    NSString *des = @"";
    if (description.length) {
        des = description;
    }
    [self nm_sendDataWithHexString:hexString recvRegularExpression:regularExpression registerID:regularExpression description:des withSingleTimeout:BTDefaultTimeout timeoutRepeatsCount:1 result:block];
}

/**
 *  1.不回调主线程，发送数据，并接收返回
 */
- (void)nm_sendDataWithHexString:(NSString *)hexString
        recvRegularExpression:(NSString *)regularExpression
                   registerID:(NSString *)registerID
                  description:(NSString *)description
            withSingleTimeout:(NSTimeInterval)timeout
             timeoutRepeatsCount:(NSUInteger)repeatsCount result:(ResutlBlock)block{
    if (!self.isConnected) {
        block(registerID, DISCONNECT_ERROR, @"设备未连接", nil, nil, nil);
        return;
    }
    
    _cancel = NO;
    
    if (!_taskQueue) {
        @synchronized (_taskQueue) {
            _taskQueue = [NSMutableDictionary dictionary];
        }
    }
    
    if (!hexString || !hexString.length) {
        NSLog(@"没有要发送的指令, recvRES = %@", regularExpression);
        return ;
    }
    
    if (!regularExpression || !regularExpression.length) {
        NSLog(@"接收正则为空, 将不考虑应答直接下发指令, sendIns = %@", hexString);
        [self.device writeDataWithString:hexString];
        
        return ;
    }
    
    GRMWEAKSELF(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        GRMSTRONGSELF(self);
        
        BOOL isSuccess = NO;
        
        NSUInteger repeatsCount_temp = repeatsCount; // 超时重复次数
        while (repeatsCount_temp && !self->_cancel) {
            
            NSInteger timeout_temp = timeout ?: BTDefaultTimeout;
            
            [self addTaskWithHexString:hexString recvRegularExpression:regularExpression registerID:registerID description:description];
            [self.device writeDataWithString:hexString];
            
            NSLog(@"send(%lu): %@", repeatsCount - repeatsCount_temp, hexString);
            
            // 阻塞等待
            NSDate *date = [NSDate dateWithTimeIntervalSinceNow:timeout_temp];
            while ([date timeIntervalSinceNow] > 0 && !self->_cancel) {
                
                NSString *recvDataSring = [self getRecvDataWithRegisterID:registerID];
                if (recvDataSring.length) {
                    
                    isSuccess = YES;
                    break;
                    
                } else {
                    
//                    [NSThread sleepForTimeInterval:BTSleepTime];
                }
                
            }
            
            // 成功或超时
            if (isSuccess) {
                
                break;
                
            } else {
                
                repeatsCount_temp --;
            }
            
        }
        
        
        // 成功或失败
        if (isSuccess) {
            
            if (block && !self->_cancel) {
                
                NSString *recvDataSring = [self getRecvDataWithRegisterID:registerID];
                NSString *regularExpressionString = regularExpression;
                
                
                block(registerID, OPERATION_SUCCEEDED, @"应答成功", recvDataSring, regularExpressionString, hexString);
                
            }
            
        } else {
            
            if (block && !self->_cancel) {
                
                block(registerID, OPERATION_SUCCEEDED, @"应答超时", nil, regularExpression, hexString);
                
            }
            
        }
        
    });
}


#pragma mark - private
/**  初始化任务队列  */
- (void)clearTaskQueue {
    
    if (!_taskQueue) {
        @synchronized (_taskQueue) {
            _taskQueue = [NSMutableDictionary dictionary];
        }
    } else {
        @synchronized (_taskQueue) {
            [_taskQueue removeAllObjects];
        }
    }
    
}
- (void)replyTaskWithRegisterID:(NSString *)registerID andRecvDataHexString:(NSString *)recvDataHexString {
    NSMutableDictionary *task = [_taskQueue objectForKey:registerID];
    if (task) {
        NSNumber *isRecvGroup = [task objectForKey:TaskRecvGroupFlagKey];
        if ([isRecvGroup boolValue]) {
            NSString *tempRecvGroup = [task objectForKey:TaskRecvGroupHexStringKey];
            
            NSMutableString *mTempRecvGroup;
            if (tempRecvGroup.length) {
                mTempRecvGroup = [NSMutableString stringWithString:tempRecvGroup];
            } else {
                mTempRecvGroup = [NSMutableString string];
            }
            
            if (mTempRecvGroup.length) {
                [mTempRecvGroup appendString:@"|"];
            }
            [mTempRecvGroup appendString:recvDataHexString];
            
            NSString *isContinue = [recvDataHexString substringWithRange:NSMakeRange(recvDataHexString.length-4, 2)];
            if ([isContinue isEqualToString:@"01"]) {
                [task setObject:mTempRecvGroup forKey:TaskRecvGroupHexStringKey];
            } else {
                [task setObject:mTempRecvGroup forKey:TaskRecvDataHexStringKey];
            }
            
        } else {
            [task setObject:recvDataHexString forKey:TaskRecvDataHexStringKey];
        }
        
        @synchronized (_taskQueue) {
            [_taskQueue setObject:task forKey:registerID];
        }
    }
}
- (void)addTaskWithHexString:(NSString * __nonnull)hexString recvRegularExpression:(NSString * __nonnull)regularExpression registerID:(NSString *)registerID description:(NSString *)description {
    [self addTaskWithHexString:hexString isRecvGroup:NO recvRegularExpression:regularExpression registerID:registerID description:description];
}
- (void)addTaskWithHexString:(NSString * __nonnull)hexString isRecvGroup:(BOOL)isRecvGroup recvRegularExpression:(NSString * __nonnull)regularExpression registerID:(NSString *)registerID description:(NSString *)description {
    NSMutableDictionary *task = [_taskQueue objectForKey:registerID];
    
    if (!task) {
        task = [NSMutableDictionary dictionary];
    } else {
        [task removeAllObjects];
    }
    
    [task setObject:hexString           forKey:TaskSendDataHexStringKey];
    [task setObject:regularExpression   forKey:TaskRecvRegularExpressionKey];
    [task setObject:description         forKey:TaskDescriptionKey];
    
    [task setObject:[NSNumber numberWithBool:isRecvGroup] forKey:TaskRecvGroupFlagKey];
    
    @synchronized (_taskQueue) {
        [_taskQueue setObject:task forKey:registerID];
    }
}
- (NSString *)getRecvDataWithRegisterID:(NSString *)registerID {
    NSMutableDictionary *task = [_taskQueue objectForKey:registerID];
    return [task objectForKey:TaskRecvDataHexStringKey];
}
- (void)removeTaskWithRegisterID:(NSString *)registerID {
    @synchronized (_taskQueue) {
        [_taskQueue removeObjectForKey:registerID];
    }
}

#pragma mark - 断开连接
/** 断开连接 */
- (void)disconnect {
    
    if (_device.peripheral && _isConnected) {
        
        [_cbCentralManager cancelPeripheralConnection:_device.peripheral];
        
    }
}

#pragma mark - CBCentralManagerDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationBlueToothStateChange object:@(central.state)];
    
    switch (central.state) {
            
        case CBManagerStatePoweredOn:
            _isOpen = YES;
            
            if (!_cancelScan) {
                [self startScan];
            }
            break;
            
        case CBManagerStatePoweredOff:
            _isOpen = NO;
            _isConnected = NO;
            [self clearTaskQueue];
            break;
            
        case CBManagerStateUnauthorized:
            _isOpen = NO;
            _isConnected = NO;
            [self clearTaskQueue];
            break;
            
        default:
            _isOpen = NO;
            [self clearTaskQueue];
            break;
    }
    
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    
    NSString *BTName = [advertisementData objectForKey:@"kCBAdvDataLocalName"];
    if (_deviceNameRegularExpression.length) {
        NSPredicate *numberPre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", _deviceNameRegularExpression];
        if (![numberPre evaluateWithObject:BTName]) {
            return;
        }
    }
    
//    kCBAdvDataManufacturerData
//    UUID identifier
    
    NSArray *serviceUUIDs = [advertisementData objectForKey:@"kCBAdvDataServiceUUIDs"];
    BOOL isExist = NO;
    for (CBUUID *uuid in serviceUUIDs) {
        if ([uuid isEqual:[CBUUID UUIDWithString:@"FA00"]]) {
            isExist = YES;
            break;
        }
    }
    if (!isExist) {
        
        return;
    }
    
    // 用户取消
    if (_cancelScan) {
        return;
    }
    
    /** 发现一个设备  **/
    GRMDevice *device = [[GRMDevice alloc] initWithPerpheral:peripheral];
    device.RSSI = [RSSI integerValue];

    if (![device matchFromArray:_matchDeviceArray]) {
        
        NSInteger index = [device indexFromArray:_matchDeviceArray];
        [_matchDeviceArray insertObject:device atIndex:index];
    }
    
    
    if (_tempDevice) {
        // 有指定搜索的设备
        if ([device.name isEqualToString:_tempDevice.name]) {
            
            _tempDevice = nil;
            
            _cancelScan = YES;
            
            [self stopScan];  // 结束搜索
            if (self.discoverDeviceBlock) {
                self.discoverDeviceBlock(_matchDeviceArray, OPERATION_SUCCEEDED, @"找到指定设备");
            }
            
        }
    }
    else {
        
        if (_keepScaning) {
            // 保持搜索，每发现一台设备回调一次block
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.discoverDeviceBlock(self->_matchDeviceArray, OPERATION_SUCCEEDED, @"发现一台设备");
            });
        }
        else {
            // 不需要保持搜索，在发现设备后。停止搜索
            _cancelScan = YES;
            
            if (self.discoverDeviceBlock) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self stopScan];  // 结束搜索
                    self.discoverDeviceBlock(self->_matchDeviceArray, OPERATION_SUCCEEDED, @"发现第一台设备1秒后回调");
                });
            } else {
                [self stopScan];  // 结束搜索
            }
        }
        
    }
    
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    
    [self stopScan];
    
    [self clearTaskQueue];
    
    _device = [[GRMDevice alloc] initWithPerpheral:peripheral];
    _tempDevice = nil;
    
    if (!_cancelScan) {
        [peripheral setDelegate:self];
        [peripheral discoverServices:nil];
    }
    
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error {
    
    NSLog(@"[BlueTooth]连接失败 == %@ == %@", peripheral.name, error);
    if (self.connecteDeviceBlock) {
        self.connecteDeviceBlock(@[], CONNECT_ERROR, @"连接失败");
        self.connecteDeviceBlock = nil;
    }
    
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error {
    
    NSLog(@"[BlueTooth]断开连接 == %@ == %@", peripheral.name, error);
    
    _isConnected = NO;
    _device = nil;
    
    if (!_cancelScan) {
        
        _cancelScan = YES;

        [[NSNotificationCenter defaultCenter] postNotificationName:NotificationBlueToothDisconnect object:nil];
        
    }
    
}


#pragma mark - CBPeripheralDelegate
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    
    if (error) return;
    
    for (CBService* service in peripheral.services) {
        
        [peripheral discoverCharacteristics:nil forService:service];
    }
    
}
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    
    if (error) return;
    
    if ([service.UUID isEqual:[CBUUID UUIDWithString:@"FA00"]]) {
        NSLog(@"[BlueTooth]发现%@", @"FA00");
        for (CBCharacteristic *characteristic in service.characteristics) {
            
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            
            if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FA01"]]) {
                _device.characteristicFA01 = characteristic;
            }
            if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FA02"]]) {
                _device.characteristicFA02 = characteristic;
            }
        }
    }
    
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error {
    
    if (error) return;
    
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FA01"]] && characteristic.isNotifying) {
        if (_device.characteristicFA01 &&
            _device.characteristicFA02 && !_cancelScan) {
                
//            [_device.peripheral setNotifyValue:YES forCharacteristic:_device.characteristicFA01];
//            [_device.peripheral setNotifyValue:YES forCharacteristic:_device.characteristicFA02];
            
            _isConnected = YES;
            _device.isConnected = YES;
            if (self.connecteDeviceBlock) {
                self.connecteDeviceBlock(@[_device], OPERATION_SUCCEEDED, @"连接成功");
                self.connecteDeviceBlock = nil;
            }
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
//    NSLog(@"~~~~~%@", characteristic.UUID);
    
    if (error) return;
    
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FA01"]]) {
    
        NSString *recvInsHexString = [InsConvertTools hexStringFromData:characteristic.value];
        if ([recvInsHexString containsString:@"0D0A"]) {
            NSData *tempData = [InsConvertTools delelteExtra00:characteristic.value];
            recvInsHexString = [InsConvertTools hexStringFromData:tempData];
        }
        
        if (_tmpRecvInsHexString.length) {
            recvInsHexString = [NSString stringWithFormat:@"%@%@", _tmpRecvInsHexString, recvInsHexString];
        }
        
        BOOL isRegister = NO;   // 是否是注册的指令
        NSArray *taskKeys = [_taskQueue allKeys];
        for (NSString *registerID in taskKeys) {
            NSMutableDictionary *task = [_taskQueue objectForKey:registerID];
            
            NSString *regularExpressionString = [task objectForKey:TaskRecvRegularExpressionKey];
            NSPredicate *numberPre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regularExpressionString];
            
            if ([numberPre evaluateWithObject:recvInsHexString]) {
                isRegister = YES;
                
                NSLog(@"match recv : %@", recvInsHexString);
                
                _tmpRecvInsHexString = nil;
                [self replyTaskWithRegisterID:registerID andRecvDataHexString:recvInsHexString];
                break;
            }
        }
        
        
        if (!isRegister) {
            _tmpRecvInsHexString = recvInsHexString;
            if (_tmpRecvInsHexString.length > 80) {
                _tmpRecvInsHexString = nil;
            }
            
            // 未注册的指令，可能是设备主动返回
            [[NSNotificationCenter defaultCenter] postNotificationName:NotificationBlueToothUnkowRecv object:recvInsHexString];
        }
    }
}

@end
