//
//  UIImageView+WTRLoad.h
//  asdasd
//
//  Created by wfz on 16/9/13.
//  Copyright © 2016年 wfz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIImageView (WTRLoad)

- (void)setImageWTRLoadWithURLStr:(NSString *)imageURLStr;  //加载图片，先加载本地缓存图片，然后比较服务器图片的大小，不一样就重新下载
- (void)setImagWTRLoadeWithURLStr:(NSString *)imageURLStr placeholder:(UIImage *)placeholder;

- (void)CancelWTRLoadCurintImageLoad;//取消当前加载的图片 后台也会取消当前图片加载，别的地方如果有相同的图片添加到后台也不会加载出来

+(void)clearImageWTRLoadCacheWithURLStr:(NSString *)imageURLStr;//清楚某一张图片缓存

@end
