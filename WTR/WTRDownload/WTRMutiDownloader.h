//
//  WTRMutiDownloader.h
//  CnkiIPhoneClient
//
//  Created by wfz on 2017/4/7.
//  Copyright © 2017年 net.cnki.www. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
/*
    一个大文件 分多次下载
 */

@interface WTRMutiDownloader : NSObject

+(CGFloat)getProgressWithTagStr:(NSString *)tagstr;

+(void)downloadWithReq:(NSURLRequest *)request tagStr:(NSString *)tagstr TotalRange:(long long)total completionHandler:(void (^)(NSData * filedata,NSString *tagstr, NSError * error))completionHandler;

@end
