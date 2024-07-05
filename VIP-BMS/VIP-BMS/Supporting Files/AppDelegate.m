//
//  AppDelegate.m
//  VIP-BMS
//
//  Created by goorume on 2020/4/23.
//  Copyright © 2020 goorume. All rights reserved.
//

#import "AppDelegate.h"

#import "BaseViewController.h"
#import "BaseTabBarController.h"
#import "BaseNavigationController.h"

#import "SearchController.h"
#import "HomeController.h"
#import "BatterysController.h"
#import "SettingController.h"
#import "AboutController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate {
    NSTimer *_timer;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [IQKeyboardManager sharedManager].enable = YES;
    
    // 初始化
    [GRMBluetoothManager sharedGRMBluetoothManager];
    
    // App 语言
    [self language];
    
    NSArray *classNameArray = @[@{@"title":InternationaString(@"Buscar"), @"class":@"SearchController",
                                  @"image":@"tabbar_search_noramal", @"selectedImage":@"tabbar_search_selected"},
                                
                                @{@"title":InternationaString(@"Tiempo Real"), @"class":@"HomeController",
                                  @"image":@"tabbar_realime_noraml",   @"selectedImage":@"tabbar_realime_selected"},
                                
                                @{@"title":InternationaString(@"Parámetros"), @"class":@"BatterysController",
                                  @"image":@"tabbar_parameter_noraml", @"selectedImage":@"tabbar_parameter_selected"},
                                
                                @{@"title":InternationaString(@"Configuración"), @"class":@"SettingController",
                                  @"image":@"tabbar_setting_noraml",   @"selectedImage":@"tabbar_setting_selected"},
                                
                                @{@"title":InternationaString(@"Info"), @"class":@"AboutController",
                                  @"image":@"tabbar_about_noraml",     @"selectedImage":@"tabbar_about_selected"}];
    NSMutableArray *controllers = [NSMutableArray array];
    for (NSDictionary *classInfo in classNameArray) {
        UIViewController *vc = [[NSClassFromString(classInfo[@"class"]) alloc] init];
        BaseNavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:vc];
        nav.tabBarItem.title = classInfo[@"title"];
        nav.tabBarItem.titlePositionAdjustment = UIOffsetMake(0, -4);
        nav.tabBarItem.image = ImageNamed(classInfo[@"image"]);
        nav.tabBarItem.selectedImage = ImageNamed(classInfo[@"selectedImage"]);
        nav.hidesBottomBarWhenPushed = YES;
        [nav.tabBarItem setTitleTextAttributes:@{NSFontAttributeName:[Utils font_Lato_B:13.0f]} forState:UIControlStateNormal];
        [controllers addObject:nav];
    }
    BaseTabBarController *tab = [[BaseTabBarController alloc] init];
    tab.viewControllers = controllers;
    tab.tabBar.tintColor = kMAINCOLOR_GREEN;
    tab.tabBar.barTintColor = UIColor.whiteColor;
    tab.tabBar.translucent = NO;
    tab.tabBar.backgroundImage = [UIImage new];
    tab.tabBar.shadowImage =[UIImage new];
    self.window.rootViewController = tab;
    
    [self.window makeKeyAndVisible];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disconnect:) name:NotificationBlueToothDisconnect object:nil];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - 语言
- (void)language {
    
    NSString *appLanguage = [USER_DEFAULT stringForKey:@"AppLanguage"];
    if ([appLanguage isEqualToString:@"en"]) {
        [NSBundle setLanguage:@"en"];
    }
    else if ([appLanguage isEqualToString:@"zh-Hans"]) {
        [NSBundle setLanguage:@"zh-Hans"];
    }
}

#pragma mark - 全局定时器
- (void)startTimer {
    _stop = NO;
    if (_timer.isValid) {
        [_timer invalidate];
        _timer = nil;
    }
    
    GRMDevice *device = [GRMBluetoothManager sharedGRMBluetoothManager].device;
    CGFloat timeInterval = device.deviceType == Device_20 ? 1.5 : 0.8;
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(updateDevice) userInfo:nil repeats:YES];
}
- (void)stopTimer {
    _stop = YES;
    if (_timer.isValid) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)updateDevice {
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationUpdateDevice object:nil];
}

#pragma mark - 断开通知
- (void)disconnect:(NSNotification *)aNotification {
    if (_timer.isValid) {
        [_timer invalidate];
        _timer = nil;
    }
}

@end
