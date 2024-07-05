//
//  DefineTools.h
//  GRMPods
//
//  Created by G.R.M. on 2017/3/30.
//  Copyright © 2017年 goorume. All rights reserved.
//

#ifndef DefineTools_h
#define DefineTools_h

// 屏幕尺寸（支持横屏）
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0 // 当前Xcode支持iOS8及以上
#define SCREEN_WIDTH ([[UIScreen mainScreen] respondsToSelector:@selector(nativeBounds)]?[UIScreen mainScreen].nativeBounds.size.width/[UIScreen mainScreen].nativeScale:[UIScreen mainScreen].bounds.size.width)
#define SCREENH_HEIGHT ([[UIScreen mainScreen] respondsToSelector:@selector(nativeBounds)]?[UIScreen mainScreen].nativeBounds.size.height/[UIScreen mainScreen].nativeScale:[UIScreen mainScreen].bounds.size.height)
#define SCREEN_SIZE ([[UIScreen mainScreen] respondsToSelector:@selector(nativeBounds)]?CGSizeMake([UIScreen mainScreen].nativeBounds.size.width/[UIScreen mainScreen].nativeScale,[UIScreen mainScreen].nativeBounds.size.height/[UIScreen mainScreen].nativeScale):[UIScreen mainScreen].bounds.size)
#else
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREENH_HEIGHT [UIScreen mainScreen].bounds.size.height
#define SCREEN_SIZE [UIScreen mainScreen].bounds.size
#endif

#define kStatusBarHeight ([[UIApplication sharedApplication] statusBarFrame].size.height)
#define kNavBarHeight 44.0
#define kTabBarHeight (kStatusBarHeight>20?83:49)
#define kTopHeight (kStatusBarHeight + kNavBarHeight)

//设备(iphone、ipad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPAD   (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)


//苹果4以下产品（包括4）
#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREENH_HEIGHT < 568.0)
//苹果4、4s
#define IS_IPHONE_4 (IS_IPHONE && SCREENH_HEIGHT == 480 && SCREEN_WIDTH == 320)
//苹果5以下产品（包括4）
#define IS_IPHONE_5_OR_LESS (IS_IPHONE && SCREENH_HEIGHT <= 568.0)
//苹果5
#define IS_IPHONE_5 (IS_IPHONE && SCREENH_HEIGHT = 568.0)
//6、6S、7、8
#define IS_IPHONE_6 (IS_IPHONE && SCREENH_HEIGHT == 667.0)
//6+、6S+、7+、8+
#define IS_IPHONE_6P (IS_IPHONE && SCREENH_HEIGHT == 736.0)
//X XS
#define IS_IPHONE_X (IS_IPHONE && SCREENH_HEIGHT == 812.0)
//XR XSMAX
#define IS_IPHONE_XR (IS_IPHONE && SCREENH_HEIGHT == 896.0)

// 全面屏
#define iSFULLSCREEN (IS_IPHONE_X || IS_IPHONE_XR)


// IOS 系统版本
#define IOS_SYS_VERSION [[UIDevice currentDevice] systemVersion]
#define IOS_VERSION   floorf([[UIDevice currentDevice].systemVersion floatValue]
#define IOS_5         floorf([[UIDevice currentDevice].systemVersion floatValue]) >= 5.0  ? YES : NO
#define IOS_6         floorf([[UIDevice currentDevice].systemVersion floatValue]) >= 6.0  ? YES : NO
#define IOS_7         floorf([[UIDevice currentDevice].systemVersion floatValue]) >= 7.0  ? YES : NO
#define IOS_8         floorf([[UIDevice currentDevice].systemVersion floatValue]) >= 8.0  ? YES : NO
#define IOS_9         floorf([[UIDevice currentDevice].systemVersion floatValue]) >= 9.0  ? YES : NO
#define IOS_10        floorf([[UIDevice currentDevice].systemVersion floatValue]) >= 10.0 ? YES : NO
#define IOS_11        floorf([[UIDevice currentDevice].systemVersion floatValue]) >= 11.0 ? YES : NO
#define IOS_12        floorf([[UIDevice currentDevice].systemVersion floatValue]) >= 12.0 ? YES : NO
#define IOS_13        floorf([[UIDevice currentDevice].systemVersion floatValue]) >= 13.0 ? YES : NO

