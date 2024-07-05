//
//  UITools.h
//  TheKoran
//
//  Created by goorume on 2019/12/25.
//  Copyright © 2019 goorume. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITools : NSObject

#pragma mark - 小黑框
+ (void)showMessage:(NSString *)message;
+ (void)showMessage:(NSString *)message orientationType:(NSInteger)type;
+ (void)showError:(NSString *)error;
+ (void)showSuccess:(NSString *)success;

+ (void)startLoading;
+ (void)stopLoading;

@end

NS_ASSUME_NONNULL_END
