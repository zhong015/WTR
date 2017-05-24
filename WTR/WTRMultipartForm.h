//
//  WTRMultipartForm.h
//  ZJY
//
//  Created by wfz on 2017/4/28.
//  Copyright © 2017年 wfz. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
    自定义表单上传 multipart/form-data;
 */

@interface OnePartForm : NSObject

@property(nonatomic,copy)NSString *name;        //必须
@property(nonatomic,copy)NSString *filename;    //非必需
@property(nonatomic,copy)NSString *mimeType;    //非必需

@property(nonatomic,strong)NSData *data;        //必须


+(OnePartForm *)FormWithName:(NSString *)name string:(NSString *)string;
+(OnePartForm *)FormWithName:(NSString *)name data:(NSData *)data;
+(OnePartForm *)FormWithName:(NSString *)name filename:(NSString *)filename mimeType:(NSString *)mimeType data:(NSData *)data;


@end

@interface WTRMultipartForm : NSObject

/*
    multipart/form-data 上传
 */
+(NSMutableURLRequest *)urlRequestWithUrlStr:(NSString *)urlStr partList:(NSArray <OnePartForm *>*)partArray;



@end
