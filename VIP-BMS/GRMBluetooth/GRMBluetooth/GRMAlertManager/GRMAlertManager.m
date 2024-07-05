//
//  GRMAlertManager.m
//  GRMToolBox
//
//  Created by G.R.M. on 2018/2/8.
//  Copyright © 2018年 _G.R.M. All rights reserved.
//

#import "GRMAlertManager.h"

#define grmAnimateDuration .25

// 屏幕尺寸（支持横屏）
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0 // 当前Xcode支持iOS8及以上
#define GRM_SCREEN_WIDTH ([[UIScreen mainScreen] respondsToSelector:@selector(nativeBounds)]?[UIScreen mainScreen].nativeBounds.size.width/[UIScreen mainScreen].nativeScale:[UIScreen mainScreen].bounds.size.width)
#define GRM_SCREENH_HEIGHT ([[UIScreen mainScreen] respondsToSelector:@selector(nativeBounds)]?[UIScreen mainScreen].nativeBounds.size.height/[UIScreen mainScreen].nativeScale:[UIScreen mainScreen].bounds.size.height)
#define GRM_SCREEN_SIZE ([[UIScreen mainScreen] respondsToSelector:@selector(nativeBounds)]?CGSizeMake([UIScreen mainScreen].nativeBounds.size.width/[UIScreen mainScreen].nativeScale,[UIScreen mainScreen].nativeBounds.size.height/[UIScreen mainScreen].nativeScale):[UIScreen mainScreen].bounds.size)
#else
#define GRM_SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define GRM_SCREENH_HEIGHT [UIScreen mainScreen].bounds.size.height
#define GRM_SCREEN_SIZE [UIScreen mainScreen].bounds.size
#endif

#define GRM_UIColorFromRGBA(rgbValue, alp)    [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0 blue:((float)(rgbValue & 0xFF)) / 255.0 alpha:alp]
#define GRM_UIColorFromRGB(rgbValue) UIColorFromRGBA(rgbValue, 1.0)



static NSString *AlerViewKey         = @"AlerView";
static NSString *ClickButtonArrayKey = @"ClickButtonArray";



@interface AlertModel : NSObject

@property (nonatomic, strong) UIView *alertView;
@property (nonatomic, copy) ConfigClickEvent configClickEvent;
@property (nonatomic, copy) WillDisplay      doSomething;
@property (nonatomic, copy) DidSelectedBlock didSelectedBlock;

@end

@implementation AlertModel

@end




@interface GRMAlertManager ()

@property (nonatomic, strong) UIButton *bbgView;
@property (nonatomic, strong) NSMutableArray<AlertModel *> *alertViewArray;

@end

@implementation GRMAlertManager {
    grmGCDTask _task;
}

static GRMAlertManager *sharedGRMAlertManager = nil;

+ (GRMAlertManager *)sharedGRMAlertManager {
    @synchronized(self) {
        if (sharedGRMAlertManager == nil) {
            sharedGRMAlertManager = [[self alloc] init];
        }
    }
    return sharedGRMAlertManager;
}
+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedGRMAlertManager == nil) {
            sharedGRMAlertManager = [super allocWithZone:zone];
            return sharedGRMAlertManager;
        }
    }
    return nil;
}
- (id)copyWithZone:(NSZone *)zone {
    return self;
}

