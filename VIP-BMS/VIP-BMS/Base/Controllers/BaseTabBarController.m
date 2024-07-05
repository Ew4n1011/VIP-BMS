//
//  BaseTabBarController.m
//  TheKoran
//
//  Created by _G.R.M. on 2019/9/12.
//  Copyright © 2019年 goorume. All rights reserved.
//

#import "BaseTabBarController.h"

#import "BaseViewController.h"
#import "BaseNavigationController.h"


@interface BaseTabBarController ()<UITabBarControllerDelegate>

@end

@implementation BaseTabBarController {
    NSInteger _lastIndex;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.delegate = self;
    
    _lastIndex = 0;
    
    [self setUI];
}

- (BOOL)shouldAutorotate{
    return [self.selectedViewController shouldAutorotate];
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return [self.selectedViewController supportedInterfaceOrientations];
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return [self.selectedViewController preferredInterfaceOrientationForPresentation];
}

- (void)setUI {
    
    NSArray *controllersConfigArray = @[];
    
    NSMutableArray *controllers = [NSMutableArray array];
    for (int i = 0; i < controllersConfigArray.count; i++) {
        NSDictionary *config = [controllersConfigArray objectAtIndex:i];
        
        Class class = NSClassFromString([config stringForKey:@"class"]);
        BaseViewController *vc = (BaseViewController *)[[class alloc] init];
        
        BaseNavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:vc];
        nav.tabBarItem.title = [config stringForKey:@"title"];
        nav.tabBarItem.image = ImageNamed([config stringForKey:@"nor_Image"]);
        nav.tabBarItem.selectedImage = ImageNamed([config stringForKey:@"sel_Image"]);
        [nav.tabBarItem setTitleTextAttributes:@{NSFontAttributeName:[Utils font_Lato_B:14.0f]} forState:UIControlStateNormal];
        [controllers addObject:nav];
    }
    self.viewControllers = controllers;
    
    if (@available(iOS 13.0, *)) {
        self.tabBar.standardAppearance.inlineLayoutAppearance.normal.titleTextAttributes = @{NSFontAttributeName:[Utils font_Lato_B:14.0f]};
    } else {
        
    }
    self.tabBar.tintColor = kMAINCOLOR_FRONT;
    if (@available(iOS 10.0, *)) {
        self.tabBar.unselectedItemTintColor = kMAINCOLOR_BLACK;
    } else {
    }
    
}
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    _lastIndex = tabBarController.selectedIndex;
    return YES;
}

- (void)toLastController {
    if (_lastIndex < self.viewControllers.count) {
        self.selectedIndex = _lastIndex;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
