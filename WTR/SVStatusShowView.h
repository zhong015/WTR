//
//  SVStatusShowView.h
//  WTRGitCs
//
//  Created by wfz on 2019/7/5.
//  Copyright © 2019 wfz. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SVStatusShowView : UIVisualEffectView

-(instancetype)initWithImage:(nullable UIImage*)image estyle:(UIBlurEffectStyle)estyle status:(nullable NSString*)status font:(UIFont *)font tintColor:(UIColor *)tintColor textImageSpace:(CGFloat)textImageSpace boundingRectSize:(CGSize)bsize edge:(UIEdgeInsets)edge cornerRadius:(CGFloat)cornerRadius;

-(void)dismissWithAnimated:(NSNumber *)animatedNum;

@end

NS_ASSUME_NONNULL_END
