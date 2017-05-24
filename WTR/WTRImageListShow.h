//
//  WTRImageListShow.h
//  WTRGitCs
//
//  Created by wfz on 2017/5/24.
//  Copyright © 2017年 wfz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface WTRImageListShow : UIView

//imArry 图片链接 Index 选中的图片  tapv 点击的ImageView
+(void)ShowImUrlArray:(NSArray <NSString *>*)imArry selct:(NSInteger) Index tapview:(UIImageView *)tapv;

//imArry 图片数组 Index 选中的图片  tapv 点击的ImageView
+(void)ShowImArray:(NSArray <UIImage *>*)imArry selct:(NSInteger) Index tapview:(UIImageView *)tapv;

@end
