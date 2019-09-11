//
//  WTREpubViewController.h
//  WTREpubReader
//
//  Created by wfz on 2017/3/20.
//  Copyright © 2017年 wfz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WTREpubHtmlFile.h"

@interface WTREpubViewController : UIViewController

@property(nonatomic,copy)NSString *titleName;

@property(nonatomic,assign)NSInteger curintRedingPage,curintRedinghtmlIndex;

@property(nonatomic,strong)NSMutableArray <WTREpubHtmlFile *>*htmlArray;

-(void)jumpnextpage;


@property(nonatomic,copy)NSString *epubpath;//文件路径 用于记录阅读位置

@end
