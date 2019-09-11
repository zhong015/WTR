//
//  WTREpubFooterView.m
//  WTREpubReader
//
//  Created by wfz on 2017/3/21.
//  Copyright © 2017年 wfz. All rights reserved.
//

#import "WTREpubFooterView.h"
#import "WTRPageNumShowrView.h"
#import "WTREpubChapterView.h"
#import "WTREpubConfig.h"
#import "WTRDefine.h"

#define TxtReaderRGB(R, G, B)    [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:1.0]
#define ISIPhoneXTop20 (ISIPhoneX?24:0)

@implementation WTREpubFooterView
{
    UIView *progressTapView;
    
    UIProgressView *progressView;
    UILabel *pagenumla;
    
    NSInteger _totalpage;
    
    //增加章节 跳转
    NSMutableArray *colorBuarray;
}

-(id)initWithFrame:(CGRect)frame
{
    self=[super initWithFrame:frame];
    if (self) {
        [self initui];
    }
    return self;
}
-(void)kongclick
{

}
-(void)initui
{
    UITapGestureRecognizer *tapk=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(kongclick)];
    [self addGestureRecognizer:tapk];
    
    progressView=[[UIProgressView alloc]initWithFrame:CGRectMake(20,20, self.frame.size.width-100,10)];
    [self addSubview:progressView];
    progressView.autoresizingMask=UIViewAutoresizingFlexibleWidth;
    progressView.progress=0.5;
    
    progressTapView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 40)];
    [self addSubview:progressTapView];
    progressTapView.autoresizingMask=UIViewAutoresizingFlexibleWidth;
    

    pagenumla=[[UILabel alloc]initWithFrame:CGRectMake(progressView.right, 0,80, 40-6)];
    pagenumla.textColor=[UIColor colorWithWhite:0.95 alpha:1.0];
    pagenumla.textAlignment=NSTextAlignmentCenter;
    pagenumla.font=[UIFont systemFontOfSize:16];
    [self addSubview:pagenumla];
    pagenumla.autoresizingMask=UIViewAutoresizingFlexibleLeftMargin;

    UIPanGestureRecognizer *pan=[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panMove:)];
    [progressTapView addGestureRecognizer:pan];
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapclick:)];
    [progressTapView addGestureRecognizer:tap];
    
    UIButton *chaptbu=[UIButton new];
    chaptbu.frame=CGRectMake(0, self.height/2.0, 80, self.height/2.0);
    [chaptbu setImage:[UIImage imageNamed:@"reader_cover"] forState:UIControlStateNormal];
    [self addSubview:chaptbu];
    chaptbu.imageEdgeInsets=UIEdgeInsetsMake(0, 0, 0, 15);
    [chaptbu addTarget:self action:@selector(chapterclick) forControlEvents:UIControlEventTouchUpInside];
    
    //背景颜色
    NSArray *colorarr=@[[UIColor whiteColor],TxtReaderRGB(250, 225, 225),TxtReaderRGB(237, 218, 189),[UIColor colorWithRed:0.87 green:0.93 blue:0.84 alpha:1.00],[UIColor blackColor]];
    
    colorBuarray=[NSMutableArray array];
    
    for (int i=0; i<colorarr.count; i++) {
        UIButton *bu=[UIButton new];
        bu.tag=i;
        [colorBuarray addObject:bu];
        bu.backgroundColor=colorarr[i];
        [bu addTarget:self action:@selector(baccolorClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:bu];
    }
    
    UIStepper *stpv=[[UIStepper alloc] initWithFrame:CGRectMake(self.width-120, self.height-40-ISIPhoneXTop20, 100, 40)];
    [self addSubview:stpv];
    stpv.tintColor=[UIColor whiteColor];
    stpv.autoresizingMask=UIViewAutoresizingFlexibleLeftMargin;
    
    stpv.maximumValue=50;
    stpv.minimumValue=8;
    stpv.value=[WTREpubConfig shareInstance].contentFont.pointSize;
    [stpv addTarget:self action:@selector(fontchange:) forControlEvents:UIControlEventValueChanged];
    
}
-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat buw=35;
    CGFloat jiange=(ScreenWidth-buw*colorBuarray.count-20*2)/(colorBuarray.count+1);
    for (int i=0; i<colorBuarray.count; i++) {
        UIButton *bu=colorBuarray[i];
        bu.frame=CGRectMake(20+jiange+(buw+jiange)*i, progressTapView.bottom+5, buw, buw);
    }
}

