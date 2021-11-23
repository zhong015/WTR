//
//  WTRHUD.h
//  Created by wfz on 16/6/23.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WTRHUD : NSObject

//自动根据bacView的背景颜色选取背景
+(void)show;
+(void)showSuccess:(NSString*)status;
+(void)showError:(NSString*)status;
+(void)showInfo:(NSString*)status;
+(void)showInfo2:(NSString*)status;
+(void)showHUDInView:(nullable UIView *)bacView;
+(void)showHUDInView:(nullable UIView *)bacView animated:(BOOL)animated size:(CGSize)size;
+(void)showSuccessInView:(nullable UIView *)bacView WithStatus:(NSString*)status;
+(void)showErrorInView:(nullable UIView *)bacView WithStatus:(NSString*)status;
+(void)showInfoInView:(nullable UIView *)bacView WithStatus:(NSString*)status;
+(void)showInfo2InView:(nullable UIView *)bacView WithStatus:(NSString*)status;

//白背景
+(void)showHUDWInView:(nullable UIView *)bacView;
+(void)showHUDWInView:(nullable UIView *)bacView animated:(BOOL)animated size:(CGSize)size;
+(void)showSuccessWInView:(nullable UIView *)bacView WithStatus:(NSString*)status;
+(void)showErrorWInView:(nullable UIView *)bacView WithStatus:(NSString*)status;
+(void)showInfoWInView:(nullable UIView *)bacView WithStatus:(NSString*)status;
+(void)showInfo2WInView:(nullable UIView *)bacView WithStatus:(NSString*)status;

//黑背景
+(void)showHUDBInView:(nullable UIView *)bacView;
+(void)showHUDBInView:(nullable UIView *)bacView animated:(BOOL)animated size:(CGSize)size;
+(void)showSuccessBInView:(nullable UIView *)bacView WithStatus:(NSString*)status;
+(void)showErrorBInView:(nullable UIView *)bacView WithStatus:(NSString*)status;
+(void)showInfoBInView:(nullable UIView *)bacView WithStatus:(NSString*)status;
+(void)showInfo2BInView:(nullable UIView *)bacView WithStatus:(NSString*)status;

//自定义
+(void)showType:(int)type InView:(nullable UIView *)bacView status:(nullable NSString*)status duration:(NSTimeInterval)duration animated:(BOOL)animated isWhite:(int)isw;
+(void)showImage:(nullable UIImage*)image status:(nullable NSString*)status duration:(NSTimeInterval)duration InView:(nullable UIView *)bacView animated:(BOOL)animated isWhite:(int)isw;
+(void)showImage:(nullable UIImage*)image bgColor:(nullable UIColor *)bgColor status:(nullable NSString*)status font:(UIFont *)font tintColor:(nullable UIColor *)tintColor textImageSpace:(CGFloat)textImageSpace boundingRectSize:(CGSize)bsize edge:(UIEdgeInsets)edge cornerRadius:(CGFloat)cornerRadius duration:(NSTimeInterval)duration animated:(BOOL)animated InView:(nullable UIView *)inbacView;

//取消
+(void)dismiss;
+(void)dismissInView:(nullable UIView *)bacView;
+(void)dismissInView:(nullable UIView *)bacView animated:(BOOL)animated;



//是否是黑色系的颜色
+(BOOL)isBlackFamilyColor:(UIColor *)incolor;


@end

NS_ASSUME_NONNULL_END
