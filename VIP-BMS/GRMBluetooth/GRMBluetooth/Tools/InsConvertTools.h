//
//  InsConvertTools.h
//  TheKoran
//
//  Created by _G.R.M. on 2019/12/17.
//  Copyright © 2019 goorume. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, BTInsType) {
    CONNECT_ACTION   = -1,   // 单纯的连接设备
    
    Ins_UNKOWN  = 0,    // 自定义指令                              send: @@! 自定义                                    recv: @@! 自定义
    
    Ins_WriteRecord,         // 写服务                             send: EA021C14XXXXXXXXXXXXXXXXXXXXXXXXXXXX00AE     recv: "7F1C"
    
    Ins_MaxCount        // 表示枚举个数
};

@interface InsConvertTools : NSObject

/////////////////////////////////////////////////////////////////////////////
//                            公共

/**  反序HexString  */
+ (NSString *)reversalHexString:(NSString *)hexString;
/**  转换 "低字节在前，高字节在后" 的 hexString -> int，最高位 1 代表负数  */
+ (NSInteger)intFrom_Low2Height_HexString:(NSString *)hexString;
+ (NSInteger)zintFrom_Low2Height_HexString:(NSString *)hexString;
/**  转换 int -> "低字节在前，高字节在后" 的 hexString，最高位 1 代表负数  */
+ (NSString *)low2Height_HexStringFromValue:(NSInteger)value;
/** 保留 n 位小数，四舍五入 */


/**  转换 string -> hexString  如: "345" -> "333435"  */
+ (NSString *)hexStringFromString:(NSString *)string;

/**  转换 hexString -> string  如: "333435" -> "345"  */
+ (NSString *)stringFromHexString:(NSString *)hexString __deprecated_msg("Use `dataFromHexString:`");

/**  转换 hexString -> NSData  如: "333435" -> <333435>  */
+ (NSData *)dataFromHexString:(NSString *)hexString;

/**  转换 NSData -> hexString  如: <333435> -> "333435"  */
+ (NSString *)hexStringFromData:(NSData *)data;

/**  给字符串追加"0",最大长度为 maxLenght  */
+ (NSString *)appendZeroFromString:(NSString *)string andMaxLenght:(NSInteger)maxLenght;

/**  按正则表达式匹配子字符串  */
+ (NSRange)matchSubstringWithRegular:(NSString *)regularExpressionString inString:(NSString *)string;




/////////////////////////////////////////////////////////////////////////////
//                            蓝牙

/**  截取数据中多余的 "0x00"  */
+ (NSData *)delelteExtra00:(NSData *)oldData;

/**  检查蓝牙发送的指令, 返回指令类型  */
+ (BTInsType)checkBTRecvInsWithData:(NSData *)data;
+ (BTInsType)checkBTRecvInsWithHexString:(NSString *)hexString;

/**  根据类型返回发送指令  */
+ (NSString *)getBTSendInsWithBTInsType:(BTInsType)insType;

/**  根据类型拼出应答指令正则字符串  */
+ (NSString *)getBTRecvInsRegularExpressionStringWithBTInsType:(BTInsType)insType;



#pragma mark - NSDate
+ (NSUInteger)day:(NSDate *)date;
+ (NSUInteger)month:(NSDate *)date;
+ (NSUInteger)year:(NSDate *)date;
+ (NSUInteger)hour:(NSDate *)date;
+ (NSUInteger)minute:(NSDate *)date;
+ (NSUInteger)second:(NSDate *)date;
+ (NSDate *)dateWithString:(NSString *)string format:(NSString *)format;


@end

NS_ASSUME_NONNULL_END
