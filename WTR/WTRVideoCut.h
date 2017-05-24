//
//  WTRVideoCut.h
//  LivePhoto
//
//  Created by wfz on 2017/5/3.
//  Copyright © 2017年 wfz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WTRVideoCut : NSObject

/*
 
 start duration : 0 ~ 1
 
 outputpath: 后缀为 .mp4 最后生成mp4文件
 
 
 也可以根据内部代码 变为视频拼接程序 中间可以自定义转换动画 也可以加水印
 
 */
+(void)cutVideoWithPath:(NSString *)movPath outputPath:(NSString *)outputpath start:(float)start duration:(float)duration Completion:(void (^)(BOOL iss))cb;

@end
