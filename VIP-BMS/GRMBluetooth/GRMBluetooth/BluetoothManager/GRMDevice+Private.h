//
//  GRMDevice+Private.h
//  TheKoran
//
//  Created by _G.R.M. on 2019/12/19.
//  Copyright © 2019 goorume. All rights reserved.
//

#import "GRMDevice.h"

NS_ASSUME_NONNULL_BEGIN

@interface GRMDevice ()

@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, strong) CBCharacteristic *characteristicFA01; //
@property (nonatomic, strong) CBCharacteristic *characteristicFA02; //



- (instancetype)initWithName:(NSString *)name;
- (instancetype)initWithPerpheral:(CBPeripheral *)peripheral;



/** 是否已经存在数组中 */
- (GRMDevice *)matchFromArray:(NSArray<GRMDevice *> *)devicesArray;
+ (GRMDevice *)match:(NSString *)name formArray:(NSArray<GRMDevice *> *)devicesArray;

/** 按设备的距离小到大排序数组，返回应插入的index -73近于-74 */
- (NSInteger)indexFromArray:(NSArray<GRMDevice *> *)deviceArray;


- (void)writeDataWithString:(NSString *)insString;
- (void)writeData:(NSData *)insData;


@end

NS_ASSUME_NONNULL_END
