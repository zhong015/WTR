//
//  WTREpubViewController.m
//  WTREpubReader
//
//  Created by wfz on 2017/3/20.
//  Copyright © 2017年 wfz. All rights reserved.
//

#import "WTREpubViewController.h"
#import "WTREpubPageViewController.h"
#import "WTREpubHeaderView.h"
#import "WTREpubFooterView.h"
#import "WTREpubChapterView.h"
#import "WTREpubShareData.h"
#import "WTRPageView.h"
#import "WTREpubConfig.h"
#import "WTRDefine.h"

#define WTREpubHeaderHight (ISIPhoneX?64.0f+20:64.0f)
#define WTREpubFooterHight (ISIPhoneX?(64+50+20)+30:(64+50+20))

@interface WTREpubViewController ()<WTRPageViewDataSource>

@property(nonatomic,strong)WTRPageView *pagevc;

@property(nonatomic,strong)WTREpubFooterView *footerView;
@property(nonatomic,strong)WTREpubHeaderView *headView;


@end

@implementation WTREpubViewController
{
//    BOOL _isspeak;
}
//-(BOOL)prefersStatusBarHidden
//{
//    return YES;
//}
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
#pragma mark 返回
-(void)backBuClick
{
    if (self.navigationController&&self.navigationController.viewControllers.count>1) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if(self.navigationController)
    {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
    else
        [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[WTREpubConfig shareInstance].themeColor;
    
    [self updatesizhoujuli];
    
//    _isspeak=NO;

    if (self.epubpath) {

//        历史记录
//        NSString *epubpathLast=[ShareSetingData baseKeyWithPath:self.epubpath];
//
//        NSString *indexstr=[[WTREpubShareData shareInstence] objectStrForKey:[epubpathLast stringByAppendingString:@"indexstr"]];
//        NSString *pagestr=[[WTREpubShareData shareInstence] objectStrForKey:[epubpathLast stringByAppendingString:@"pagestr"]];
//        if (pagestr&&indexstr) {
//            _curintRedinghtmlIndex=indexstr.integerValue;
//            _curintRedingPage=pagestr.integerValue;
//        }else{
            _curintRedinghtmlIndex=0;
            _curintRedingPage=0;
//        }
    }
    else
    {
        _curintRedinghtmlIndex=0;
        _curintRedingPage=0;
    }
    
    self.pagevc=[[WTRPageView alloc] initWithFrame:self.view.bounds];//[[UIPageViewController alloc]initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    self.pagevc.delegate=self;
    [self.view addSubview:self.pagevc];
    self.pagevc.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
   
    WTREpubPageViewController *firstv=[self getWTREpubPageViewControllerWithHtmlIndex:_curintRedinghtmlIndex page:_curintRedingPage];
    if (!firstv) {
        _curintRedinghtmlIndex=0;
        _curintRedingPage=0;
        firstv=[self getWTREpubPageViewControllerWithHtmlIndex:_curintRedinghtmlIndex page:_curintRedingPage];
        if (!firstv) {
            [self performSelector:@selector(backBuClick) withObject:nil afterDelay:0.2];
            return;
        }
    }
    [self.pagevc setViewController:firstv];
//    self.pagevc.transitionStyle=[ShareSetingData shareInstence].fanyemoshi;

    [self loadheadView];
    [self loadfootrView];
    
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapClick)];
    [self.view addGestureRecognizer:tap];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(configAudioSession) name:ConfigAudioSessionNotification object:nil];
}
-(void)configAudioSession
{
//    self.pagevc.transitionStyle=[ShareSetingData shareInstence].fanyemoshi;
}
#pragma mark 控制条动画
-(void)showHeaderFooterView
{
    if (![self isHeaderShow]) {
        [UIView animateWithDuration:0.3 animations:^{
            self.headView.frame=CGRectMake(0,0, ScreenWidth, WTREpubHeaderHight);
            self.footerView.frame=CGRectMake(0, ScreenHeight-WTREpubFooterHight, ScreenWidth, WTREpubFooterHight);
        }];
    }
}
-(void)hideHeaderFooterView
{
    if ([self isHeaderShow]) {
        [UIView animateWithDuration:0.3 animations:^{
            self.headView.frame=CGRectMake(0,-WTREpubHeaderHight, ScreenWidth, WTREpubHeaderHight);
            self.footerView.frame=CGRectMake(0, ScreenHeight, ScreenWidth, WTREpubFooterHight);
        }];
    }
}
-(BOOL)isHeaderShow
{
    if (self.headView.frame.origin.y>-0.1) {
        return YES;
    }
    return NO;
}
-(void)tapClick
{
    if ([self isHeaderShow]) {
        [self hideHeaderFooterView];
    }
    else
        [self showHeaderFooterView];
}
- (void)pageViewControllerFiledaction:(WTRPageView *_Nonnull)pageViewController
{
    [self tapClick];
}
-(WTREpubPageViewController *)getWTREpubPageViewControllerWithHtmlIndex:(NSInteger )htmlindex page:(NSInteger)page
{
    if (htmlindex<0) {
        htmlindex=0;
    }
    if (htmlindex>=self.htmlArray.count) {
        return nil;
    }
    
    WTREpubHtmlFile *file=[self.htmlArray objectAtIndex:htmlindex];
    [file loaddataIfNotLoad];
    if (file.pageArray.count==0) {
        return nil;
    }
    if (page<0) {
        page=0;
    }
    if (page>=file.pageArray.count) {
        page=file.pageArray.count-1;
    }
    WTREpubPageViewController *pagevc=[[WTREpubPageViewController alloc]init];
    pagevc.epubpage=[file.pageArray objectAtIndex:page];
    pagevc.htmlfile=file;
    return pagevc;
}
- (nullable UIViewController *)pageViewController:(WTRPageView *_Nonnull)pageView viewControllerBeforeViewController:(UIViewController *_Nonnull)viewController
{
    WTREpubPageViewController *epubViewController=(WTREpubPageViewController *)viewController;
    if (epubViewController.epubpage.curintpage==0) {
        NSInteger htmlindex=epubViewController.htmlfile.index-1;
        if (htmlindex<0||htmlindex>=self.htmlArray.count) {
            return nil;
        }
        WTREpubHtmlFile *file=[self.htmlArray objectAtIndex:htmlindex];
        return [self getWTREpubPageViewControllerWithHtmlIndex:htmlindex page:file.pageArray.count-1];
    }else
    {
        return [self getWTREpubPageViewControllerWithHtmlIndex:epubViewController.htmlfile.index page:epubViewController.epubpage.curintpage-1];
    }
}
- (nullable UIViewController *)pageViewController:(WTRPageView *_Nonnull)pageView viewControllerAfterViewController:(UIViewController *_Nonnull)viewController
{
    WTREpubPageViewController *epubViewController=(WTREpubPageViewController *)viewController;
    if (epubViewController.epubpage.curintpage>=epubViewController.htmlfile.pageArray.count-1) {
        NSInteger htmlindex=epubViewController.htmlfile.index+1;
        if (htmlindex<0||htmlindex>=self.htmlArray.count) {
            return nil;
        }
        return [self getWTREpubPageViewControllerWithHtmlIndex:htmlindex page:0];
    }else
    {
        return [self getWTREpubPageViewControllerWithHtmlIndex:epubViewController.htmlfile.index page:epubViewController.epubpage.curintpage+1];
    }
}
- (void)pageViewController:(WTRPageView *_Nonnull)pageViewController didTransitionTo:(UIViewController *_Nonnull)viewController;
{
    WTREpubPageViewController *epubpageViewController=(WTREpubPageViewController *)viewController;
    if ([epubpageViewController isKindOfClass:[WTREpubPageViewController class]]) {
        _curintRedingPage=epubpageViewController.epubpage.curintpage;
        _curintRedinghtmlIndex=epubpageViewController.htmlfile.index;
        
        [self.footerView setcurPage:_curintRedingPage totalPage:epubpageViewController.htmlfile.pageArray.count];
    }
    
    if (self.epubpath) {
//        存记录
//        NSString *epubpathLast=[ShareSetingData baseKeyWithPath:self.epubpath];

//        [[WTREpubShareData shareInstence] setObjectStr:[NSString stringWithFormat:@"%ld",_curintRedinghtmlIndex] forKey:[epubpathLast stringByAppendingString:@"indexstr"]];
//        [[WTREpubShareData shareInstence] setObjectStr:[NSString stringWithFormat:@"%ld",_curintRedingPage] forKey:[epubpathLast stringByAppendingString:@"pagestr"]];

    }
    
//    if (_isspeak) {
//        _isspeak=NO;
////        [self.headView startSpeakCurintpageifneed];
//    }
}
-(void)loadheadView
{
    self.headView=[[WTREpubHeaderView alloc]initWithFrame:CGRectMake(0,0, ScreenWidth, WTREpubHeaderHight)];
    self.headView.autoresizingMask=UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.headView];
    self.headView.backgroundColor=[UIColor colorWithWhite:0 alpha:0.8];
    self.headView.epubViewController=self;
    
    UIButton * backButton=[UIButton new];
    [self.headView addSubview:backButton];
    backButton.frame=CGRectMake(0, WTREpubHeaderHight-44, 80, 44);
    [backButton setImage:[UIImage imageNamed:@"newreturntr"] forState:UIControlStateNormal];
    backButton.imageEdgeInsets=UIEdgeInsetsMake(0, 0, 0, 30);
    [backButton addTarget:self action:@selector(backBuClick) forControlEvents:UIControlEventTouchUpInside];
    
    if (self.titleName) {
        UILabel *la=[[UILabel alloc]initWithFrame:CGRectMake(50, WTREpubHeaderHight-44,self.headView.width-100, 44)];
        if (isPad) {
            la.font=[UIFont systemFontOfSize:18];
        }
        else
            la.font=[UIFont systemFontOfSize:16];
        
        la.textAlignment=NSTextAlignmentCenter;
        la.textColor=[UIColor whiteColor];
        [self.headView addSubview:la];
        la.autoresizingMask=UIViewAutoresizingFlexibleWidth;
        la.text=self.titleName;
        la.backgroundColor=[UIColor clearColor];
    }
}
-(void)loadfootrView
{
    self.footerView=[[WTREpubFooterView alloc]initWithFrame:CGRectMake(0, ScreenHeight-WTREpubFooterHight, ScreenWidth,WTREpubFooterHight)];
    self.footerView.backgroundColor=self.headView.backgroundColor;
    self.footerView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:self.footerView];
    
    
    WTREpubHtmlFile *file=[self.htmlArray objectAtIndex:_curintRedinghtmlIndex];
    [file loaddataIfNotLoad];
    [self.footerView setcurPage:_curintRedingPage totalPage:(int)file.pageArray.count];
    
    __WEAKSelf
    self.footerView.retpageCb=^(NSInteger curpage){
        [weakSelf jumptoPage:curpage speakifneed:NO];
    };
    self.footerView.retChapterShow=^(void){
        [WTREpubChapterView ShowCurintChapterInView:weakSelf.view withHtmlFileArray:weakSelf.htmlArray curintIndex:weakSelf.curintRedinghtmlIndex SelectCb:^(NSInteger index) {
            [weakSelf jumptohtmlIndex:index Page:0];
        }];
    };
    self.footerView.retupdataShow=^(void){
        [weakSelf updatashowview];
    };
}
#pragma mark 跳转章节
-(void)jumptohtmlIndex:(NSInteger)index Page:(NSInteger)jumpPage
{
    if (_curintRedingPage==jumpPage&&_curintRedinghtmlIndex==index) {
        return;
    }
    WTREpubPageViewController *epubpageViewController=[self getWTREpubPageViewControllerWithHtmlIndex:index page:jumpPage];
    
    if (epubpageViewController) {
        [self.pagevc setViewController:epubpageViewController];
        _curintRedingPage=epubpageViewController.epubpage.curintpage;
        _curintRedinghtmlIndex=epubpageViewController.htmlfile.index;
        
        [self.footerView setcurPage:_curintRedingPage totalPage:epubpageViewController.htmlfile.pageArray.count];
    }
}
#pragma mark 跳转到页
-(void)jumptoPage:(NSInteger)jumpPage speakifneed:(BOOL)isspeak
{
    if (_curintRedingPage==jumpPage) {
        return;
    }
    
//    _isspeak=isspeak;

    WTREpubPageViewController *epubpageViewController;
    WTREpubHtmlFile *file=[self.htmlArray objectAtIndex:_curintRedinghtmlIndex];
    if (jumpPage>file.pageArray.count-1) {
        jumpPage=0;
        epubpageViewController=[self getWTREpubPageViewControllerWithHtmlIndex:_curintRedinghtmlIndex+1 page:jumpPage];
    }
    else
        epubpageViewController=[self getWTREpubPageViewControllerWithHtmlIndex:_curintRedinghtmlIndex page:jumpPage];
    
    if (epubpageViewController) {
        [self.pagevc setViewController:epubpageViewController];
        _curintRedingPage=epubpageViewController.epubpage.curintpage;
        _curintRedinghtmlIndex=epubpageViewController.htmlfile.index;
        
        [self.footerView setcurPage:_curintRedingPage totalPage:epubpageViewController.htmlfile.pageArray.count];
    }
}
-(void)jumpnextpage
{
    [self jumptoPage:_curintRedingPage+1 speakifneed:YES];
}

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [coordinator animateAlongsideTransitionInView:nil animation:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        [self updatashowview];
    }];
}
-(void)updatashowview
{
    [self updatesizhoujuli];
    for (WTREpubHtmlFile *file in self.htmlArray) {
        [file Clearloaddata];
    }
    WTREpubPageViewController *epubpageViewController=[self getWTREpubPageViewControllerWithHtmlIndex:_curintRedinghtmlIndex page:_curintRedingPage];
    if (epubpageViewController) {
        [self.pagevc setViewController:epubpageViewController];
        _curintRedingPage=epubpageViewController.epubpage.curintpage;
        _curintRedinghtmlIndex=epubpageViewController.htmlfile.index;
        
        [self.footerView setcurPage:_curintRedingPage totalPage:epubpageViewController.htmlfile.pageArray.count];
    }
    self.view.backgroundColor=[WTREpubConfig shareInstance].themeColor;
}
-(void)updatesizhoujuli
{
    if (ISIPhoneX&&ScreenWidth>ScreenHeight) {
        if ([UIDevice currentDevice].orientation==UIDeviceOrientationLandscapeLeft) {
            [WTREpubConfig shareInstance].contentEdgeInsets=UIEdgeInsetsMake([WTREpubConfig shareInstance].contentEdgeInsets.top, 46, [WTREpubConfig shareInstance].contentEdgeInsets.bottom,[WTREpubConfig shareInstance].contentEdgeInsets.right);
        }else{
            [WTREpubConfig shareInstance].contentEdgeInsets=UIEdgeInsetsMake([WTREpubConfig shareInstance].contentEdgeInsets.top, [WTREpubConfig shareInstance].contentEdgeInsets.left, [WTREpubConfig shareInstance].contentEdgeInsets.bottom, 46);
        }
    }else{
        [WTREpubConfig shareInstance].contentEdgeInsets=UIEdgeInsetsMake([WTREpubConfig shareInstance].contentEdgeInsets.top,20,[WTREpubConfig shareInstance].contentEdgeInsets.bottom, 20);
    }
}
-(void)remoteControlReceivedWithEvent:(UIEvent *)event
{
//    [[WTRTextSpeaker shareInstence] remoteControlReceivedWithEvent:event];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
