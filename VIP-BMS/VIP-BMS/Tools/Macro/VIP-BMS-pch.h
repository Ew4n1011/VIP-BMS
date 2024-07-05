//
//  TheKoran-pch.h
//  TheKoran
//
//  Created by _G.R.M. on 2018/9/15.
//  Copyright © 2018年 _G.R.M. All rights reserved.
//

#ifndef TheKoran_pch_h
#define TheKoran_pch_h


//===================  生产环境  ===================


//===================  测试环境  ===================


//================================================

#define UserPassword @"MeEnergy1234"


#import <UIKit/UIKit.h>
#import "AppDelegate.h"

#import <GRMBluetooth/GRMBluetooth.h>
#import <IQKeyboardManager/IQKeyboardManager.h>
#import "Masonry.h"
#import "NSBundle+Language.h"

#import "NSDictionary+SafeAccess.h"

#import "DefineTools.h"
#import "ColorDefine.h"
#import "NotificationDefine.h"

#import "Utils.h"
#import "UITools.h"


typedef void(^PopBlock)(NSDictionary *info, BOOL updata);


/// User


#endif /* TheKoran_pch_h */
