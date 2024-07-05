//
//  GRMAlertManager.h
//  GRMToolBox
//
//  Created by G.R.M. on 2018/2/8.
//  Copyright © 2018年 _G.R.M. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, GRMAlertScreenDirection) {
    GRMAlertScreenDirectionPortrait,   // 竖屏
    GRMAlertScreenDirectionLandscapeLeft,   // 向左横屏
    GRMAlertScreenDirectionLandscapeRight,  // 向右横屏
};

typedef NS_ENUM(NSInteger, GRMAlertAnimationType) {
    GRMAlertAnimationNone,              // 无动画
    GRMAlertAnimationCenterScale,       // 中心缩放
    // 左边缘渐入
    // 上边缘渐入
    // 右边缘渐入
    // 下边缘渐入
    GRMAlertAnimationBottomSheet,       // 类似 Sheet 的上拉动画
    GRMAlertAnimationTopSheet,          // 类似 Sheet 的下拉动画
};

typedef NSArray* (^ConfigClickEvent)(UIView *alert);
typedef void (^WillDisplay)(UIView *alert);
typedef void (^DidSelectedBlock)(NSInteger index, UIView *alert);
typedef void (^grmGCDTask)(BOOL cancel);

@interface GRMAlertManager : NSObject

+ (GRMAlertManager *)sharedGRMAlertManager;

@property (nonatomic, weak) UIWindow *appWindow;



/** 是否可点击背景取消弹框  Default:YES */
@property (nonatomic, assign) BOOL backgroundEnabled;

/** 几秒后自动消失，0为不自动消失  Default:0 */
@property (nonatomic, assign) NSTimeInterval dismissAfterTime;

/** 动画类型 Default:GRMAlertAnimationCenterScale */
@property (nonatomic, assign) GRMAlertAnimationType animationType;

/** 屏幕方向 Default:GRMAlertScreenDirectionPortrait */
@property (nonatomic, assign) GRMAlertScreenDirection alertScreenDirection;

/** 每次显示只允许管理一个Alert */
@property (nonatomic, assign) BOOL onlyOneAlert;



/** 从xib中加载弹窗 */
+ (UIView *)showAlertViewFormNib:(NSString *)nibName configClickEvent:(ConfigClickEvent)config didSelectedBlock:(DidSelectedBlock)selectedBlock;
/** 从xib中加载弹窗，在将显示时需要做一些事 */
+ (UIView *)showAlertViewFormNib:(NSString *)nibName configClickEvent:(ConfigClickEvent)config willDisplay:(WillDisplay)doSomething didSelectedBlock:(DidSelectedBlock)selectedBlock;

/** 显示一个弹窗视图 */
+ (UIView *)showAlertView:(UIView *)view configClickEvent:(ConfigClickEvent)config didSelectedBlock:(DidSelectedBlock)selectedBlock;
/** 显示一个弹窗视图，在将显示时需要做一些事  */
+ (UIView *)showAlertView:(UIView *)view configClickEvent:(ConfigClickEvent)config willDisplay:(WillDisplay)doSomething didSelectedBlock:(DidSelectedBlock)selectedBlock;


+ (void)close;




/** 系统Alert */
+ (void)showSysAlertTitle:(NSString *)title message:(NSString *)message ok:(NSString *)ok cancel:(NSString *)cancel block:(void(^)(NSString *title))block;

@end
