//
//  Utils.h
//  TheKoran
//
//  Created by goorume on 2019/12/21.
//  Copyright © 2019 goorume. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "VIP-BMS-pch.h"

NS_ASSUME_NONNULL_BEGIN

@interface Utils : NSObject

/** 有效数字，包括正负，整数，小数 */
+ (BOOL)valideLFNumber:(NSString *)number;

+ (UIFont *)font_Lato_R:(CGFloat)size;
+ (UIFont *)font_Lato_B:(CGFloat)size;

@end

NS_ASSUME_NONNULL_END
