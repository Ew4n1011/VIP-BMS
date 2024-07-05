//
//  InsConvertTools.m
//  TheKoran
//
//  Created by _G.R.M. on 2019/12/17.
//  Copyright © 2019 goorume. All rights reserved.
//

#import "InsConvertTools.h"

@implementation InsConvertTools

#pragma mark - 公共函数
/////////////////////////////////////////////////////////////////////////////
//                            公共

/**  反序HexString  */
+ (NSString *)reversalHexString:(NSString *)hexString {
    NSMutableString *tmpString = [NSMutableString string];
    NSInteger count = hexString.length/2;
    for (NSInteger i = count-1; i >= 0; i--) {
        NSString *s = [hexString substringWithRange:NSMakeRange(i*2, 2)];
        [tmpString appendString:s];
    }
    return tmpString;
}

/**  转换 "低字节在前，高字节在后" 的 hexString -> int，最高位 1 代表负数  */
+ (NSInteger)intFrom_Low2Height_HexString:(NSString *)hexString {
    NSString *tmpString = [InsConvertTools reversalHexString:hexString];
    NSInteger num = strtol([tmpString UTF8String], 0, 16);
    
    BOOL falg = (num & (1<<(7*tmpString.length/2))) > 0; // > 0 为负数
    if (falg) {
        NSData *data = [InsConvertTools dataFromHexString:tmpString];
        NSMutableData *mData = [NSMutableData data];
        for (int i = 0; i < data.length; i++) {
            __signed char oc = 0x00;
            [data getBytes:&oc range:NSMakeRange(i, 1)];
            __signed char cc = ~oc;
            [mData appendBytes:&cc length:1];
        }
        NSString *cString = [InsConvertTools hexStringFromData:mData];
        num = -(strtol([cString UTF8String], 0, 16) + 1);
    }
    return num;
}

+ (NSInteger)zintFrom_Low2Height_HexString:(NSString *)hexString {
    NSString *tmpString = [InsConvertTools reversalHexString:hexString];
    return strtol([tmpString UTF8String], 0, 16);
}

/**  转换 int -> "低字节在前，高字节在后" 的 hexString，最高位 1 代表负数  */
+ (NSString *)low2Height_HexStringFromValue:(NSInteger)value {
    NSString *hexString = [NSString stringWithFormat:@"%X", value];
    if (value == -1) {
        hexString = @"FF";
    } else {
        hexString = [hexString stringByReplacingOccurrencesOfString:@"FF" withString:@""];
    }
    if (hexString.length%2 == 1) {
        hexString = [NSString stringWithFormat:@"0%@", hexString];
    }
    NSString *tmpString = [InsConvertTools reversalHexString:hexString];
    return tmpString;
}

/**  转换 string -> hexString  如: "345" -> "333435"  */
+ (NSString *)hexStringFromString:(NSString *)string {
    NSData *myD = [string dataUsingEncoding:NSUTF8StringEncoding];
    Byte *bytes = (Byte *)[myD bytes];
    
    NSString *hexStr=@"";
    for(int i = 0; i < [myD length]; i++)
    {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];///16进制数
        
        if([newHexStr length]==1)
            
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        
        else
            
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
    }
    return [hexStr uppercaseString];
}

/**  转换 hexString -> string  如: "333435" -> "345"  */
+ (NSString *)stringFromHexString:(NSString *)hexString {
    
    char *myBuffer = (char *)malloc((int)[hexString length] / 2 + 1);
    bzero(myBuffer, [hexString length] / 2 + 1);
    for (int i = 0; i < [hexString length] - 1; i += 2) {
        unsigned int anInt;
        NSString * hexCharStr = [hexString substringWithRange:NSMakeRange(i, 2)];
        NSScanner * scanner = [[NSScanner alloc] initWithString:hexCharStr];
        [scanner scanHexInt:&anInt];
        myBuffer[i / 2] = (char)anInt;
    }
    NSString *unicodeString = [NSString stringWithCString:myBuffer encoding:4];

    return [unicodeString uppercaseString];
}

/**  转换 hexString -> NSData  如: "333435" -> <333435>"  */
+ (NSData *)dataFromHexString:(NSString *)hexString {
    
    if (hexString.length%2 == 1) {
        NSAssert(hexString.length%2 == 0, @"hexString 长度为单数");
        NSLog(@"hexString 长度为单数, 最后一个字符将被忽略:\n%@", hexString);
    }
    
    NSMutableData *dataM = [NSMutableData data];
    NSInteger count = hexString.length/2;
    for (int i = 0; i < count; i++) {
        
        unsigned int anInt;
        NSString * hexCharStr = [hexString substringWithRange:NSMakeRange(2*i, 2)];
        NSScanner * scanner = [[NSScanner alloc] initWithString:hexCharStr];
        [scanner scanHexInt:&anInt];
        
        NSData *data = [NSData dataWithBytes:&anInt length:1];
        [dataM appendData:data];
    }
    
    return dataM;
}

/**  转换 NSData -> hexString  如: <333435> -> "333435"  */
+ (NSString *)hexStringFromData:(NSData *)data {
    
    if (!data || [data length] == 0) {
        return nil;
    }
    NSMutableString *string = [[NSMutableString alloc] initWithCapacity:[data length]];
    
    [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
        unsigned char *dataBytes = (unsigned char*)bytes;
        for (NSInteger i = 0; i < byteRange.length; i++) {
            NSString *hexStr = [NSString stringWithFormat:@"%x", (dataBytes[i]) & 0xff];
            if ([hexStr length] == 2) {
                [string appendString:hexStr];
            } else {
                [string appendFormat:@"0%@", hexStr];
            }
        }
    }];
    
    return [string uppercaseString];
}

