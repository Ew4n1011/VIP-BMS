//
//  Utils.m
//  TheKoran
//
//  Created by goorume on 2019/12/21.
//  Copyright © 2019 goorume. All rights reserved.
//

#import "Utils.h"

@implementation Utils

/** 有效数字，包括正负，整数，小数 */
+ (BOOL)valideLFNumber:(NSString *)number {
    NSString *reString = @"[+|-]{0,1}[0-9]*\\.{0,1}[0-9]*";
    NSPredicate *numberPre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", reString];
    return [numberPre evaluateWithObject:number];
}

//familyName:'Lato'
//fontName:'Lato-Regular'
//fontName:'Lato-Bold'
+ (UIFont *)font_Lato_R:(CGFloat)size {
    return [UIFont fontWithName:@"Lato-Regular" size:size];
}

+ (UIFont *)font_Lato_B:(CGFloat)size {
    return [UIFont fontWithName:@"Lato-Bold" size:size];
}

@end
