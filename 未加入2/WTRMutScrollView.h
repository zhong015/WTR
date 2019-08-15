//
//  WTRMutScrollView.h
//  CnkiIPhoneClient
//
//  Created by wfz on 2019/6/3.
//  Copyright © 2019 net.cnki.www. All rights reserved.
//

//顶部平均分的多个标题 可以颜色渐变

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WTRMutScrollView : UIView

/*
 titieArray 必须和 cselectColorArray 数量一样

 lineHeight 大于0 时 下面有变颜色的条

leftjiange rightjiange topjiange bottomjiange 为文字显示控件周围的空白
 */
-(void)setTitleArray:(NSArray <NSString *>*)titieArray selectColor:(NSArray <UIColor *>*)cselectColorArray unSelectColor:(UIColor *)cunSelectColor lineHeight:(CGFloat)lineHeight font:(UIFont *)font leftjiange:(CGFloat)leftjiange rightjiange:(CGFloat)rightjiange topjiange:(CGFloat)topjiange bottomjiange:(CGFloat)bottomjiange;

@property(nonatomic,copy) void (^retcb)(NSInteger index);

-(void)setPro:(CGFloat)pro;// 0 ~ 1

@end

NS_ASSUME_NONNULL_END
