//
//  WTRWebUrlPro.h
//  Created by wfz on 2019/7/12.

#import <Foundation/Foundation.h>

/*
 //    [NSURLProtocol registerClass:[WTRWebUrlPro class]];
 //    [WTRWebUrlPro zhuce];

 //    [NSURLProtocol unregisterClass:[WTRWebUrlPro class]];
 //    [WTRWebUrlPro quxiao];
 */
//监听的Scheme 只对这个做缓存（使用系统[NSURLCache sharedURLCache]）
#define WTRWebUrlProScheme @"wtrhttp"

NS_ASSUME_NONNULL_BEGIN

@interface WTRWebUrlPro : NSURLProtocol

+(void)zhuce;
+(void)quxiao;

@end

NS_ASSUME_NONNULL_END
