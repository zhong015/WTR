//
//  WTRImageCutView.m
//  WTRGitCs
//
//  Created by wfz on 2018/1/18.
//  Copyright © 2018年 wfz. All rights reserved.
//

#import "WTRImageCutView.h"
#import "WTRBaseDefine.h"

@interface WTRImageCutView ()<UIScrollViewDelegate>

@property(nonatomic,strong)UIScrollView *scrollView;

@property(nonatomic,strong)UIImageView *imv;

@property(nonatomic,strong)UIView *coverv;

@end

@implementation WTRImageCutView

-(void)setSourceImage:(UIImage *)sourceImage
{
    _sourceImage=sourceImage;
    
    for (UIView *vv in self.subviews) {
        [vv removeFromSuperview];
    }
    
    [self loadui];
}

-(void)loadui
{
    self.scrollView=[[UIScrollView alloc] initWithFrame:self.bounds];
    self.scrollView.delegate=self;
    [self addSubview:self.scrollView];
    self.scrollView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    if (@available(iOS 11.0, *)) {
        self.scrollView.contentInsetAdjustmentBehavior=UIScrollViewContentInsetAdjustmentNever;
    }
    
    self.scrollView.alwaysBounceVertical=YES;
    self.scrollView.alwaysBounceHorizontal=YES;
    
    self.scrollView.maximumZoomScale=4.5;
    self.scrollView.minimumZoomScale=1.0;
    
    CGFloat scrollbili=self.scrollView.width/self.scrollView.height;
    
    CGFloat sourcebili=self.sourceImage.size.width/self.sourceImage.size.height;
    
    if (sourcebili>=scrollbili) {
        CGFloat iww=self.width-20;;
        CGFloat ihh=iww/sourcebili;
        self.imv=[[UIImageView alloc] initWithFrame:CGRectMake(0,0, iww, ihh)];
        
        self.scrollView.contentSize=self.imv.size;
        self.scrollView.contentInset=UIEdgeInsetsMake((self.scrollView.height-ihh)/2.0,10, (self.scrollView.height-ihh)/2.0, 10);
        
    }else{
        CGFloat ihh=self.scrollView.height-20;
        CGFloat iww=ihh*sourcebili;
        self.imv=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, iww, ihh)];
        
        self.scrollView.contentSize=self.imv.size;
        self.scrollView.contentInset=UIEdgeInsetsMake(10,(self.scrollView.width-iww)/2.0, 10,(self.scrollView.width-iww)/2.0);
    }
    
    self.imv.image=self.sourceImage;
    //    self.imv.contentMode=UIViewContentModeScaleAspectFit;
    [self.scrollView addSubview:self.imv];
    //    self.imv.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.imv.backgroundColor=RANDCOLOR;
    
    
    CGFloat bili=self.cutToSize.width/self.cutToSize.height;
    
    if (bili>=sourcebili) {
        
        CGFloat ww=self.imv.width;
        CGFloat hh=ww/bili;
        
        self.coverv=[[UIView alloc] initWithFrame:CGRectMake(self.scrollView.contentInset.left, (self.height-hh)/2.0, ww, hh)];
        
        //再赋值一次 转换到剪切的位置
        self.scrollView.contentInset=UIEdgeInsetsMake(self.coverv.y,self.scrollView.contentInset.left, self.scrollView.height-self.coverv.bottom, self.scrollView.contentInset.right);
        
    }else{
        CGFloat hh=self.imv.height;
        CGFloat ww=hh*bili;
        self.coverv=[[UIView alloc] initWithFrame:CGRectMake((self.width-ww)/2.0,self.scrollView.contentInset.top, ww, hh)];
        
        //再赋值一次 转换到剪切的位置
        self.scrollView.contentInset=UIEdgeInsetsMake(self.scrollView.contentInset.top,self.coverv.x, self.scrollView.contentInset.bottom, self.scrollView.width-self.coverv.right);
    }
    
    [self addSubview:self.coverv];
    self.coverv.userInteractionEnabled=NO;
    self.coverv.backgroundColor=[UIColor clearColor];
    LayerMakeBorder(self.coverv, 1, [UIColor whiteColor].CGColor);
}

-(void)quedinglclick
{
    CGPoint ydpo=CGPointMake(self.scrollView.contentOffset.x+self.scrollView.contentInset.left, self.scrollView.contentOffset.y+self.scrollView.contentInset.top);
    if (ydpo.x<0) {
        ydpo.x=0;
    }
    if (ydpo.y<0) {
        ydpo.y=0;
    }
    
    NSLog(@"yd:%.2f,%.2f",ydpo.x,ydpo.y);
    
    NSLog(@"im:%.2f,%.2f",self.imv.width,self.imv.height);
    
    NSLog(@"Scale:%.2f\n\n",self.scrollView.zoomScale);
    
    CGSize imNowSize=CGSizeMake(self.imv.width, self.imv.height);
    
    CGRect cutrect=CGRectMake(ydpo.x, ydpo.y, self.coverv.width, self.coverv.height);
    
    CGFloat bili=self.coverv.width/self.cutToSize.width;
    
    imNowSize=CGSizeMake(self.imv.width/bili, self.imv.height/bili);
    cutrect=CGRectMake(ydpo.x/bili, ydpo.y/bili, self.coverv.width/bili, self.coverv.height/bili);
    
    UIGraphicsBeginImageContext(self.cutToSize);
    
    [self.sourceImage drawInRect:CGRectMake(-cutrect.origin.x,-cutrect.origin.y,imNowSize.width,imNowSize.height)];
    
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if (self.retcb) {
        self.retcb(viewImage);
    }
}

- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imv;
}
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view atScale:(CGFloat)scale
{
    NSLog(@"%.2f",view.width);
}

@end
