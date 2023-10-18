//
//  WTRHUD.h
//  Created by wfz on 16/6/23.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define WTRHUDScale (1/1.2f) //变小好看点

NS_ASSUME_NONNULL_BEGIN

@interface WTRHUD : NSObject

//自动根据bacView的背景颜色选取背景
//HUD 转圈
+(void)show;
+(void)showHUDInView:(nullable UIView *)bacView;
+(void)showHUDInView:(nullable UIView *)bacView animated:(BOOL)animated transform:(CGAffineTransform)transform;

+(void)showSuccess:(NSString*)status;
+(void)showSuccessInView:(nullable UIView *)bacView WithStatus:(NSString*)status;
+(void)showSuccessInView:(nullable UIView *)bacView WithStatus:(NSString*)status transform:(CGAffineTransform)transform;

+(void)showError:(NSString*)status;
+(void)showErrorInView:(nullable UIView *)bacView WithStatus:(NSString*)status;
+(void)showErrorInView:(nullable UIView *)bacView WithStatus:(NSString*)status transform:(CGAffineTransform)transform;

+(void)showInfo:(NSString*)status;
+(void)showInfoInView:(nullable UIView *)bacView WithStatus:(NSString*)status;
+(void)showInfoInView:(nullable UIView *)bacView WithStatus:(NSString*)status transform:(CGAffineTransform)transform;

+(void)showInfo2:(NSString*)status;
+(void)showInfo2InView:(nullable UIView *)bacView WithStatus:(NSString*)status;
+(void)showInfo2InView:(nullable UIView *)bacView WithStatus:(NSString*)status transform:(CGAffineTransform)transform;

//白背景
+(void)showHUDWInView:(nullable UIView *)bacView;
+(void)showHUDWInView:(nullable UIView *)bacView animated:(BOOL)animated transform:(CGAffineTransform)transform;
+(void)showSuccessWInView:(nullable UIView *)bacView WithStatus:(NSString*)status;
+(void)showErrorWInView:(nullable UIView *)bacView WithStatus:(NSString*)status;
+(void)showInfoWInView:(nullable UIView *)bacView WithStatus:(NSString*)status;
+(void)showInfo2WInView:(nullable UIView *)bacView WithStatus:(NSString*)status;

//黑背景
+(void)showHUDBInView:(nullable UIView *)bacView;
+(void)showHUDBInView:(nullable UIView *)bacView animated:(BOOL)animated transform:(CGAffineTransform)transform;
+(void)showSuccessBInView:(nullable UIView *)bacView WithStatus:(NSString*)status;
+(void)showErrorBInView:(nullable UIView *)bacView WithStatus:(NSString*)status;
+(void)showInfoBInView:(nullable UIView *)bacView WithStatus:(NSString*)status;
+(void)showInfo2BInView:(nullable UIView *)bacView WithStatus:(NSString*)status;

//自定义
+(void)showType:(int)type InView:(nullable UIView *)bacView status:(NSString*)status isWhite:(int)isw transform:(CGAffineTransform)transform;
+(void)showType:(int)type InView:(nullable UIView *)bacView status:(NSString*)status duration:(NSTimeInterval)duration animated:(BOOL)animated isWhite:(int)isw transform:(CGAffineTransform)transform;
+(void)showImage:(UIImage*)image status:(NSString*)status duration:(NSTimeInterval)duration InView:(nullable UIView *)bacView animated:(BOOL)animated isWhite:(int)isw transform:(CGAffineTransform)transform;
+(void)showImage:(nullable UIImage*)image bgColor:(nullable UIColor *)bgColor status:(nullable NSString*)status font:(UIFont *)font tintColor:(nullable UIColor *)tintColor textImageSpace:(CGFloat)textImageSpace boundingRectSize:(CGSize)bsize edge:(UIEdgeInsets)edge cornerRadius:(CGFloat)cornerRadius duration:(NSTimeInterval)duration animated:(BOOL)animated InView:(nullable UIView *)inbacView transform:(CGAffineTransform)transform;
+(void)showHUDInView:(nullable UIView *)inbacView animated:(BOOL)animated isWhite:(int)isw transform:(CGAffineTransform)transform;

//取消
+(void)dismiss;
+(void)dismissInView:(nullable UIView *)bacView;
+(void)dismissInView:(nullable UIView *)bacView animated:(BOOL)animated;



//是否是黑色系的颜色
+(BOOL)isBlackFamilyColor:(UIColor *)incolor;


@end

NS_ASSUME_NONNULL_END
