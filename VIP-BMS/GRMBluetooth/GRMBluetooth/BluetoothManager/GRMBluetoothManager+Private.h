//
//  GRMBluetoothManager+Private.h
//  GRMBluetooth
//
//  Created by _G.R.M. on 2019/12/20.
//  Copyright © 2019 goorume. All rights reserved.
//

#import "GRMBluetoothManager.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^ResutlBlock)(NSString *registerID, OPERATION_ERROR code, NSString *msg, NSString * __nullable recvDataString, NSString * __nullable recvRegularExpression, NSString * __nullable sendHexString); // 发指令结果回调


@interface GRMBluetoothManager ()

/**
 *  3.发送数据，并接收返回
 */
- (void)sendDataWithHexString:(NSString *)hexString recvRegularExpression:(NSString *)regularExpression result:(ResutlBlock)block;
- (void)sendDataWithHexString:(NSString *)hexString isRecvGroup:(BOOL)isRecvGroup recvRegularExpression:(NSString *)regularExpression result:(ResutlBlock)block;

/**
 *  2.发送数据，并接收返回
 */
- (void)sendDataWithHexString:(NSString *)hexString recvRegularExpression:(NSString *)regularExpression description:(NSString *)description result:(ResutlBlock)block;
- (void)sendDataWithHexString:(NSString *)hexString isRecvGroup:(BOOL)isRecvGroup recvRegularExpression:(NSString *)regularExpression description:(NSString *)description result:(ResutlBlock)block;

/**
 *  1.发送数据，并接收返回
 */
- (void)sendDataWithHexString:(NSString *)hexString
        recvRegularExpression:(NSString *)regularExpression
                   registerID:(NSString *)registerID
                  description:(NSString *)description
            withSingleTimeout:(NSTimeInterval)timeout
          timeoutRepeatsCount:(NSUInteger)repeatsCount result:(ResutlBlock)block;

- (void)sendDataWithHexString:(NSString *)hexString
                  isRecvGroup:(BOOL)isRecvGroup
        recvRegularExpression:(NSString *)regularExpression
                   registerID:(NSString *)registerID
                  description:(NSString *)description
            withSingleTimeout:(NSTimeInterval)timeout
          timeoutRepeatsCount:(NSUInteger)repeatsCount result:(ResutlBlock)block;


/**
 *  3.不回调主线程，发送数据，并接收返回
 */
- (void)nm_sendDataWithHexString:(NSString *)hexString recvRegularExpression:(NSString *)regularExpression result:(ResutlBlock)block;

/**
 *  2.不回调主线程，发送数据，并接收返回
 */
- (void)nm_sendDataWithHexString:(NSString *)hexString recvRegularExpression:(NSString *)regularExpression description:(NSString *)description result:(ResutlBlock)block;

/**
 *  1.不回调主线程，发送数据，并接收返回
 */
- (void)nm_sendDataWithHexString:(NSString *)hexString
        recvRegularExpression:(NSString *)regularExpression
                   registerID:(NSString *)registerID
                  description:(NSString *)description
            withSingleTimeout:(NSTimeInterval)timeout
          timeoutRepeatsCount:(NSUInteger)repeatsCount result:(ResutlBlock)block;

@end

NS_ASSUME_NONNULL_END
