//
//  UITools.m
//  TheKoran
//
//  Created by goorume on 2019/12/25.
//  Copyright © 2019 goorume. All rights reserved.
//

#import "UITools.h"

#import <MBProgressHUD/MBProgressHUD.h>

@implementation UITools

+ (UIImage *)imageWithView:(UIView *)view size:(CGSize)size {
    // 下面方法，第一个参数表示区域大小。第二个参数表示是否是非透明的。如果需要显示半透明效果，需要传NO，否则传YES。第三个参数就是屏幕密度了，关键就是第三个参数 [UIScreen mainScreen].scale。
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (void)showMessage:(NSString *)message {
    [self showMessage:message orientationType:0];
}
+ (void)showMessage:(NSString *)message orientationType:(NSInteger)type {
//    UIView *view = [[UIApplication sharedApplication].windows lastObject];
    UIView *view = [UIApplication sharedApplication].keyWindow.rootViewController.view;
    
    UIView *h = [view viewWithTag:99999];
    if (h) {
        [h removeFromSuperview];
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.tag = 99999;
    hud.contentColor = [UIColor whiteColor];
    hud.bezelView.backgroundColor = [UIColor blackColor];
    hud.detailsLabel.text = message;
    hud.mode = MBProgressHUDModeText;
    hud.margin = 10.f;
//    hud.square = YES;

    if (type == 0) {
        hud.offset = CGPointMake(0, [UIScreen mainScreen].bounds.size.height/2.0-130);
    } else if (type == 1) {
        hud.transform = CGAffineTransformMakeRotation(M_PI_2);
        hud.center = CGPointMake(40, [UIScreen mainScreen].bounds.size.height/2.0);
    } else {
        hud.transform = CGAffineTransformMakeRotation(-M_PI_2);
        hud.center = CGPointMake([UIScreen mainScreen].bounds.size.width-40, [UIScreen mainScreen].bounds.size.height/2.0);
    }
    
    hud.userInteractionEnabled = NO;
    hud.removeFromSuperViewOnHide = YES;
    [hud hideAnimated:YES afterDelay:2];
}

+ (void)showError:(NSString *)error {
    [self show:error icon:@"hud_error" view:nil];
}
+ (void)showSuccess:(NSString *)success {
    [self show:success icon:@"hud_success" view:nil];
}
+ (void)show:(NSString *)text icon:(NSString *)icon view:(UIView *)view {
    if (view == nil) view = [[UIApplication sharedApplication].windows lastObject];
    
//    MBProgressHUD *pHud = [view viewWithTag:99999];
//    if (pHud) {
//        [pHud hideAnimated:NO];
//    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.contentColor = [UIColor whiteColor];
    hud.bezelView.backgroundColor = [UIColor blackColor];
//    hud.tag = 99999;
    hud.detailsLabel.text = text;
    if (icon == nil) {
        hud.mode = MBProgressHUDModeText;
    }
    else if ([icon isEqualToString:@"hud_error"]) {
        CGFloat wh = 40;
        
        UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, wh, wh)];
        
        UIImageView *cv = [[UIImageView alloc] initWithImage:[self imageWithView:v size:CGSizeMake(wh, wh)]];
        cv.frame = CGRectMake(0, 0, wh, wh);
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, wh, wh) cornerRadius:wh/2];
        [path moveToPoint:CGPointMake(wh/2-wh/4, wh/4)];
        [path addLineToPoint:CGPointMake(wh/2+wh/4, wh*3/4)];

        [path moveToPoint:CGPointMake(wh/2+wh/4, wh/4)];
        [path addLineToPoint:CGPointMake(wh/2-wh/4, wh*3/4)];

        CAShapeLayer *sLayer = [CAShapeLayer layer];
        sLayer.frame = CGRectZero;
        sLayer.fillColor = [UIColor clearColor].CGColor;
        sLayer.path = path.CGPath;
        sLayer.strokeColor = [UIColor whiteColor].CGColor;
        sLayer.lineWidth = 2;
        sLayer.cornerRadius = wh/2;

        CABasicAnimation *ani = [ CABasicAnimation animationWithKeyPath: @"strokeEnd"];
        ani.fromValue = @0;
        ani.toValue = @1;
        ani.duration = 0.25;
        [sLayer addAnimation:ani forKey:@"strokeEnd"];

        [cv.layer addSublayer:sLayer];
        
        hud.customView = cv;
        hud.mode = MBProgressHUDModeCustomView;
    }
    else if ([icon isEqualToString:@"hud_success"]) {
        CGFloat wh = 40;
        
        UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, wh, wh)];
        
        UIImageView *cv = [[UIImageView alloc] initWithImage:[self imageWithView:v size:CGSizeMake(wh, wh)]];
        cv.frame = CGRectMake(0, 0, wh, wh);
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, wh, wh) cornerRadius:wh/2];
        [path moveToPoint:CGPointMake((wh-wh)/2+wh/4,  1 + wh/2)];
        [path addLineToPoint:CGPointMake(wh/2, wh*3/4)];
        [path addLineToPoint:CGPointMake(wh/2 + wh*1/3, wh*1/3)];
        
        CAShapeLayer *sLayer = [CAShapeLayer layer];
        sLayer.frame = CGRectZero;
        sLayer.fillColor = [UIColor clearColor].CGColor;
        sLayer.path = path.CGPath;
        sLayer.strokeColor = [UIColor whiteColor].CGColor;
        sLayer.lineWidth = 2;
        sLayer.cornerRadius = wh/2;
        
        CABasicAnimation *ani = [ CABasicAnimation animationWithKeyPath: @"strokeEnd"];
        ani.fromValue = @0;
        ani.toValue = @1;
        ani.duration = 0.25;
        [sLayer addAnimation:ani forKey:@"strokeEnd"];
        
        [cv.layer addSublayer:sLayer];
        
        hud.customView = cv;
        hud.mode = MBProgressHUDModeCustomView;
    }
    else{
        UIImage *img = [UIImage imageNamed:icon];
        hud.customView = [[UIImageView alloc] initWithImage:img];
        hud.mode = MBProgressHUDModeCustomView;
    }
    hud.margin = 10.f;
//    hud.square = YES;
//    hud.yOffset = kSCRHEIGHT/2;
    hud.userInteractionEnabled = NO;
    hud.removeFromSuperViewOnHide = YES;
    [hud hideAnimated:YES afterDelay:2];
}

+ (void)startLoading {
    UIView *view = [UIApplication sharedApplication].keyWindow.rootViewController.view;
    
    UIView *h = [view viewWithTag:99998];
    if (h) {
        [h removeFromSuperview];
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.tag = 99998;
    hud.contentColor = [UIColor whiteColor];
    hud.bezelView.backgroundColor = [UIColor blackColor];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.margin = 10.f;
//    hud.square = YES;
    hud.removeFromSuperViewOnHide = YES;
    hud.userInteractionEnabled = YES;
}

+ (void)stopLoading {
    UIView *view = [UIApplication sharedApplication].keyWindow.rootViewController.view;
    [MBProgressHUD hideHUDForView:view animated:YES];
}

@end
