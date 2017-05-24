//
//  WTRDefine.h
//  WTRGitCs
//
//  Created by wfz on 2017/5/23.
//  Copyright © 2017年 wfz. All rights reserved.
//

#ifndef WTRDefine_h
#define WTRDefine_h

#ifndef DEBUG

#define NSLog(...) {}

#endif

#ifdef __OBJC__
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "WTRAppDelegate.h"
#import "WTRZX.h"


#define ISIOS8 ([UIDevice currentDevice].systemVersion.floatValue>=8.0)
#define ISIOS9 ([UIDevice currentDevice].systemVersion.floatValue>=9.0)
#define ISIOS10 ([UIDevice currentDevice].systemVersion.floatValue>=10.0)
#define ScreenWidth  (((WTRAppDelegate *)[UIApplication sharedApplication].delegate).window.bounds.size.width)
#define ScreenHeight  (((WTRAppDelegate *)[UIApplication sharedApplication].delegate).window.bounds.size.height)

// 是否iPad
#define isPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

//IOS8后 旋转屏幕 ScreenWidth与ScreenHeight会调换 下面是绝对的
#define ScreenWidthD (([UIScreen mainScreen].bounds.size.width<[UIScreen mainScreen].bounds.size.height)?[UIScreen mainScreen].bounds.size.width:[UIScreen mainScreen].bounds.size.height)
#define ScreenHeightD (([UIScreen mainScreen].bounds.size.width>[UIScreen mainScreen].bounds.size.height)?[UIScreen mainScreen].bounds.size.width:[UIScreen mainScreen].bounds.size.height)

//颜色
#define RANDOMF (arc4random()%1000/1000.0)
#define RANDCOLOR [UIColor colorWithRed:RANDOMF green:RANDOMF blue:RANDOMF alpha:1] //变幻颜色

#define UIColorFromRGB(rgbValue) [UIColor                    \
colorWithRed: ((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 \
green: ((float)((rgbValue & 0xFF00) >> 8)) / 255.0           \
blue: ((float)(rgbValue & 0xFF)) / 255.0 alpha : 1.0]

//创造圆角
#define LayerMakeCorner(view,radius) {(view).layer.cornerRadius=(radius);(view).layer.masksToBounds=YES;}
#define LayerMakeBorder(view,_borderWidth,_borderColor) {(view).layer.borderWidth=(_borderWidth);(view).layer.borderColor=(_borderColor);}
#define LayerMakeCB(view,radius,_borderWidth,_borderColor) {LayerMakeCorner(view,radius);LayerMakeBorder(view,_borderWidth,_borderColor);}

//判断是不是字符串 并且长度大于0
#define ISString(str) (str&&[str isKindOfClass:[NSString class]]&&str.length>0)
#define ISNumberStr(str) (str&&([str isKindOfClass:[NSString class]]||[str isKindOfClass:[NSNumber class]]))
#define ISArray(arr) (arr&&[arr isKindOfClass:[NSArray class]])


#define __WEAKSelf __weak typeof(self) weakSelf = self;

//字体
#define WJIACUZITI(x) [UIFont fontWithName:@"Helvetica-Bold" size:x] //加粗字体


#endif

#endif /* Define_h */
