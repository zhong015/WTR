//
//  WCTLabel.h
//  CnkiIPhoneClient
//
//  Created by wfz on 2023/9/22.
//  Copyright © 2023 net.cnki.www. All rights reserved.
//

//CoreText文本 支持自动约束 支持定位点击文字位置

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

NS_ASSUME_NONNULL_BEGIN

@interface WCTLabel : UIView

@property(nonatomic,copy,nullable)NSAttributedString *attributedText;

@property(nonatomic,assign)UIEdgeInsets contentInsets;

//点击事件，如使用textIndex需注意越界情况
@property(nonatomic,strong,nullable)void (^tapClick)(WCTLabel *la,CGPoint po,NSInteger textIndex);


/*
 由显示位置得到字符串位置
 返回值：-1:未找到 0-文字长度：找到位置 最大值为文字长度值 标记超越情况
 */
-(NSInteger)indexWithTapPoint:(CGPoint)po;

//由字符串位置位置得到显示文字的左上角点位置
-(CGPoint)pointWithIndex:(NSInteger)index;

//当前显示的长度
-(CFRange)getVisibleRange;


+(CGSize)sizeWithAttrStr:(NSAttributedString *)atr maxSize:(CGSize)maxSize contentInsets:(UIEdgeInsets)contentInsets;

@end

NS_ASSUME_NONNULL_END
