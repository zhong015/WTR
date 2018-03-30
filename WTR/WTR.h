//
//  WTR.h
//  WTRGitCs
//
//  Created by wfz on 2017/5/24.
//  Copyright © 2017年 wfz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface WTR : NSObject


/*
    自动调整键盘弹起时textfiledOrTextView的高度
 
    .layer.masksToBounds=YES;//键盘弹起，切掉超出部分
 */
+(void)addKeyboardTransform:(UIView <UIKeyInput>*)textfiledOrTextView TransView:(UIView *)view;//监听键盘高度 自动调整view
+(void)addKeyboardTransform:(UIView <UIKeyInput>*)textfiledOrTextView TransView:(UIView *)view addHeight:(CGFloat )adh; //adh 多增加的高度

+(void)removeKeyboardTransform:(UIView <UIKeyInput>*)textfiledOrTextView; //移除监听

+(void)huishoujianpan;//回收当前监听的键盘


//获取字符串所占区域大小
+(CGSize)getsizeOfStr:(NSString *)str Fontsize:(UIFont *)tyfont Width:(CGFloat )ww;
+(CGSize)getsizeOfStr:(NSString *)str Attributes:(NSDictionary *)attributes Width:(CGFloat )ww;
+(CGSize)getSizeOfStr:(NSAttributedString *)attString Size:(CGSize)size;

+(NSArray *)getPagesAttributedString:(NSAttributedString *)attString size:(CGSize)bbsize;//分页

+ (NSDate *)dateWithISOFormatString:(NSString *)dateString;
+ (NSDate *)dateWithISOFormatStringZ:(NSString *)dateString;

+ (NSString *)timestringof:(NSDate *)date; //时间显示

+ (BOOL)isContainsEmoji:(NSString *)string; //是否包含表情

+ (BOOL)version:(NSString *)_oldver lessthan:(NSString *)_newver;   //版本比较

+ (BOOL)isQQNum:(NSString *)QQNum;
+ (BOOL)isPhoneNum:(NSString *)phoneNum;//验证手机号
+ (BOOL)isEmail:(NSString *)email;
+ (BOOL)isNeedURLEncoding:(NSString *)inurlstr;//是否需要URLEncoding

+ (NSString *)getIPAddress;

+ (CGFloat)getFileSize:(NSString *)path; //此方法可以获取文件的大小，返回的是单位是M。

+(void)clearAllCaches; //清除所有缓存
+(NSString *)AllCachesSize; //所有缓存大小


+(UIViewController *)curintViewController;//当前ViewController

//获取数据库一个表的所有数据
+(NSArray *)GetAllDataWithDbPath:(NSString *)path tablename:(NSString *)tablename columnArray:(NSArray <NSString *>*)columnArray;

@end


@interface NSData (WTRMDJiaMi)

-(NSString *)md5jiami;

@end

