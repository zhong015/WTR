//
//  WTRBaseDefine.h
//  WTRGitCs
//
//  Created by wfz on 2017/5/24.
//  Copyright © 2017年 wfz. All rights reserved.
//

#ifndef WTRBaseDefine_h
#define WTRBaseDefine_h

#ifdef __OBJC__
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#import "WTR.h"
#import "UIView+WTRFrame.h"
#import "WTRFilePath.h"

#define ScreenWidth  ([UIApplication sharedApplication].delegate.window.bounds.size.width)
#define ScreenHeight  ([UIApplication sharedApplication].delegate.window.bounds.size.height)
#define ScreenBounds  ([UIApplication sharedApplication].delegate.window.bounds)

// 是否iPad
#define ISPadWTR ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)

#define ISIPhoneX (^(void){if(@available(iOS 11.0, *)){return (([UIApplication sharedApplication].delegate.window.safeAreaInsets.top>41)||[UIApplication sharedApplication].delegate.window.safeAreaInsets.left>41||[UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom>41||[UIApplication sharedApplication].delegate.window.safeAreaInsets.right>41);}else{return 0;}}())

//IOS8后 旋转屏幕 ScreenWidth与ScreenHeight会调换 下面是绝对的
#define ScreenWidthD ((ScreenWidth<ScreenHeight)?ScreenWidth:ScreenHeight)
#define ScreenHeightD ((ScreenWidth>ScreenHeight)?ScreenWidth:ScreenHeight)

#define WTRSafeTop (^(void){if(ISIPhoneX){if (@available(iOS 11.0, *)) {return [UIApplication sharedApplication].delegate.window.safeAreaInsets.top;}else{ return (CGFloat)20.0;}}else{return (CGFloat)20.0;}}())
#define WTRSafeLeft (^(void){if(ISIPhoneX){if (@available(iOS 11.0, *)) {return [UIApplication sharedApplication].delegate.window.safeAreaInsets.left;}else{ return (CGFloat)0.0;}}else{return (CGFloat)0.0;}}())
#define WTRSafeBottom (^(void){if(ISIPhoneX){if (@available(iOS 11.0, *)) {return [UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom;}else{ return (CGFloat)0.0;}}else{return (CGFloat)0.0;}}())
#define WTRSafeRight (^(void){if(ISIPhoneX){if (@available(iOS 11.0, *)) {return [UIApplication sharedApplication].delegate.window.safeAreaInsets.right;}else{ return (CGFloat)0.0;}}else{return (CGFloat)0.0;}}())

//判断类型
#define ISString(str) (str&&[str isKindOfClass:[NSString class]]&&str.length>0)
#define ISNumberStr(str) (str&&([str isKindOfClass:[NSString class]]||[str isKindOfClass:[NSNumber class]]))
#define ISArray(arr) (arr&&[arr isKindOfClass:[NSArray class]])
#define ISDictionary(dic) (dic&&[dic isKindOfClass:[NSDictionary class]])

//只返回字符串
#define SafeStr(str) ((str&&[str isKindOfClass:[NSString class]])?(NSString *)str:([str isKindOfClass:[NSNumber class]]?((NSNumber*)str).stringValue:@""))

//颜色
#define RANDOMF (arc4random()%1000/1000.0)
#define RANDCOLOR [UIColor colorWithRed:RANDOMF green:RANDOMF blue:RANDOMF alpha:1] //变幻颜色

#define UIColorFromRGB(rgbValue) [UIColor                    \
colorWithRed: ((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 \
green: ((float)((rgbValue & 0xFF00) >> 8)) / 255.0           \
blue: ((float)(rgbValue & 0xFF)) / 255.0 alpha : 1.0]

#define UIColorFromRGB0x(rgbValue) [UIColor \
colorWithRed:((float)((0x##rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((0x##rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(0x##rgbValue & 0xFF))/255.0 alpha:1.0]

#define UIColorFromRGB_A(rgbValue,a) [UIColor \
colorWithRed: ((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 \
green: ((float)((rgbValue & 0xFF00) >> 8)) / 255.0           \
blue: ((float)(rgbValue & 0xFF)) / 255.0 alpha : a]


//创造圆角
#define LayerMakeCorner(view,radius) {(view).layer.cornerRadius=(radius);(view).layer.masksToBounds=YES;}
#define LayerMakeBorder(view,_borderWidth,_borderColor) {(view).layer.borderWidth=(_borderWidth);(view).layer.borderColor=(_borderColor);}
#define LayerMakeCB(view,radius,_borderWidth,_borderColor) {LayerMakeCorner(view,radius);LayerMakeBorder(view,_borderWidth,_borderColor);}

#define __WEAKSelf __weak typeof(self) weakSelf = self;

//字体
#define WJIACUZITI(x) [UIFont fontWithName:@"Helvetica-Bold" size:x] //加粗字体

//自定义手势返回
#define WGESTUREPUSH {self.navigationController.interactivePopGestureRecognizer.enabled = YES;self.navigationController.interactivePopGestureRecognizer.delegate = nil;}

#endif


#endif /* WTRBaseDefine_h */
