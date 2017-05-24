//
//  WTRZX.h
//  PocketUniversity
//
//  Created by wangfuzhong on 15/7/16.
//  Copyright (c) 2015年 CY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface WTRZX : NSObject

//.layer.masksToBounds=YES;//键盘弹起，切掉超出部分
+(void)addKeyboardTransform:(UIView *)textfiledOrTextView TransView:(UIView *)view;//监听键盘高度 自动调整view
+(void)removeKeyboardTransform:(UIView *)textfiledOrTextView; //移除监听

+(void)huishoujianpan;//回收监听的键盘

//获取字符串所占区域大小
+(CGSize)getsizeOfStr:(NSString *)str Fontsize:(UIFont *)tyfont Width:(CGFloat )ww;
+(CGSize)getsizeOfStr:(NSString *)str Attributes:(NSDictionary *)attributes Width:(CGFloat )ww;

+(NSArray *)getPagesAttributedString:(NSAttributedString *)attString size:(CGSize)bbsize;//分页

+ (NSString *)timestringof:(NSDate *)date; //时间显示

+ (BOOL)isContainsEmoji:(NSString *)string; //是否包含表情

+ (BOOL)version:(NSString *)_oldver lessthan:(NSString *)_newver;   //版本比较

+ (BOOL)isQQNum:(NSString *)QQNum;
+ (BOOL)isPhoneNum:(NSString *)phoneNum;//验证手机号
+ (BOOL)isEmail:(NSString *)email;

+ (NSString *)getIPAddress; //获得ipv4的IP 如果是ipv6网络返回error  或者 [ipstr hasPrefix:@"169.254."]


+ (CGFloat)getFileSize:(NSString *)path; //此方法可以获取文件的大小，返回的是单位是M。

+(void)clearAllCaches; //清除所有缓存
+(NSString *)AllCachesSize; //所有缓存大小

@end