+ (void)destroy {
    sharedGRMAlertManager = nil;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _alertViewArray = [NSMutableArray array];
        
        _bbgView = [[UIButton alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _bbgView.backgroundColor = GRM_UIColorFromRGBA(0x000000, 0.6);
        [_bbgView addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return self;
}

- (void)dealloc {
    NSLog(@"[GRMAlertManager] dealloc ~~~~~~");
}

- (void)cancel {
    
    if (self.backgroundEnabled) {
        [self dismissCompletion:nil];
    }
    
}

- (void)show {
    
    UIView *pView = [[UIApplication sharedApplication].keyWindow.rootViewController.view viewWithTag:50001];
    if (pView) {
        [pView removeFromSuperview];
    }
    
    AlertModel *alertModel = [_alertViewArray lastObject];
    
    if (!alertModel) {
        [self.bbgView removeFromSuperview];
        [GRMAlertManager destroy];
        return;
    }
    
    // 如果有延时任务，则取消延时任务
    if (_task) {
        NSLog(@"取消");
        [[self class] gcdCancel:_task];
        _task = nil;
    }
    
    // 恢复默认配置
    self.backgroundEnabled = YES;
    self.dismissAfterTime  = 0;
    self.animationType     = GRMAlertAnimationCenterScale;
    self.alertScreenDirection = GRMAlertScreenDirectionPortrait;
    
    NSArray *clickButtonArray = nil;
    if (alertModel.configClickEvent) {
        clickButtonArray = alertModel.configClickEvent(alertModel.alertView);
        
        for (int i = 0; i < clickButtonArray.count; i++) {
            UIButton *btn = [clickButtonArray objectAtIndex:i];
            btn.tag = 40000+i;
            [btn addTarget:self action:@selector(didClicked:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    
    
    if (!_bbgView.superview) {
        [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:_bbgView];
    }
    [_bbgView addSubview:alertModel.alertView];
    
    // 显示动画
    [self configAnimateWithType:self.animationType toAlert:alertModel];
    
    if (self.dismissAfterTime > 0) {
        if (alertModel.alertView.superview) {
            if (alertModel.doSomething) {
                alertModel.doSomething(alertModel.alertView);
            }
            
            _task = [[self class] gcdDelay:self.dismissAfterTime task:^{
                if (alertModel.alertView.superview) {
                    [self dismissCompletion:^(BOOL finished) {
                        if (alertModel.didSelectedBlock) {
                            alertModel.didSelectedBlock(0, alertModel.alertView);
                        }
                    }];
                }
            }];
            
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.dismissAfterTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                if (alertModel.alertView.superview) {
//                    [self dissmiss];
//
//                    if (alertModel.didSelectedBlock) {
//                        alertModel.didSelectedBlock(0, alertModel.alertView);
//                    }
//                }
//            });
        }
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            if (alertModel.alertView.superview) {
//                if (alertModel.doSomething) {
//                    alertModel.doSomething(alertModel.alertView);
//                }
//
//                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.dismissAfterTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                    if (alertModel.alertView.superview) {
//                        [self dissmiss];
//
//                        if (alertModel.didSelectedBlock) {
//                            alertModel.didSelectedBlock(0, alertModel.alertView);
//                        }
//                    }
//                });
//            }
//        });
    } else {
        
        if (alertModel.doSomething) {
            alertModel.doSomething(alertModel.alertView);
        }
        
    }
    
}

- (void)dismissCompletion:(void (^)(BOOL finished))completion {
    
    AlertModel *alertModel = [_alertViewArray lastObject];
    
    if (!alertModel) {
        [self.bbgView removeFromSuperview];
        [GRMAlertManager destroy];
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [self dismissAnimateWithType:self.animationType toAlert:alertModel completion:^(BOOL finished) {
        
        [alertModel.alertView removeFromSuperview];
        [weakSelf.alertViewArray removeLastObject];
        
        if (completion) {
            completion(finished);
        }
        
        AlertModel *pAlertModel = [weakSelf.alertViewArray lastObject];
        if (pAlertModel) {
            [weakSelf show];
        } else {
            [weakSelf.bbgView removeFromSuperview];
            [GRMAlertManager destroy];
        }
    }];
}

- (void)didClicked:(UIButton *)button {
    
    AlertModel *alertModel = [_alertViewArray lastObject];
    
    NSInteger index = button.tag - 40000;
    
    [self dismissCompletion:^(BOOL finished) {
        if (alertModel.didSelectedBlock) {
            alertModel.didSelectedBlock(index, alertModel.alertView);
        }
    }];

}

- (void)configAnimateWithType:(GRMAlertAnimationType)animationType toAlert:(AlertModel *)alertModel {
    CGAffineTransform rotation;
    if (self.alertScreenDirection == GRMAlertScreenDirectionLandscapeLeft) {
        rotation = CGAffineTransformMakeRotation(M_PI_2);
    } else if (self.alertScreenDirection == GRMAlertScreenDirectionLandscapeRight) {
        rotation = CGAffineTransformMakeRotation(-M_PI_2);
    } else {
        rotation = CGAffineTransformMakeRotation(0);
    }
    
    if (animationType == GRMAlertAnimationNone) {
        CGRect rect = alertModel.alertView.frame;
        alertModel.alertView.frame = CGRectMake(0, GRM_SCREENH_HEIGHT-rect.size.height, rect.size.width, rect.size.height);
        return;
    }
    
    if (animationType == GRMAlertAnimationCenterScale) {
//        alertModel.alertView.transform = CGAffineTransformMakeScale(CGFLOAT_MIN, CGFLOAT_MIN);
        alertModel.alertView.transform = CGAffineTransformScale(rotation, CGFLOAT_MIN, CGFLOAT_MIN);
        [UIView animateWithDuration:grmAnimateDuration animations:^{
            alertModel.alertView.transform = CGAffineTransformScale(rotation, 1, 1);
        }];
        if (CGRectEqualToRect(alertModel.alertView.frame, CGRectZero)) {
            alertModel.alertView.translatesAutoresizingMaskIntoConstraints = NO;
            
            [alertModel.alertView.superview addConstraint:[NSLayoutConstraint constraintWithItem:alertModel.alertView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:alertModel.alertView.superview attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
            [alertModel.alertView.superview addConstraint:[NSLayoutConstraint constraintWithItem:alertModel.alertView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:alertModel.alertView.superview attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];

        } else {
            alertModel.alertView.center = CGPointMake(GRM_SCREEN_WIDTH/2.0, GRM_SCREENH_HEIGHT/2.0);
        }
        return;
    }
    
    if (animationType == GRMAlertAnimationBottomSheet) {
        if (CGRectEqualToRect(alertModel.alertView.frame, CGRectZero)) {
            alertModel.alertView.translatesAutoresizingMaskIntoConstraints = NO;
            
            [alertModel.alertView.superview addConstraint:[NSLayoutConstraint constraintWithItem:alertModel.alertView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:alertModel.alertView.superview attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
            [alertModel.alertView.superview addConstraint:[NSLayoutConstraint constraintWithItem:alertModel.alertView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:alertModel.alertView.superview attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
            [alertModel.alertView.superview layoutIfNeeded];
            
            [alertModel.alertView.superview removeConstraints:alertModel.alertView.superview.constraints];
            [alertModel.alertView.superview addConstraint:[NSLayoutConstraint constraintWithItem:alertModel.alertView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:alertModel.alertView.superview attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
            [alertModel.alertView.superview addConstraint:[NSLayoutConstraint constraintWithItem:alertModel.alertView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:alertModel.alertView.superview attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
            [UIView animateWithDuration:grmAnimateDuration animations:^{
               [alertModel.alertView.superview layoutIfNeeded];
            }];
            
        } else {
            CGRect rect = alertModel.alertView.frame;
            alertModel.alertView.frame = CGRectMake((GRM_SCREEN_WIDTH-rect.size.width)/2.0, GRM_SCREENH_HEIGHT, rect.size.width, rect.size.height);
            [UIView animateWithDuration:grmAnimateDuration animations:^{
                alertModel.alertView.frame = CGRectMake((GRM_SCREEN_WIDTH-rect.size.width)/2.0, GRM_SCREENH_HEIGHT-rect.size.height, rect.size.width, rect.size.height);
            }];
        }

        return;
    }
    
    if (animationType == GRMAlertAnimationTopSheet) {
        if (CGRectEqualToRect(alertModel.alertView.frame, CGRectZero)) {
            alertModel.alertView.translatesAutoresizingMaskIntoConstraints = NO;
            
            [alertModel.alertView.superview addConstraint:[NSLayoutConstraint constraintWithItem:alertModel.alertView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:alertModel.alertView.superview attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
            [alertModel.alertView.superview addConstraint:[NSLayoutConstraint constraintWithItem:alertModel.alertView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:alertModel.alertView.superview attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
            [alertModel.alertView.superview layoutIfNeeded];
            
            [alertModel.alertView.superview removeConstraints:alertModel.alertView.superview.constraints];
            [alertModel.alertView.superview addConstraint:[NSLayoutConstraint constraintWithItem:alertModel.alertView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:alertModel.alertView.superview attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
            [alertModel.alertView.superview addConstraint:[NSLayoutConstraint constraintWithItem:alertModel.alertView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:alertModel.alertView.superview attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
            [UIView animateWithDuration:grmAnimateDuration animations:^{
                [alertModel.alertView.superview layoutIfNeeded];
            }];
            
        } else {
            CGRect rect = alertModel.alertView.frame;
            alertModel.alertView.frame = CGRectMake((GRM_SCREEN_WIDTH-rect.size.width)/2.0, -rect.size.height, rect.size.width, rect.size.height);
            [UIView animateWithDuration:grmAnimateDuration animations:^{
                alertModel.alertView.frame = CGRectMake((GRM_SCREEN_WIDTH-rect.size.width)/2.0, 0, rect.size.width, rect.size.height);
            }];
        }
        return;
    }
}
- (void)dismissAnimateWithType:(GRMAlertAnimationType)animationType toAlert:(AlertModel *)alertModel completion:(void (^)(BOOL finished))completion {
    
    if (animationType == GRMAlertAnimationNone) {
        completion(YES);
        return;
    }
    if (animationType == GRMAlertAnimationCenterScale) {
        
        CGAffineTransform rotation;
        if (self.alertScreenDirection == GRMAlertScreenDirectionLandscapeLeft) {
            rotation = CGAffineTransformMakeRotation(M_PI_2);
        } else if (self.alertScreenDirection == GRMAlertScreenDirectionLandscapeRight) {
            rotation = CGAffineTransformMakeRotation(-M_PI_2);
        } else {
            rotation = CGAffineTransformMakeRotation(0);
        }
        [UIView animateWithDuration:grmAnimateDuration animations:^{
            alertModel.alertView.transform = CGAffineTransformScale(rotation, 0.01, 0.01);
        } completion:^(BOOL finished) {
            completion(finished);
        }];
        return;
    }
    if (animationType == GRMAlertAnimationBottomSheet) {
        [UIView animateWithDuration:grmAnimateDuration animations:^{
            alertModel.alertView.frame = CGRectMake(alertModel.alertView.frame.origin.x, GRM_SCREENH_HEIGHT, alertModel.alertView.frame.size.width, alertModel.alertView.frame.size.height);
        } completion:^(BOOL finished) {
            completion(finished);
        }];
        return;
    }
    if (animationType == GRMAlertAnimationTopSheet) {
        [UIView animateWithDuration:grmAnimateDuration animations:^{
            alertModel.alertView.frame = CGRectMake(alertModel.alertView.frame.origin.x, -alertModel.alertView.frame.size.height, alertModel.alertView.frame.size.width, alertModel.alertView.frame.size.height);
        } completion:^(BOOL finished) {
            completion(finished);
        }];
        return;
    }
}

+ (UIView *)showAlertViewFormNib:(NSString *)nibName configClickEvent:(NSArray * (^)(UIView *alert))config didSelectedBlock:(void (^)(NSInteger index, UIView *alert))selectedBlock {
    
    UIView *view = [[[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil] lastObject];
    return [self showAlertView:view configClickEvent:config willDisplay:nil didSelectedBlock:selectedBlock];
}
+ (UIView *)showAlertViewFormNib:(NSString *)nibName configClickEvent:(ConfigClickEvent)config willDisplay:(WillDisplay)doSomething didSelectedBlock:(DidSelectedBlock)selectedBlock {
    
    UIView *view = [[[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil] lastObject];
    return [self showAlertView:view configClickEvent:config willDisplay:doSomething didSelectedBlock:selectedBlock];
}
+ (UIView *)showAlertView:(UIView *)view configClickEvent:(NSArray* (^)(UIView *alert))config didSelectedBlock:(void (^)(NSInteger index, UIView *alert))selectedBlock {
    
    return [self showAlertView:view configClickEvent:config willDisplay:nil didSelectedBlock:selectedBlock];
}
+ (UIView *)showAlertView:(UIView *)view configClickEvent:(ConfigClickEvent)config willDisplay:(WillDisplay)doSomething didSelectedBlock:(DidSelectedBlock)selectedBlock {
    
    view.tag = 50001;
    
    AlertModel *alertModel = [[AlertModel alloc] init];
    alertModel.alertView = view;
    if (config) {
        alertModel.configClickEvent = config;
    }
    if (doSomething) {
        alertModel.doSomething = doSomething;
    }
    if (selectedBlock) {
        alertModel.didSelectedBlock = selectedBlock;
    }
    
    if ([GRMAlertManager sharedGRMAlertManager].onlyOneAlert) {
        [[GRMAlertManager sharedGRMAlertManager].alertViewArray removeAllObjects];
    }
    
    [[GRMAlertManager sharedGRMAlertManager].alertViewArray addObject:alertModel];
    
    [[GRMAlertManager sharedGRMAlertManager] show];
    
    return view;
}

+ (void)close {
    [[GRMAlertManager sharedGRMAlertManager] dismissCompletion:nil];
}




#pragma mark - 系统AlertView
+ (void)showSysAlertTitle:(NSString *)title message:(NSString *)message ok:(NSString *)ok cancel:(NSString *)cancel block:(void(^)(NSString *title))block {
    
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    if (ok.length) {
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:ok style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (block) {
                block(ok);
            }
        }];
        [ac addAction:okAction];
    }
    
    if (cancel.length) {
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancel style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            if (block) {
                block(cancel);
            }
        }];
        [ac addAction:cancelAction];
    }
    
    [[GRMAlertManager sharedGRMAlertManager].appWindow.rootViewController presentViewController:ac animated:YES completion:nil];
}



#pragma mark - GCD
+(void)dispatch_after:(NSTimeInterval)time block:(dispatch_block_t)block {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), block);
}

+(grmGCDTask)gcdDelay:(NSTimeInterval)time task:(dispatch_block_t)block {
    __block dispatch_block_t closure = block;
    __block grmGCDTask result;
    grmGCDTask delayedClosure = ^(BOOL cancel){
        if (closure) {
            if (!cancel) {
                dispatch_async(dispatch_get_main_queue(), closure);
            }
        }
        closure = nil;
        result = nil;
    };
    result = delayedClosure;
    [self dispatch_after:time block:^{
        if (result)
            result(NO);
    }];
    
    return result;
}

+(void)gcdCancel:(grmGCDTask)task {
    task(YES);
}



@end