/**  给字符串追加"0",最大长度为 maxLenght  */
+ (NSString *)appendZeroFromString:(NSString *)string andMaxLenght:(NSInteger)maxLenght {

    NSString *temp_String = [NSString stringWithString:string];
    if (temp_String.length >= maxLenght) {
        NSLog(@"\n字符串被截断:\n%@\n%@\n", string, [temp_String substringWithRange:NSMakeRange(0, maxLenght)]);
        return [temp_String substringWithRange:NSMakeRange(0, maxLenght)];
    }
    
    NSMutableString *appendString = [NSMutableString stringWithString:@""];
    NSInteger appendCount = maxLenght - temp_String.length;
    if (appendCount > 0) {
        for (int i = 0; i < appendCount; i++) {
            [appendString appendString:@"0"];
        }
        
    }
    
    NSString *newString = [NSString stringWithFormat:@"%@%@", temp_String, appendString];
    
    return newString;
}

/**  按正则表达式匹配子字符串  */
+ (NSRange)matchSubstringWithRegular:(NSString *)regularExpressionString inString:(NSString *)string {
    
    NSRange range = NSMakeRange(0, 0);
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regularExpressionString options:NSRegularExpressionCaseInsensitive error:NULL];
    NSTextCheckingResult *result = [regex firstMatchInString:string options:0 range:NSMakeRange(0, [string length])];
    
    if (result)  range = result.range;
    
    return range;
}



#pragma mark - 蓝牙相关
/////////////////////////////////////////////////////////////////////////////
//                            蓝牙

/**  截取数据中多余的 "0x00"  */
+ (NSData *)delelteExtra00:(NSData *)oldData {
    NSData *temp_Data = [NSMutableData dataWithData:oldData];
    
    BOOL preFlag = NO;
    BOOL subFlag = YES;
    NSInteger preLoc = 0;
    NSInteger subLoc = oldData.length - 1;
    
    NSData *compareData = [InsConvertTools dataFromHexString:@"00"];
    NSInteger count = oldData.length;
    for (int i = 0; i < count; i++) {
        
        if (preFlag) {
            NSData *subData = [temp_Data subdataWithRange:NSMakeRange(i, 1)];
            if ([subData isEqualToData:compareData]) {
                
                preLoc = i + 1;
            } else {
                preFlag = NO;
                preLoc = i;
            }
        }
        if (subFlag) {
            NSInteger loc = (oldData.length - 1) - i;
            NSData *subData = [temp_Data subdataWithRange:NSMakeRange(loc, 1)];
            if ([subData isEqualToData:compareData]) {
                
                subLoc = loc;
            } else {
                subFlag = NO;
                subLoc = loc + 1;  // 若不相等,要加上这个字节,即loc移到下一个位置
            }
        }
        
        if (!preFlag && !subFlag) {
            break;
        }
    }
    
    NSMutableData *newData = [NSMutableData data];
    NSInteger resultLenght = subLoc - preLoc;
    if (resultLenght > 0) {
        
        if (resultLenght > 1) {
            
            [newData appendData:[oldData subdataWithRange:NSMakeRange(preLoc, resultLenght)]];
            
        } else if (preLoc == oldData.length/2) {
            
            NSData *data = [oldData subdataWithRange:NSMakeRange(preLoc, resultLenght)];
            if (![data isEqualToData:compareData]) {
                [newData appendData:data];
            }
        }
        
    }
    
    return newData;
}



#pragma mark - NSDate
+ (NSUInteger)day:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_8_0
    // NSDayCalendarUnit
    NSDateComponents *dayComponents = [calendar components:(NSCalendarUnitDay) fromDate:date];
#else
    NSDateComponents *dayComponents = [calendar components:(NSDayCalendarUnit) fromDate:date];
#endif
    
    return [dayComponents day];
}

+ (NSUInteger)month:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_8_0
    // NSDayCalendarUnit
    NSDateComponents *dayComponents = [calendar components:(NSCalendarUnitMonth) fromDate:date];
#else
    NSDateComponents *dayComponents = [calendar components:(NSMonthCalendarUnit) fromDate:date];
#endif
    
    return [dayComponents month];
}

+ (NSUInteger)year:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_8_0
    // NSDayCalendarUnit
    NSDateComponents *dayComponents = [calendar components:(NSCalendarUnitYear) fromDate:date];
#else
    NSDateComponents *dayComponents = [calendar components:(NSYearCalendarUnit) fromDate:date];
#endif
    
    return [dayComponents year];
}

+ (NSUInteger)hour:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_8_0
    // NSDayCalendarUnit
    NSDateComponents *dayComponents = [calendar components:(NSCalendarUnitHour) fromDate:date];
#else
    NSDateComponents *dayComponents = [calendar components:(NSHourCalendarUnit) fromDate:date];
#endif
    
    return [dayComponents hour];
}

+ (NSUInteger)minute:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_8_0
    // NSDayCalendarUnit
    NSDateComponents *dayComponents = [calendar components:(NSCalendarUnitMinute) fromDate:date];
#else
    NSDateComponents *dayComponents = [calendar components:(NSMinuteCalendarUnit) fromDate:date];
#endif
    
    return [dayComponents minute];
}

+ (NSUInteger)second:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_8_0
    // NSDayCalendarUnit
    NSDateComponents *dayComponents = [calendar components:(NSCalendarUnitSecond) fromDate:date];
#else
    NSDateComponents *dayComponents = [calendar components:(NSSecondCalendarUnit) fromDate:date];
#endif
    
    return [dayComponents second];
}
+ (NSDate *)dateWithString:(NSString *)string format:(NSString *)format {
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    [inputFormatter setDateFormat:format];
    
    NSDate *date = [inputFormatter dateFromString:string];
    
    return date;
}


@end
