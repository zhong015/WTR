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
- (UIImage *)imageCutWithSize:(CGSize)size isAspectFill:(BOOL)isAspectFill opaque:(BOOL)opaque;

- (UIImage *)fixOrientation;//纠正系统相机照出来的图片方向

- (UIImage *)maskImageWithMask:(UIImage *)maskImage;//照片mask提取

- (UIImage *)WTR_imageWithTintColor:(UIColor *)tintColor; //使用一个颜色来代替图片上的所有颜色
- (UIImage *)WTR_imageWithTintColor:(UIColor *)tintColor blendMode:(CGBlendMode)blendMode;
- (UIImage *)WTR_imageWithTintColor:(UIColor *)tintColor blendMode:(CGBlendMode)blendMode alpha:(CGFloat)alpha;

- (UIImage *)WTR_heiBaiTuImg:(UIImage *)img;//黑白背景显示不同图片

+ (UIImage *)imageWithWTRCIImage:(CIImage *)ciimage;

- (CIImage *)WTRCIImage;

- (UIImage *)imagemultiplyByR:(CGFloat)r g:(CGFloat)g b:(CGFloat)b a:(CGFloat)a;//图片像素值乘 对应系数 全写1返回原图片

- (UIImage *)boxblurImageWithBlur:(CGFloat)blur;//模糊

/*
 
 //常用图片模糊 也可以用 [CIFilter filterWithName:@"CIDiscBlur"]; 等
 
 UIColor *tintColor = [UIColor colorWithRed:0  green:0  blue:0 alpha:0.5];
 viewImage=[viewImage applyWBlurWithRadius:20 tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];
 
 */
- (UIImage *)applyWBlurWithRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage;////模糊半径、饱和度、以及可选的掩盖图片

/*
 https://developer.apple.com/library/archive/documentation/GraphicsImaging/Reference/CoreImageFilterReference/index.html#//apple_ref/doc/filter/ci/CIAreaMaximum
 CIAreaMaximum
有时间可以试试  GPU可能会快点 但是不能排除特殊颜色 如黑白

 */
-(UIColor *)mainColorWtr;   //提取图片主要颜色 特殊颜色 (平均值算法)
-(UIColor *)mainColorWtr2;  //最多颜色算法

+(UIColor *)colorHeCheng:(UIColor *)color1 co:(UIColor *)color2;//颜色合成 相当于两个颜色覆盖


+(UIImage *)QRCodeImageWithStr:(NSString *)infoStr size:(CGSize)size;//生成二维码图片
-(NSString *)QRCodeStr;//二维码扫描


@end
