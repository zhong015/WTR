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
+(void)showHUDWInView:(UIView *)bacView animated:(BOOL)animated;
+(void)showHUDWInView:(UIView *)bacView animated:(BOOL)animated size:(CGSize)size;

//黑背景
+(void)showHUDBInView:(UIView *)bacView;
+(void)showHUDBInView:(UIView *)bacView animated:(BOOL)animated;
+(void)showHUDBInView:(UIView *)bacView animated:(BOOL)animated size:(CGSize)size;

+(void)dismissInView:(UIView *)bacView;
+(void)dismissInView:(UIView *)bacView animated:(BOOL)animated;


@end
