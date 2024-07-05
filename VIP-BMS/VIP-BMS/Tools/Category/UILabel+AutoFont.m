//
//  UILabel+AutoFont.m
//  GRMToolBox
//
//  Created by _G.R.M. on 2019/11/8.
//  Copyright © 2019年 _G.R.M. All rights reserved.
//

#import "UILabel+AutoFont.h"
#import "objc/runtime.h"
#import "Utils.h"

@implementation UILabel (AutoFont)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method oriMethod = class_getInstanceMethod(self.class, @selector(setText:));
        Method cusMethod = class_getInstanceMethod(self.class, @selector(setTextHooked:));
        // 判断自定义的方法是否实现, 避免崩溃
        BOOL addSuccess = class_addMethod(self.class, @selector(setText:), method_getImplementation(cusMethod), method_getTypeEncoding(cusMethod));
        if (addSuccess) {
            // 没有实现, 将源方法的实现替换到自定义方法的实现
            class_replaceMethod(self.class, @selector(setTextHooked:), method_getImplementation(oriMethod), method_getTypeEncoding(oriMethod));
        } else {
            // 已经实现, 直接交换方法
            method_exchangeImplementations(oriMethod, cusMethod);
        }
        
        Method oriMethod1 = class_getInstanceMethod(self.class, @selector(setAttributedText:));
        Method cusMethod1 = class_getInstanceMethod(self.class, @selector(setAttributedTextHooked:));
        // 判断自定义的方法是否实现, 避免崩溃
        BOOL addSuccess1 = class_addMethod(self.class, @selector(setAttributedText:), method_getImplementation(cusMethod1), method_getTypeEncoding(cusMethod1));
        if (addSuccess1) {
            // 没有实现, 将源方法的实现替换到自定义方法的实现
            class_replaceMethod(self.class, @selector(setAttributedTextHooked:), method_getImplementation(oriMethod1), method_getTypeEncoding(oriMethod1));
        } else {
            // 已经实现, 直接交换方法
            method_exchangeImplementations(oriMethod1, cusMethod1);
        }
    });
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    if (self.attributedText.length) {
        self.attributedText = self.attributedText;
    }
    else {
        self.text = self.text;
    }
    
}

- (void)setTextHooked:(NSString *)text {
    
    [self setTextHooked:text];
    
    UIFont *font = self.font;
    if ([font.fontName rangeOfString:@"Bold"].location != NSNotFound) {
        self.font = [Utils font_Lato_B:font.pointSize];
    }
    else {
        self.font = [Utils font_Lato_R:font.pointSize];
    }
    
}

- (void)setAttributedTextHooked:(NSAttributedString *)attributedString {
  
    NSMutableAttributedString *mAttString = [[NSMutableAttributedString alloc] initWithAttributedString:attributedString];
    
    WEAKSELF(self);
    [attributedString enumerateAttribute:NSFontAttributeName inRange:NSMakeRange(0, attributedString.length) options:NSAttributedStringEnumerationReverse usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
        STRONGSELF(self);
        
        UIFont *font = value ? value : self.font;
        UIFont *newFont = nil;
        if ([font.fontName rangeOfString:@"Bold"].location != NSNotFound) {
            newFont = [Utils font_Lato_B:font.pointSize];
        }
        else {
            newFont = [Utils font_Lato_R:font.pointSize];
        }
        
        [mAttString addAttribute:NSFontAttributeName value:newFont range:range];
        
        if (range.location == 0) {
            [self setAttributedTextHooked:mAttString];
            [self setNeedsUpdateConstraints];
        }
        
    }];
}

@end

