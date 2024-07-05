//
//  BaseNavigationController.m
//  BGBT
//
//  Created by _G.R.M. on 2018/12/5.
//  Copyright © 2018年 _G.R.M. All rights reserved.
//

#import "BaseNavigationController.h"

#import "BaseViewController.h"

@interface BaseNavigationController ()<UIGestureRecognizerDelegate>

@end

@implementation BaseNavigationController {
    BOOL _gesturePop;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.interactivePopGestureRecognizer.delegate = self;
    
    [self baseConfig];
}

- (void)baseConfig {
    
    // 去除系统背景
//    [self.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
//    [self.navigationBar setShadowImage:[UIImage new]];
    
//    [UINavigationBar appearance].tintColor = [UIColor blackColor];
//    [UINavigationBar appearance].barTintColor = [UIColor whiteColor];
//    [UINavigationBar appearance].titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor blackColor],NSFontAttributeName:[GRMTools font_EN_B:17]};

}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    
    if(self.viewControllers.count == 1) {
        return NO;
    }
    
    BOOL enable = YES;
    if ([self.topViewController isKindOfClass:[BaseViewController class]]) {
        if ([self.topViewController respondsToSelector:@selector(goBackShouldBegin)]) {
            BaseViewController *vc = (BaseViewController *)self.topViewController;
            enable = [vc goBackShouldBegin];
        }
    }
    
    return enable;
}

- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item {
    
    if([self.viewControllers count] < [navigationBar.items count]) {
        return YES;
    }
    
    BOOL enable = YES;
    if ([self.topViewController isKindOfClass:[BaseViewController class]]) {
        if ([self.topViewController respondsToSelector:@selector(goBackShouldBegin)]) {
            BaseViewController *vc = (BaseViewController *)self.topViewController;
            enable = [vc goBackShouldBegin];
        }
    }
    
    if (!(IOS_13)) {
        [self popViewControllerAnimated:YES];
    }
    
    return enable;
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.viewControllers.count > 0) {
        viewController.hidesBottomBarWhenPushed = YES;
    }
    [super pushViewController:viewController animated:animated];
}

- (BOOL)shouldAutorotate {
    return [self.topViewController shouldAutorotate];
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return [self.topViewController supportedInterfaceOrientations];
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return [self.topViewController preferredInterfaceOrientationForPresentation];
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
