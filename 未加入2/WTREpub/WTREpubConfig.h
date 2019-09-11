//
//  WTREpubConfig.h
//  WTREpubReader
//
//  Created by wfz on 2017/3/16.
//  Copyright © 2017年 wfz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    
    WTREpubParagNotDefin=0,
    
    WTREpubParagTitle=1200,
    WTREpubParagSubTitle,
    WTREpubParagAuthor,
    WTREpubParagContent,
    WTREpubParagImage,
    WTREpubParagImageTitle,
    
    WTREpubParagHtmlTitle,
    
    WTREpubParagHtmlStyle,
    WTREpubParagHtmlJS,
    
} WTREpubParagraphType;

@interface WTREpubConfig : NSObject<NSCoding>

+(instancetype)shareInstance;

@property (nonatomic,strong) UIFont *titleFont;
@property (nonatomic) CGFloat titleLineSpace;
@property (nonatomic,strong) UIColor *titleColor;

@property (nonatomic,strong) UIFont *authorFont;
@property (nonatomic) CGFloat authorLineSpace;
@property (nonatomic,strong) UIColor *authorColor;

@property (nonatomic,strong) UIFont *subTitleFont;
@property (nonatomic) CGFloat subTitleLineSpace;
@property (nonatomic,strong) UIColor *subTitleColor;

@property (nonatomic,strong) UIFont *contentFont;
@property (nonatomic) CGFloat contentlineSpace;
@property (nonatomic,strong) UIColor *contentColor;

@property (nonatomic,strong) UIFont *imageTitleFont;
@property (nonatomic) CGFloat imageTitlelineSpace;
@property (nonatomic,strong) UIColor *imageTitleColor;


@property (nonatomic,strong) UIColor *themeColor;   //主题颜色

@property(nonatomic,assign)UIEdgeInsets contentEdgeInsets;//内容四周最小间隔
@property(nonatomic,assign)UIEdgeInsets imageEdgeInsets;//图片四周最小间隔



+(NSMutableDictionary *)AttributeTitle;
+(NSMutableDictionary *)AttributeAuthor;
+(NSMutableDictionary *)AttributeSubTitle;
+(NSMutableDictionary *)AttributeContentWithFL:(BOOL)iswf;
+(NSMutableDictionary *)AttributeImageTitle;

@end
