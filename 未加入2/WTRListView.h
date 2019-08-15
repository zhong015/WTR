//
//  WTRListView.h
//  CnkiIPhoneClient
//
//  Created by wfz on 2018/12/26.
//  Copyright © 2018 net.cnki.www. All rights reserved.
//

#import <UIKit/UIKit.h>

//内容自定义显示


@interface WTRListModel : NSObject

//公用属性
@property(nonatomic)UIEdgeInsets contentInset; //默认 UIEdgeInsetsZero

//下面属性只能有一组有值

//文字段
@property(nonatomic,copy)NSString *content;
@property(nonatomic,strong)UIFont *font;
@property(nonatomic,strong)UIColor *color;
@property(nonatomic,assign)CGFloat lineSpacing;

@property(nonatomic,copy)NSAttributedString *contentAttr;//这两组只赋值一个就行

@property(nonatomic)NSTextAlignment textAlignment;
@property(nonatomic,assign)CGFloat limitHeight;     //最高限制高度  默认-1

//内部使用
@property(nonatomic,assign)CGFloat contentHeight;   //已经计算过的高度

//图片
@property(nonatomic,copy)NSURL *imgUrl;
@property(nonatomic,assign)CGFloat imgBili;//图片宽高比
@property(nonatomic,strong)UIImage *placeholderImage;

//一行图片
@property(nonatomic,strong)NSArray <WTRListModel *>* imageModelArray;
@property(nonatomic,assign)CGFloat imgSpacing;
@property(nonatomic,assign)CGFloat imArraybili;//图片宽高比

//视频
@property(nonatomic,copy)NSURL *videoUrl;
@property(nonatomic,copy)NSURL *videoImgUrl;
@property(nonatomic,assign)CGFloat videoBili;
@property(nonatomic,assign)CGFloat videoTime;//视频时长 秒

@end

@interface WTRListView : UIView

+(CGFloat)heightWithList:(NSArray <WTRListModel *>*)arr width:(CGFloat)width;

+(WTRListView *)ViewWithList:(NSArray <WTRListModel *>*)arr width:(CGFloat)width;

@end

