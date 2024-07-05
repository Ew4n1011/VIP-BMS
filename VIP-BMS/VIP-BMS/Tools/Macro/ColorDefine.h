//
//  ColorDefine.h
//  TheKoran
//
//  Created by _G.R.M. on 2018/9/15.
//  Copyright © 2018年 _G.R.M. All rights reserved.
//

#ifndef ColorDefine_h
#define ColorDefine_h

// 颜色转换
#define UIColorFromRGBA(rgbValue, alp)    [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0 blue:((float)(rgbValue & 0xFF)) / 255.0 alpha:alp]
#define UIColorFromRGB(rgbValue) UIColorFromRGBA(rgbValue, 1.0)

#define RGBA(R,G,B,A) [UIColor colorWithRed:R/255.0f green:G/255.0f blue:B/255.0f alpha:A]
#define RGB(R,G,B) RGBA(R,G,B,1.0f)


#define kMAINCOLOR_GREEN  UIColorFromRGB(0x47B632)  // 主色调
#define kMAINCOLOR_BG     UIColorFromRGB(0xF9F9F9)  // 背景色
#define kMAINCOLOR_BUTTON_BG     UIColorFromRGB(0xEFEFEF)  // 背景色


#define kMAINCOLOR_FRONT  UIColorFromRGB(0x47B632)
#define kMAINCOLOR_BLACK  UIColorFromRGB(0x333333)
#define kMAINCOLOR_BLUE   UIColorFromRGB(0x0058B2)

#define kMAINCOLOR_BLACK_A3  UIColorFromRGBA(0x333333, 0.3)




// 默认字体大小
#define FONTSIZE(fs)   [UIFont fontWithName:@"Helvetica" size:fs]
#define SYSFONTSIZE(fs)     [UIFont systemFontOfSize:fs]


/*  文字颜色  */
#define kMLC_TEXTCOLOR_0     UIColorFromRGB(0x000000)
#define kMLC_TEXTCOLOR_3     UIColorFromRGB(0x333333)
#define kMLC_TEXTCOLOR_6     UIColorFromRGB(0x666666)
#define kMLC_TEXTCOLOR_9     UIColorFromRGB(0x999999)
#define kMLC_TEXTCOLOR_C     UIColorFromRGB(0xCCCCCC)
#define kMLC_TEXTCOLOR_F     UIColorFromRGB(0xFFFFFF)  // 白色


/* TableView 分割线 */
#define kMLC_TBV_Line     UIColorFromRGB(0xC8C8CC)




#endif /* ColorDefine_h */
