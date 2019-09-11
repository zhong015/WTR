//
//  WTREpubChapterView.m
//  PDFTXTREADER
//
//  Created by wfz on 2017/3/27.
//  Copyright © 2017年 wfz. All rights reserved.
//

#define KDBILICPT 1.8  //显示宽度是屏幕的几分之一

#import "WTREpubChapterView.h"
#import "WTREpubHtmlFile.h"
#import "WTRDefine.h"

@interface WTREpubChapterView ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong)NSArray *dataArray;

@property(nonatomic,strong)UITableView *tableView;

@property(nonatomic,assign)NSInteger curintSelect;

@property(nonatomic,copy)void (^retcb)(NSInteger index);

@end


@implementation WTREpubChapterView
{
    UIView *tapview;
}
+(void)ShowCurintChapterInView:(UIView *)fview withHtmlFileArray:(NSArray *)fileArray curintIndex:(NSInteger) index SelectCb:(void (^)(NSInteger index))cb;
{
    WTREpubChapterView *chapview=[[WTREpubChapterView alloc]initWithFrame:fview.bounds];
    [fview addSubview:chapview];
    chapview.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    chapview.dataArray=fileArray;
    chapview.curintSelect=index;
    chapview.retcb=cb;
    [chapview performSelector:@selector(scrollvvv) withObject:nil afterDelay:0.1];
    
    [fview.gestureRecognizers enumerateObjectsUsingBlock:^(__kindof UIGestureRecognizer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.enabled=NO;
    }];
}
-(void)scrollvvv
{
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.curintSelect inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
}
-(id)initWithFrame:(CGRect)frame
{
    self=[super initWithFrame:frame];
    if (self) {
        [self loadui];
    }
    return self;
}
-(void)loadui
{
    tapview=[[UIView alloc]initWithFrame:CGRectMake(self.width/KDBILICPT, 0,self.width-self.width/KDBILICPT, self.height)];
    [self addSubview:tapview];
    
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismisview)];
    UISwipeGestureRecognizer *swip=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(dismisview)];
    swip.direction=UISwipeGestureRecognizerDirectionLeft;
    [tapview addGestureRecognizer:tap];
    [self addGestureRecognizer:swip];
    
    self.tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0,self.width/KDBILICPT, self.height) style:UITableViewStylePlain];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    [self addSubview:self.tableView];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    
    self.tableView.frame=CGRectMake(-self.width/KDBILICPT, 0, self.width/KDBILICPT, self.height);
    [UIView animateWithDuration:0.25 animations:^{
        self.tableView.frame=CGRectMake(0, 0, self.width/KDBILICPT, self.height);
    }];
}
-(void)layoutSubviews
{
    [super layoutSubviews];
    self.tableView.frame=CGRectMake(0, 0, self.width/KDBILICPT, self.height);
    tapview.frame=CGRectMake(self.width/KDBILICPT, 0,self.width-self.width/KDBILICPT, self.height);
}
-(void)dismisview
{
    [self.superview.gestureRecognizers enumerateObjectsUsingBlock:^(__kindof UIGestureRecognizer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.enabled=YES;
    }];
    [UIView animateWithDuration:0.25 animations:^{
        self.tableView.frame=CGRectMake(-self.width/KDBILICPT, 0, self.width/KDBILICPT, self.height);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    WTREpubHtmlFile *file=[self.dataArray objectAtIndex:indexPath.row];
    
    cell.textLabel.text=file.htmltext;
    
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    
    if (indexPath.row==self.curintSelect) {
        cell.backgroundColor=[UIColor grayColor];
    }
    else
        cell.backgroundColor=[UIColor whiteColor];
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.retcb) {
        self.retcb(indexPath.row);
    }
    [self dismisview];
}

@end
