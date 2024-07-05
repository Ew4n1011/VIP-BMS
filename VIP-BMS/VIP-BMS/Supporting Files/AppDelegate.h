//
//  AppDelegate.h
//  VIP-BMS
//
//  Created by goorume on 2020/4/23.
//  Copyright © 2020 goorume. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VIP-BMS-pch.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;


- (void)startTimer;
- (void)stopTimer;
@property (nonatomic, assign) BOOL stop;


- (void)language;

@end