-(void)chapterclick
{
    if (self.retChapterShow) {
        self.retChapterShow();
    }
}
-(void)panMove:(UIPanGestureRecognizer *)pan
{
    CGPoint po=[pan locationInView:pan.view];
    [self selectlocation:po];
}
-(void)tapclick:(UITapGestureRecognizer *)tap
{
    CGPoint po=[tap locationInView:tap.view];
    [self selectlocation:po];
}
-(void)selectlocation:(CGPoint)po
{
    CGFloat pro=(po.x-progressView.x)/progressView.width;
    if (pro<0) {
        pro=0;
    }
    if (pro>1) {
        pro=1;
    }
    progressView.progress=pro;
    if (_totalpage) {
        NSInteger curpage=_totalpage*pro;
        if (curpage<0) {
            curpage=0;
        }
        if (curpage>_totalpage-1) {
            curpage=_totalpage-1;
        }
        [self setcurPage:curpage totalPage:_totalpage isSetproui:NO];
        if (self.retpageCb) {
            self.retpageCb(curpage);
        }
    }
}

-(void)setcurPage:(NSInteger)curpage totalPage:(NSInteger)totalpage
{
    [self setcurPage:curpage totalPage:totalpage isSetproui:YES];
}
-(void)setcurPage:(NSInteger)curpage totalPage:(NSInteger)totalpage isSetproui:(BOOL)isset
{
    _totalpage=totalpage;
    if (isset) {
        progressView.progress=(curpage+1)*1.0/totalpage;
    }
    pagenumla.text=[NSString stringWithFormat:@"%ld",curpage+1];
    [WTRPageNumShowrView showCurintPage:curpage TotalPage:totalpage toview:self.superview Bottom:self.height+26];
}
#pragma mark 背景更新
-(void)baccolorClick:(UIButton *)bu
{
    [WTREpubConfig shareInstance].themeColor=bu.backgroundColor;
    UIColor *textcolor;
    
    if (bu.tag==1) {
        textcolor=TxtReaderRGB(147, 83, 93);
    }
    else if (bu.tag==2) {
        textcolor=TxtReaderRGB(78, 59, 46);
    }
    else if (bu.tag==3) {
        textcolor=[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.00];
    }
    else if (bu.tag==4) {
        textcolor=[UIColor colorWithRed:0.46 green:0.46 blue:0.46 alpha:1.00];
    }
    else
        textcolor=[UIColor blackColor];
    
    [WTREpubConfig shareInstance].titleColor=textcolor;
    [WTREpubConfig shareInstance].subTitleColor=textcolor;
    [WTREpubConfig shareInstance].authorColor=textcolor;
    [WTREpubConfig shareInstance].contentColor=textcolor;
    [WTREpubConfig shareInstance].imageTitleColor=textcolor;
    if (self.retupdataShow) {
        self.retupdataShow();
    }
}
-(void)fontchange:(UIStepper *)stp
{
    CGFloat jbz=(stp.value>22)?2.5:1.5;
    
    [WTREpubConfig shareInstance].titleFont=WJIACUZITI(stp.value+3*jbz);
    [WTREpubConfig shareInstance].subTitleFont=WJIACUZITI(stp.value+jbz);
    [WTREpubConfig shareInstance].authorFont=[UIFont systemFontOfSize:stp.value-1.5*jbz];
    [WTREpubConfig shareInstance].contentFont=[UIFont systemFontOfSize:stp.value];
    [WTREpubConfig shareInstance].imageTitleFont=[UIFont systemFontOfSize:stp.value-2*jbz];
    if (self.retupdataShow) {
        self.retupdataShow();
    }
}

@end
