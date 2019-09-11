//
//  WTREpubHtmlFile.h
//  WTREpubReader
//
//  Created by wfz on 2017/3/17.
//  Copyright © 2017年 wfz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WTREpubConfig.h"

//段落
@interface WTREpubParagraph : NSObject

@property(nonatomic,strong)NSAttributedString *attrString;
@property(nonatomic,assign)CFRange visibleRange;

@property(nonatomic,strong)UIImage *image;

@property(nonatomic,assign)CGRect frame; //段落位置

@property(nonatomic,assign)CGFloat topBlankHeight; //段落上面的空白高度
@property(nonatomic,assign)CGFloat bottomBlankHeight; //段落下面的空白高度

@property(nonatomic,assign)int type;// 0: UILabel   1: WTREpubShowLa

@property(nonatomic,assign)WTREpubParagraphType Paragtype;

@end


//页
@interface WTREpubPage : NSObject

@property(nonatomic,assign)NSInteger curintpage;

@property(nonatomic,strong)NSMutableArray <WTREpubParagraph *>* paragraphArray;

-(UIView *)getView;

@end


//html文件
@interface WTREpubHtmlFile : NSObject

@property(nonatomic,assign)NSInteger index;

@property(nonatomic,copy)NSString *filePath;

@property(nonatomic,copy)NSString *htmlid;
@property(nonatomic,copy)NSString *htmltext;//标题 目录

@property(nonatomic,strong)NSMutableArray <WTREpubPage *>*pageArray;

-(void)loaddataIfNotLoad;

-(void)Clearloaddata;

@end
