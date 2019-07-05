//
//  WTRHUD.h
//  CnkiIPadHD
//
//  Created by wfz on 16/6/23.
//  Copyright © 2016年 cnki. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface WTRHUD : NSObject

//白背景
+(void)showHUDWInView:(UIView *)bacView;
+(void)showHUDWInView:(UIView *)bacView animated:(BOOL)animated size:(CGSize)size;
+(void)showSuccessWInView:(UIView *)bacView WithStatus:(NSString*)status;
+(void)showErrorWInView:(UIView *)bacView WithStatus:(NSString*)status;
+(void)showInfoWInView:(UIView *)bacView WithStatus:(NSString*)status;

//黑背景
+(void)showHUDBInView:(UIView *)bacView;
+(void)showHUDBInView:(UIView *)bacView animated:(BOOL)animated size:(CGSize)size;
+(void)showSuccessBInView:(UIView *)bacView WithStatus:(NSString*)status;
+(void)showErrorBInView:(UIView *)bacView WithStatus:(NSString*)status;
+(void)showInfoBInView:(UIView *)bacView WithStatus:(NSString*)status;

//自定义
+(void)showType:(int)type InView:(UIView *)bacView status:(NSString*)status duration:(NSTimeInterval)duration animated:(BOOL)animated IsWhite:(BOOL)isw;
+(void)showImage:(UIImage*)image status:(NSString*)status duration:(NSTimeInterval)duration InView:(UIView *)bacView animated:(BOOL)animated IsWhite:(BOOL)isw;

//取消
+(void)dismissInView:(UIView *)bacView;
+(void)dismissInView:(UIView *)bacView animated:(BOOL)animated;


@end
