//
//  WTRImageListShow.m
//  WTRGitCs
//
//  Created by wfz on 2017/5/24.
//  Copyright © 2017年 wfz. All rights reserved.
//

#import "WTRImageListShow.h"
#import "WTRDefine.h"
#import "UIImageView+WTRLoad.h"

@interface WTRImageListShow ()<UIActionSheetDelegate,UIScrollViewDelegate>

@end

@implementation WTRImageListShow
{
    NSArray *imarr;
    NSInteger index;
    
    UIScrollView *myscrollView;
    
    NSMutableArray *subscorllviewArray;
    
    CGFloat ww,hh;
    
    UIImageView *crutapv;
    CGRect yuanlrect;
    WTRAppDelegate *app;
    
    BOOL ispic;
    
    UIAlertController *actionContr;
    UIImage *curintim;
}
+(void)ShowImArray:(NSArray *)imArry selct:(NSInteger) Index tapview:(UIImageView *)tapv
{
    WTRImageListShow *myvv=[[WTRImageListShow alloc]initWithImOssPathArray:imArry selct:Index tapview:tapv ispic:YES];
    myvv=nil;
}

+(void)ShowImUrlArray:(NSArray *)imArry selct:(NSInteger) Index tapview:(UIImageView *)tapv
{
    WTRImageListShow *myvv=[[WTRImageListShow alloc]initWithImOssPathArray:imArry selct:Index tapview:tapv ispic:NO];
    myvv=nil;
}
-(id)initWithImOssPathArray:(NSArray *)imArry selct:(NSInteger) Index tapview:(UIImageView *)tapv ispic:(BOOL)isp
{
    self=[super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        ispic=isp;
        
        index=Index;
        imarr=imArry;
        crutapv=[[UIImageView alloc]initWithFrame:tapv.frame];
        crutapv.image=tapv.image;
        ww=self.frame.size.width;
        hh=self.frame.size.height;
        self.backgroundColor=[UIColor clearColor];
        crutapv.contentMode=tapv.contentMode;//UIViewContentModeScaleAspectFill;
        
        app=(WTRAppDelegate *)[UIApplication sharedApplication].delegate;
        [app.window addSubview:self];
        
        [self donghua:tapv];
        
        [[UIMenuController sharedMenuController] setMenuVisible:NO animated:NO];
    }
    return self;
}
-(void)donghua:(UIImageView *)tapv
{
    
    CGRect rect=[app.window convertRect:tapv.frame fromView:tapv.superview];
    
    UIImage *img=tapv.image;
    
    CGSize imsize=rect.size;
    if (img) {
        imsize=img.size;
    }
    
    crutapv.frame=CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
    [app.window addSubview:crutapv];
    
    yuanlrect=crutapv.frame;
    
    CGFloat faw=0,fah=0;
    if (imsize.width/imsize.height>ScreenWidthD/ScreenHeightD) {
        if (tapv.image) {
            faw=self.frame.size.width;
            fah=tapv.image.size.height*(faw/tapv.image.size.width);
        }
        else
        {
            faw=self.frame.size.width;
            fah=imsize.height*(faw/imsize.width);
        }
    }
    else
    {
        fah=self.frame.size.height;
        faw=imsize.width*(fah/imsize.height);
    }
    
    self.backgroundColor=[UIColor blackColor];
    self.alpha=0;
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha=0.8;
        crutapv.frame=CGRectMake((ScreenWidthD-faw)/2,(ScreenHeightD-fah)/2, faw, fah);
    }completion:^(BOOL finished) {
        self.alpha=1;
        [self shushihua];
    }];
}
-(void)clearall
{
    [UIView animateWithDuration:0.1 animations:^{
        self.alpha=0;
    }completion:^(BOOL finished) {
        [self removeFromSuperview];
        [[UIMenuController sharedMenuController] setMenuVisible:NO animated:NO];
    }];
    
    if (actionContr) {
        [actionContr dismissViewControllerAnimated:YES completion:nil];
    }
}
-(void)shushihua
{
    [UIView animateWithDuration:0.3 animations:^{
        crutapv.alpha=0;
    }completion:^(BOOL finished) {
        crutapv.hidden=YES;
    }];
    
    myscrollView=[[UIScrollView alloc]initWithFrame:self.frame];
    myscrollView.contentSize=CGSizeMake(ww*imarr.count+1,hh);
    myscrollView.pagingEnabled=YES;
    [self addSubview:myscrollView];
    myscrollView.delegate=self;
    myscrollView.minimumZoomScale=1;
    myscrollView.maximumZoomScale=2;
    
    subscorllviewArray=[NSMutableArray arrayWithCapacity:0];
    
    for (int i=0; i<imarr.count; i++) {
        UIScrollView *conscroll=[[UIScrollView alloc]initWithFrame:CGRectMake(ww*i,0, ww, hh)];
        conscroll.contentSize=CGSizeMake(ww, hh);
        conscroll.delegate=self;
        conscroll.minimumZoomScale=1;
        conscroll.maximumZoomScale=4.5;
        [subscorllviewArray addObject:conscroll];
        
        UIImageView *imv=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, ww, hh)];
        if (index==i) {
            if (ispic) {
                imv.image=[imarr objectAtIndex:index];
            }
            else
            {
                [imv setImageWTRLoadWithURLStr:[imarr objectAtIndex:index]];
                //[imv setImageWithURL:[NSURL URLWithString:[imarr objectAtIndex:index]]]; //也可以用AF 来下载图片
            }
        }
        [myscrollView addSubview:conscroll];
        [conscroll addSubview:imv];
        imv.contentMode=UIViewContentModeScaleAspectFit;
        conscroll.tag=i+10;
        imv.tag=i+10;
        UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imshowqunxiao:)];
        tap.numberOfTapsRequired=1;
        [imv addGestureRecognizer:tap];
        imv.userInteractionEnabled=YES;
        
        UITapGestureRecognizer *tap2=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imshowqunxiao:)];
        tap2.numberOfTapsRequired=2;
        [imv addGestureRecognizer:tap2];
        [tap requireGestureRecognizerToFail:tap2];
        
        //保存
        UILongPressGestureRecognizer *touch = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [imv addGestureRecognizer:touch];
    }
    myscrollView.contentOffset=CGPointMake(ww*index, 0);
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView!=myscrollView) {
        return;
    }
    CGFloat ss= scrollView.contentOffset.x/ww;
    index=roundf(ss);
    
    [self setindesima:index];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView!=myscrollView) {
        return;
    }
    CGFloat ss= scrollView.contentOffset.x/ww;
    if ((ss-index>0.1)&&(ss-index<0.2)) {
        [self setindesima:index+1];
    }
    if ((index-ss>0.1)&&(index-ss<0.2)) {
        [self setindesima:index-1];
    }
}
-(void)setindesima:(NSInteger)inddd
{
    if (subscorllviewArray.count<=inddd||inddd<0) {
        return;
    }
    UIScrollView *curinZoomscrollView=[subscorllviewArray objectAtIndex:inddd];
    for (UIImageView *imv in curinZoomscrollView.subviews) {
        if (imv.tag==inddd+10) {
            if (imv.image) {
                return ;
            }
            if (ispic) {
                imv.image=[imarr objectAtIndex:inddd];
            }
            else{
                [imv setImageWTRLoadWithURLStr:[imarr objectAtIndex:inddd]];
                // [imv setImageWithURL:[NSURL URLWithString:[imarr objectAtIndex:inddd]]];//也可以用AF 来下载图片
            }
            return ;
        }
    }
}
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    if (scrollView==myscrollView) {
        return nil;
    }
    for (UIImageView *imv in scrollView.subviews) {
        if (imv.tag==index+10) {
            return imv;
        }
    }
    return nil;
}
-(void)imshowqunxiao:(UITapGestureRecognizer *)tap
{
    UIScrollView *curinZoomscrollView=[subscorllviewArray objectAtIndex:index];
    if (tap.numberOfTapsRequired==2)
    {
        if (curinZoomscrollView.zoomScale==1) {
            [curinZoomscrollView setZoomScale:2 animated:YES];
        }
        else
        {
            [curinZoomscrollView setZoomScale:1 animated:YES];
        }
        return;
    }
    if (curinZoomscrollView.zoomScale!=1) {
        [curinZoomscrollView setZoomScale:1 animated:YES];
        return;
    }
    [self clearall];
}
#pragma mark 保存图片
-(void)handleTap:(UILongPressGestureRecognizer*) recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        if (!actionContr) {
            actionContr = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            [actionContr addAction:[UIAlertAction actionWithTitle:@"保存到相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                UIImageWriteToSavedPhotosAlbum(curintim, nil, nil,nil);
                [actionContr dismissViewControllerAnimated:YES completion:nil];
            }]];
            [actionContr addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
               [actionContr dismissViewControllerAnimated:YES completion:nil];
            }]];
        }
        UIImageView *imv=(UIImageView *)recognizer.view;
        curintim=imv.image;
        [[WTR curintViewController] presentViewController:actionContr animated:YES completion:nil];
    }
}

@end
