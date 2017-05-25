//
//  WTRHUD.m
//  CnkiIPadHD
//
//  Created by wfz on 16/6/23.
//  Copyright © 2016年 cnki. All rights reserved.
//

#import "WTRHUD.h"
#import "SVIndefiniteAnimatedView2.h"

#define WTRHUDW 100.0  //默认大小
#define WTRHUDH 100.0

@implementation WTRHUD

+(void)showHUDWInView:(UIView *)bacView
{
    [self showHUDWInView:bacView animated:YES];
}
+(void)showHUDWInView:(UIView *)bacView animated:(BOOL)animated
{
    [self showHUDInView:bacView animated:animated IsWhite:YES size:CGSizeMake(WTRHUDW, WTRHUDH)];
}
+(void)showHUDWInView:(UIView *)bacView animated:(BOOL)animated size:(CGSize)size
{
    [self showHUDInView:bacView animated:animated IsWhite:YES size:size];
}


+(void)showHUDBInView:(UIView *)bacView
{
    [self showHUDBInView:bacView animated:YES];
}
+(void)showHUDBInView:(UIView *)bacView animated:(BOOL)animated
{
    [self showHUDInView:bacView animated:animated IsWhite:NO size:CGSizeMake(WTRHUDW, WTRHUDH)];
}
+(void)showHUDBInView:(UIView *)bacView animated:(BOOL)animated size:(CGSize)size
{
    [self showHUDInView:bacView animated:animated IsWhite:NO size:size];
}


+(void)showHUDInView:(UIView *)bacView animated:(BOOL)animated IsWhite:(BOOL)isw size:(CGSize)size
{
    if (!bacView) {
        return;
    }
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        for (UIView *vv in bacView.subviews) {
            if ([vv isKindOfClass:[SVIndefiniteAnimatedView2 class]]) {
                [vv removeFromSuperview];
            }
        }
        
        SVIndefiniteAnimatedView2 * svv=[[SVIndefiniteAnimatedView2 alloc]initWithFrame:CGRectMake((bacView.bounds.size.width-size.width)/2.0,(bacView.bounds.size.height-size.height)/2.0, size.width, size.height)];
        svv.strokeThickness=2.0;
        svv.radius=24.0;
        svv.layer.cornerRadius=14.0;
        [bacView addSubview:svv];
        svv.autoresizingMask=UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
        
        if (isw) {
            svv.strokeColor=[UIColor blackColor];
            svv.backgroundColor=[UIColor whiteColor];
        }
        else
        {
            svv.strokeColor=[UIColor whiteColor];
            svv.backgroundColor=[UIColor colorWithWhite:0.4 alpha:1];//[UIColor blackColor];
        }
        
        if (ABS(size.width-WTRHUDW)>10) {
            svv.radius=24.0/WTRHUDW*size.width;
            svv.layer.cornerRadius=14.0/WTRHUDW*size.width;
        }
        
        if (animated) {
            svv.alpha=0.0;
            [UIView animateWithDuration:0.15 animations:^{
                svv.alpha=1.0;
            }];
        }
    }];
}

+(void)dismissInView:(UIView *)bacView
{
    [self dismissInView:bacView animated:YES];
}
+(void)dismissInView:(UIView *)bacView animated:(BOOL)animated
{
    if (!bacView) {
        return;
    }
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{

        SVIndefiniteAnimatedView2 * svv=nil;
        for (UIView *vv in bacView.subviews) {
            if ([vv isKindOfClass:[SVIndefiniteAnimatedView2 class]]) {
                svv=(SVIndefiniteAnimatedView2 *)vv;
                break;
            }
        }
        if (!svv) {
            return;
        }
        if (animated) {
            [UIView animateWithDuration:0.15 animations:^{
                svv.alpha=0.0;
            } completion:^(BOOL finished) {
                [svv removeFromSuperview];
            }];
        }
        else
            [svv removeFromSuperview];
    }];
}


@end
