//
//  WTRHUD.m
//  CnkiIPadHD
//
//  Created by wfz on 16/6/23.
//  Copyright © 2016年 cnki. All rights reserved.
//

#import "WTRHUD.h"
#import "SVIndefiniteAnimatedView2.h"
#import "SVStatusShowView.h"

#define WTRHUDW 100.0  //默认大小
#define WTRHUDH 100.0

#define WTRHUDMinimumDismissTime 2  //最小显示时间
#define WTRHUDMaximumDismissTime 7 //最大显示时间

@implementation WTRHUD

#pragma mark HUD部分
+(void)showHUDWInView:(UIView *)bacView
{
    [self showHUDWInView:bacView animated:YES size:CGSizeMake(WTRHUDW, WTRHUDH)];
}
+(void)showHUDWInView:(UIView *)bacView animated:(BOOL)animated size:(CGSize)size
{
    [self showHUDInView:bacView animated:animated IsWhite:YES size:size];
}

+(void)showHUDBInView:(UIView *)bacView
{
    [self showHUDBInView:bacView animated:YES size:CGSizeMake(WTRHUDW, WTRHUDH)];
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
            if ([vv isKindOfClass:[SVIndefiniteAnimatedView2 class]]||[vv isKindOfClass:[SVStatusShowView class]]) {
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


#pragma mark Status部分
+ (void)showSuccessWInView:(UIView *)bacView WithStatus:(NSString*)status
{
    [self showType:0 InView:bacView status:status IsWhite:YES];
}
+ (void)showErrorWInView:(UIView *)bacView WithStatus:(NSString*)status
{
    [self showType:1 InView:bacView status:status IsWhite:YES];
}
+ (void)showInfoWInView:(UIView *)bacView WithStatus:(NSString*)status
{
    [self showType:-1 InView:bacView status:status IsWhite:YES];
}
+ (void)showInfo2WInView:(UIView *)bacView WithStatus:(NSString*)status
{
    [self showType:2 InView:bacView status:status IsWhite:YES];
}
+ (void)showSuccessBInView:(UIView *)bacView WithStatus:(NSString*)status
{
    [self showType:0 InView:bacView status:status IsWhite:NO];
}
+ (void)showErrorBInView:(UIView *)bacView WithStatus:(NSString*)status
{
    [self showType:1 InView:bacView status:status IsWhite:NO];
}
+ (void)showInfoBInView:(UIView *)bacView WithStatus:(NSString*)status
{
    [self showType:-1 InView:bacView status:status IsWhite:NO];
}
+ (void)showInfo2BInView:(UIView *)bacView WithStatus:(NSString*)status
{
    [self showType:2 InView:bacView status:status IsWhite:NO];
}
+ (void)showType:(int)type InView:(UIView *)bacView status:(NSString*)status IsWhite:(BOOL)isw
{
    if (!status||![status isKindOfClass:[NSString class]]) {
        status=@"";
    }
    CGFloat minimum = MAX(status.length * 0.06 + 0.5,WTRHUDMinimumDismissTime);
    minimum=MIN(minimum, WTRHUDMaximumDismissTime);

    [self showType:type InView:bacView status:status duration:minimum animated:YES IsWhite:isw];
}
+ (void)showType:(int)type InView:(UIView *)bacView status:(NSString*)status duration:(NSTimeInterval)duration animated:(BOOL)animated IsWhite:(BOOL)isw
{
    NSBundle *bundle = [NSBundle bundleForClass:NSClassFromString(@"WTR")];
    NSURL *url = [bundle URLForResource:@"WTRBundle" withExtension:@"bundle"];
    NSBundle *imageBundle = [NSBundle bundleWithURL:url];

    UIImage *image=nil;
    switch (type) {
        case 0:
        {
            image = [UIImage imageWithContentsOfFile:[imageBundle pathForResource:@"success" ofType:@"png"]];
        }
            break;
        case 1:
        {
            image = [UIImage imageWithContentsOfFile:[imageBundle pathForResource:@"error" ofType:@"png"]];
        }
            break;
        case 2:
        {
             image = [UIImage imageWithContentsOfFile:[imageBundle pathForResource:@"info" ofType:@"png"]];
        }
            break;
        default:
            image = nil;
            break;
    }

    [self showImage:image status:status duration:duration InView:bacView animated:animated IsWhite:isw];
}

+(void)showImage:(UIImage*)image status:(NSString*)status duration:(NSTimeInterval)duration InView:(UIView *)bacView animated:(BOOL)animated IsWhite:(BOOL)isw;
{
    UIColor *tintColor;
    if (isw) {
        tintColor=[UIColor blackColor];
    }else{
        tintColor=[UIColor whiteColor];
    }

    [self showImage:image estyle:(isw?UIBlurEffectStyleExtraLight:UIBlurEffectStyleDark) status:status font:[UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline] tintColor:tintColor textImageSpace:8 boundingRectSize:CGSizeMake(200.0f, 300.0f) edge:UIEdgeInsetsMake(12, 12, 12, 12) cornerRadius:(image?14.0:5.0) duration:duration animated:animated InView:bacView];
}
+(void)showImage:(nullable UIImage*)image estyle:(UIBlurEffectStyle)estyle status:(nullable NSString*)status font:(UIFont *)font tintColor:(UIColor *)tintColor textImageSpace:(CGFloat)textImageSpace boundingRectSize:(CGSize)bsize edge:(UIEdgeInsets)edge cornerRadius:(CGFloat)cornerRadius duration:(NSTimeInterval)duration animated:(BOOL)animated InView:(UIView *)bacView
{
    if (!bacView) {
        return;
    }
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{

        for (UIView *vv in bacView.subviews) {
            if ([vv isKindOfClass:[SVIndefiniteAnimatedView2 class]]||[vv isKindOfClass:[SVStatusShowView class]]) {
                [vv removeFromSuperview];
            }
        }

        SVStatusShowView * svv=[[SVStatusShowView alloc]initWithImage:image estyle:estyle status:status font:font tintColor:tintColor textImageSpace:textImageSpace boundingRectSize:bsize edge:edge cornerRadius:cornerRadius];

        [bacView addSubview:svv];
        svv.center=CGPointMake(bacView.frame.size.width/2.0, bacView.frame.size.height/2.0);
        svv.autoresizingMask=UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;

        if (animated) {
            svv.alpha=0.0;
            [UIView animateWithDuration:0.15 animations:^{
                svv.alpha=1.0;
            } completion:^(BOOL finished) {
                [svv performSelector:@selector(dismissWithAnimated:) withObject:@(animated) afterDelay:duration];
            }];
        }else{
            [svv performSelector:@selector(dismissWithAnimated:) withObject:@(animated) afterDelay:duration];
        }
    }];
}

#pragma mark 取消
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

        UIView * svv=nil;
        for (UIView *vv in bacView.subviews) {
            if ([vv isKindOfClass:[SVIndefiniteAnimatedView2 class]]||[vv isKindOfClass:[SVStatusShowView class]]) {
                svv=vv;
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
