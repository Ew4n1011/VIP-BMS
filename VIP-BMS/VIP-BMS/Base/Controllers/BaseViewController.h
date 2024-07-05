//
//  BaseViewController.h
//  BglenMask
//
//  Created by _G.R.M. on 2018/9/13.
//  Copyright © 2018年 _G.R.M. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VIP-BMS-pch.h"

#import "UIViewController+HBD.h"

typedef void(^AlertBlock)(NSString *title);

@interface BaseViewController : UIViewController

// 返回时的回调
@property (nonatomic, copy) PopBlock popBlock;



/** 子类可重写该方法实现特殊的返回事件。  默认返回YES，表示允许Pop */
- (BOOL)goBackShouldBegin;


- (void)setUI;

/** 当前控制器是否可见 */ 
- (BOOL)isVisible;



@end
