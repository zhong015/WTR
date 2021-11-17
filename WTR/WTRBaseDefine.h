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

#define WTRSafeTop (^(void){if (@available(iOS 11.0, *)) {return [UIApplication sharedApplication].delegate.window.safeAreaInsets.top;}else{ return (CGFloat)20.0;}}())
#define WTRSafeLeft (^(void){if (@available(iOS 11.0, *)) {return [UIApplication sharedApplication].delegate.window.safeAreaInsets.left;}else{ return (CGFloat)0.0;}}())
#define WTRSafeBottom (^(void){if (@available(iOS 11.0, *)) {return [UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom;}else{ return (CGFloat)0.0;}}())
#define WTRSafeRight (^(void){if (@available(iOS 11.0, *)) {return [UIApplication sharedApplication].delegate.window.safeAreaInsets.right;}else{ return (CGFloat)0.0;}}())

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

//动态动画CGRect中间位置
#define WTRCGRectPro(wtr_yframe,wtr_tframe,wtr_pro) (^(CGRect ylf,CGRect tof,CGFloat cp){return CGRectMake((tof.origin.x-ylf.origin.x)*cp+ylf.origin.x, (tof.origin.y-ylf.origin.y)*cp+ylf.origin.y, (tof.size.width-ylf.size.width)*cp+ylf.size.width, (tof.size.height-ylf.size.height)*cp+ylf.size.height);}(wtr_yframe,wtr_tframe,wtr_pro))

//动态动画UIColor中间位置
#define WTRUIColorPro(wtr_ycolor,wtr_tcolor,wtr_pro) (^(UIColor *color1,UIColor *color2,CGFloat pro){CGFloat c1r,c1g,c1b,c1a,c2r,c2g,c2b,c2a;[color1 getRed:&c1r green:&c1g blue:&c1b alpha:&c1a];[color2 getRed:&c2r green:&c2g blue:&c2b alpha:&c2a];return [UIColor colorWithRed:(c2r-c1r)*pro+c1r green:(c2g-c1g)*pro+c1g blue:(c2b-c1b)*pro+c1b alpha:(c2a-c1a)*pro+c1a];}(wtr_ycolor,wtr_tcolor,wtr_pro))

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
