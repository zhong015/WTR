//
//  UIImageView+WTRLoad.h
//
//  Created by wfz on 16/9/13.
//  Copyright © 2016年 wfz. All rights reserved.


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIImageView (WTRLoad)

//加载图片，先加载缓存图片，isneedcheck:是否之后比较服务器图片的大小，不一样就重新下载
- (void)WTR_setImageWithURLStr:(NSString *)imageURLStr isNeedcheck:(BOOL)isneedcheck;
- (void)WTR_setImageWithURLStr:(NSString *)imageURLStr placeholder:(UIImage *)placeholder isNeedcheck:(BOOL)isneedcheck;


//取消当前加载的图片 后台也会取消当前图片加载，别的地方如果有相同的图片添加到后台也不会加载出来
- (void)WTR_cancelCurintImageLoad;

//清除某一张图片缓存
+(void)WTR_clearImageCacheWithURLStr:(NSString *)imageURLStr;

+(void)WTR_clearAllMemCache;

@end