// APP 版本
#define APP_VERSION [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]

// AppDelegate
#define APP ((AppDelegate *)[UIApplication sharedApplication].delegate)

//获取当前语言
#define CurrentLanguage ([[NSLocale preferredLanguages] objectAtIndex:0])

// 获取国际化字符串
#define InternationaString(NSString_Nonnull_format)  NSLocalizedString(NSString_Nonnull_format, nil)

// 通知中心
#define NotificationCenter [NSNotificationCenter defaultCenter]

//NSUserDefaults 实例化
#define USER_DEFAULT [NSUserDefaults standardUserDefaults]



// 蓝牙单例
#define BTM [GRMBluetoothManager sharedGRMBluetoothManager]


// 弱引用 强引用
#define WEAKSELF(object) __weak __typeof__(object) weak##_##object = object
#define STRONGSELF(object) __typeof__(object) object = weak##_##object


// 由角度转换弧度 由弧度转换角度
#define DegreesToRadian(x) (M_PI * (x) / 180.0)
#define RadianToDegrees(radian) (radian*180.0)/(M_PI)

// 加载 xib
#define kRoadXib(name) [[[NSBundle mainBundle] loadNibNamed:name owner:nil options:nil] firstObject]

//获取 目录文件
#define kPathTemp       NSTemporaryDirectory()
#define kPathDocument   [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]
#define kPathCache      [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject]

// GCD
#define kDISPATCH_ONCE_BLOCK(onceBlock) static dispatch_once_t onceToken; dispatch_once(&onceToken, onceBlock);
#define kDISPATCH_MAIN_THREAD(mainQueueBlock) dispatch_async(dispatch_get_main_queue(), mainQueueBlock);
#define kDISPATCH_GLOBAL_QUEUE_DEFAULT(globalQueueBlock) dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), globalQueueBlocl);

// 本地图片
#define LOADIMAGE(file,ext) [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:file ofType:ext]]
#define IMAGE(file)         LOADIMAGE(file,nil)
#define ImageNamed(imgName) [UIImage imageNamed:imgName]

//代理实现
#define DELEGATE_IMP(selector,param) \
if(self.delegate && [self.delegate respondsToSelector:(selector)]){\
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
[self.delegate performSelector:(selector) withObject:(param)];\
_Pragma("clang diagnostic pop") \
}
#define DELEGATE_IMP2(selector,param,otherParam) \
if(self.delegate && [self.delegate respondsToSelector:(selector)]){\
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
[self.delegate performSelector:(selector) withObject:(param) withObject:(otherParam)];\
_Pragma("clang diagnostic pop") \
}

//单例化一个类（非线程安全）
#define SINGLETON_FOR_IMPLEMENTATION_NO(classname) \
\
static classname *shared##classname = nil; \
\
+ (classname *)shared##classname \
{ \
@synchronized(self) \
{ \
if (shared##classname == nil) \
{ \
shared##classname = [[self alloc] init]; \
} \
} \
\
return shared##classname; \
} \
\
+ (id)allocWithZone:(NSZone *)zone \
{ \
@synchronized(self) \
{ \
if (shared##classname == nil) \
{ \
shared##classname = [super allocWithZone:zone]; \
return shared##classname; \
} \
} \
return nil; \
} \
\
- (id)copyWithZone:(NSZone *)zone \
{ \
return self; \
}

#define SINGLETON_FOR_INTERFACE_NO(classname) \
\
+ (classname *)shared##classname; \


//单例化一个类（线程安全）
#define SINGLETON_FOR_IMPLEMENTATION(classname) \
\
static classname *shared##classname = nil; \
\
+ (classname *)shared##classname \
{ \
static dispatch_once_t onceToken;\
dispatch_once(&onceToken,^{\
shared##classname = [[self alloc] init];\
});\
return shared##classname;\
} \
\
+ (id)allocWithZone:(NSZone *)zone \
{ \
@synchronized(self) \
{ \
if (shared##classname == nil) \
{ \
shared##classname = [super allocWithZone:zone]; \
return shared##classname; \
} \
} \
return nil; \
} \
\
- (id)copyWithZone:(NSZone *)zone \
{ \
return self; \
}


#define SINGLETON_FOR_INTERFACE(classname) \
\
+ (classname *)shared##classname; \



#endif /* DefineTools_h */
