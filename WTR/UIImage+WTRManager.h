//
//  UIImage+WTRManager.h
//  WTRGitCs
//
//  Created by wfz on 2017/5/24.
//  Copyright © 2017年 wfz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIImage (WTRManager)

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

- (UIImage *)imageCutWith:(CGSize)size;//改变分辨率 透明部分变白
- (UIImage *)imageCutNoOpaqueWith:(CGSize)size;//改变分辨率 透明部分透明

- (UIImage *)fixOrientation;//纠正系统相机照出来的图片方向

- (UIImage*)maskImageWithMask:(UIImage *)maskImage;//照片mask提取

+ (UIImage *)imageWithWTRCIImage:(CIImage *)ciimage;

- (CIImage *)WTRCIImage;

-(UIImage *)imagemultiplyByR:(CGFloat)r g:(CGFloat)g b:(CGFloat)b a:(CGFloat)a;//图片像素值乘 对应系数 全写1返回原图片

- (UIImage *)boxblurImageWithBlur:(CGFloat)blur;//模糊

/*
 
 //常用图片模糊 也可以用 [CIFilter filterWithName:@"CIDiscBlur"]; 等
 
 UIColor *tintColor = [UIColor colorWithRed:0  green:0  blue:0 alpha:0.5];
 viewImage=[viewImage applyWBlurWithRadius:20 tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];
 
 */
- (UIImage *)applyWBlurWithRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage;////模糊半径、饱和度、以及可选的掩盖图片


@end
