//
//  WTRHUD.h
//  Created by wfz on 16/6/23.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WTRHUD : NSObject

//自动根据bacView的背景颜色选取背景
+(void)showHUDInView:(UIView *)bacView;
+(void)showHUDInView:(UIView *)bacView animated:(BOOL)animated size:(CGSize)size;
+(void)showSuccessInView:(UIView *)bacView WithStatus:(NSString*)status;
+(void)showErrorInView:(UIView *)bacView WithStatus:(NSString*)status;
+(void)showInfoInView:(UIView *)bacView WithStatus:(NSString*)status;
+(void)showInfo2InView:(UIView *)bacView WithStatus:(NSString*)status;

//白背景
+(void)showHUDWInView:(UIView *)bacView;
+(void)showHUDWInView:(UIView *)bacView animated:(BOOL)animated size:(CGSize)size;
+(void)showSuccessWInView:(UIView *)bacView WithStatus:(NSString*)status;
+(void)showErrorWInView:(UIView *)bacView WithStatus:(NSString*)status;
+(void)showInfoWInView:(UIView *)bacView WithStatus:(NSString*)status;
+(void)showInfo2WInView:(UIView *)bacView WithStatus:(NSString*)status;

//黑背景
+(void)showHUDBInView:(UIView *)bacView;
+(void)showHUDBInView:(UIView *)bacView animated:(BOOL)animated size:(CGSize)size;
+(void)showSuccessBInView:(UIView *)bacView WithStatus:(NSString*)status;
+(void)showErrorBInView:(UIView *)bacView WithStatus:(NSString*)status;
+(void)showInfoBInView:(UIView *)bacView WithStatus:(NSString*)status;
+(void)showInfo2BInView:(UIView *)bacView WithStatus:(NSString*)status;

//自定义
+(void)showType:(int)type InView:(UIView *)bacView status:(nullable NSString*)status duration:(NSTimeInterval)duration animated:(BOOL)animated IsWhite:(BOOL)isw;
+(void)showImage:(nullable UIImage*)image status:(nullable NSString*)status duration:(NSTimeInterval)duration InView:(UIView *)bacView animated:(BOOL)animated IsWhite:(BOOL)isw;
+(void)showImage:(nullable UIImage*)image estyle:(UIBlurEffectStyle)estyle status:(nullable NSString*)status font:(UIFont *)font tintColor:(UIColor *)tintColor textImageSpace:(CGFloat)textImageSpace boundingRectSize:(CGSize)bsize edge:(UIEdgeInsets)edge cornerRadius:(CGFloat)cornerRadius duration:(NSTimeInterval)duration animated:(BOOL)animated InView:(UIView *)bacView;

//取消
+(void)dismissInView:(UIView *)bacView;
+(void)dismissInView:(UIView *)bacView animated:(BOOL)animated;



//是否是黑色系的颜色
+(BOOL)isBlackFamilyColor:(UIColor *)incolor;


@end

NS_ASSUME_NONNULL_END
