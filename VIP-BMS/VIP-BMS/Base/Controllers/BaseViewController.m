//
//  BaseViewController.m
//  BglenMask
//
//  Created by _G.R.M. on 2018/9/13.
//  Copyright © 2018年 _G.R.M. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@property (nonatomic, copy) AlertBlock alertBlock;

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = kMAINCOLOR_BG;
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    self.hbd_barShadowHidden = YES;
    self.hbd_barHidden = NO;
    self.hbd_barTintColor = kMAINCOLOR_FRONT;
    self.hbd_tintColor = UIColor.blackColor;
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationController.navigationBar.translucent = NO;
    
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)goBackShouldBegin {
    if (self.popBlock) {
        self.popBlock(nil, YES);
    }
    return YES;
}

//是否自动旋转,返回YES可以自动旋转,返回NO禁止旋转
- (BOOL)shouldAutorotate {
    return NO;
}
//返回支持的方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}
//由模态推出的视图控制器 优先支持的屏幕方向
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation { 
    return UIInterfaceOrientationPortrait;
}

- (void)setUI {
    

}

- (BOOL)isVisible {
    return (self.isViewLoaded && self.view.window);
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
