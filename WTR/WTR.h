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

+(BOOL)huishoujianpan;//回收当前监听的键盘


//获取字符串所占区域大小
+(CGSize)getsizeOfStr:(NSString *)str Fontsize:(UIFont *)tyfont Width:(CGFloat )ww;
+(CGSize)getsizeOfStr:(NSString *)str Attributes:(NSDictionary *)attributes Width:(CGFloat )ww;
+(CGSize)getSizeOfStr:(NSAttributedString *)attString Size:(CGSize)size;

+(NSArray *)getPagesAttributedString:(NSAttributedString *)attString size:(CGSize)bbsize;//分页

#pragma mark 日期获取
+ (NSDate *)dateWithISOFormatString:(NSString *)dateString;
+ (NSString *)ISOFormatStringWithDate:(NSDate *)date;
+ (NSDate *)dateWithISOFormatStringZ:(NSString *)dateString;
+ (NSString *)ISOFormatStringZWithDate:(NSDate *)date;

+ (NSString *)timestringof:(NSDate *)date; //时间显示

+ (BOOL)isContainsEmoji:(NSString *)string; //是否包含表情

+ (BOOL)version:(NSString *)_oldver lessthan:(NSString *)_newver;   //版本比较

+ (BOOL)isQQNum:(NSString *)QQNum;
+ (BOOL)isPhoneNum:(NSString *)phoneNum;//验证手机号
+ (BOOL)isEmail:(NSString *)email;
+ (BOOL)isNeedURLEncoding:(NSString *)inurlstr;//是否需要URLEncoding

+ (NSString *)getIPAddress;

+(NSString *)SortedJsonStr:(id)dicOrArr; //得到排序JSON字符串
+(NSString *)CovertLogToJson:(NSString *)inlogstr;//NSLog打印的字符串转换为json


+(void)clearAllCaches; //清除所有缓存
+(unsigned long long)AllCachesSize; //所有缓存大小 Byte
+(unsigned long long)fileSizeAtPath:(NSString*)filePath;    //文件的大小 Byte
+(unsigned long long)folderSizeAtPath:(NSString*)folderPath;//文件夹内文件大小 Byte
+(double)getFreeDiskSize;//设备可用容量 返回单位G
+(double)getTotalDiskSize;//设备总容量 返回单位G


+(UIViewController *)curintViewController;//当前ViewController


//获取数据库一个表的所有数据
+(NSArray *)GetAllDataWithDbPath:(NSString *)path tablename:(NSString *)tablename columnArray:(NSArray <NSString *>*)columnArray;

+(NSString *)numtohanzi:(uint64_t)index;// 数字转汉字 12 -> 十二

//Keychain操作
+(NSData *)readKeychainId:(NSString *)identifier; //读取数据
+(NSData *)readKeychainId:(NSString *)identifier Account:(NSString *)Account Group:(NSString *)Group;
+(BOOL)writeData:(NSData *)data KeychainId:(NSString *)identifier; //写入数据
+(BOOL)writeData:(NSData *)data KeychainId:(NSString *)identifier Account:(NSString *)Account Group:(NSString *)Group;
+(BOOL)deleteKeychainId:(NSString *)identifier; //删除数据
+(BOOL)deleteKeychainId:(NSString *)identifier Account:(NSString *)Account Group:(NSString *)Group;

#pragma mark 验证内购
+(void)verifyReceiptWithData:(NSData *)receiptData isSANDBOX:(BOOL)isSANDBOX completionHandler:(void (^)(NSDictionary * retdic, NSURLResponse * response, NSError * error))completionHandler;

#pragma mark 从数组中随机取连续的几个
+(NSMutableArray *)getSomeObjWithInArr:(NSArray *)yarr num:(NSInteger)num;

#pragma mark 通用html处理-html显示优化
+(NSString *)htmlConvert:(NSString *)html;
#pragma mark 只留html中展示文字，去除所有标签、回车和空白
+(NSString *)jianHuaHtml:(NSString *)html;
#pragma mark 过滤所有标签
+(NSString *)filterAllHTMLTag:(NSString *)html;
#pragma mark 过滤标签和标签内东西
+(NSString *)filterHTML:(NSString *)html biaoqian:(NSString *)biaoqian;
#pragma mark 转意html字符
+(NSString *)htmlzhuanyizifu:(NSString *)html;

#pragma mark 去除空行
+(NSString *)quchukonghang:(NSString *)str;
#pragma mark 去除首行缩进空格回车空行
+(NSString *)quchuShkongge:(NSString *)str;
#pragma mark 去除tagStr后的空白和空行
+(NSString *)quchuKBKH:(NSString *)str tagStr:(NSString *)tagStr;

#pragma mark 给出现文字设置属性
+(void)AddAttributeStr:(NSMutableAttributedString *)allstr   Attributes:(NSDictionary *)atr inStr:(NSString *)str;
#pragma mark 汉字转拼音
+(NSString *)HanZiToPinYin:(NSString *)hanzi;

//规范价格显示
+(NSString *)getPriceStr:(NSString *)inPrice;   //显示2位小数
+(NSString *)getPriceStr2:(NSString *)inPrice;  //有几位小数显示几位，没有不显示

//强制旋转屏幕
+(void)switchNewOrientation:(UIInterfaceOrientation)newOrientation;

@end


@interface NSData (WTRMDJiaMi)

-(NSString *)WTRMD5String;

+(NSData *)WTRfileMD5:(NSString*)path;
+(NSString *)WTRfileMD5String:(NSString *)path;

+(NSData *)WTR_dataWithHexString:(NSString *)hexStr; //十六进制字符串 转data
-(NSString *)WTR_hexString;

@end

@interface NSString (WTRStr)

/*
 WTR_stringByURLEncode
 只适用于值中不需要对 !$&'()*+,;= 加密的，如果值中带有&=什么的特殊符号 （例如 example.com?name=asd&qwe） 其中&不会被Encode

 如果需要真实的URLEncode只能每项拿出来单独stringByURLEncodeReal；
 */
- (NSString*)WTR_stringByURLEncode;
- (NSString*)WTR_stringByURLDecode;
- (NSString*)WTR_stringByURLEncodeReal;
- (NSString*)WTR_stringByURLDecodeReal;

@end
