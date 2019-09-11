//
//  WTRPageView.m
//  PDFTXTREADER
//
//  Created by wfz on 2017/10/23.
//  Copyright © 2017年 wfz. All rights reserved.
//

#define TPUCHJULIWV 4 //点击翻页区域 是屏幕的几分之一

#import "WTRPageView.h"
#import "WTRDefine.h"

@interface WTRPageView () <CAAnimationDelegate,UIGestureRecognizerDelegate,UIPageViewControllerDataSource,UIPageViewControllerDelegate>

@end

@implementation WTRPageView
{
    UITapGestureRecognizer *tap;
    UISwipeGestureRecognizer *swip1,*swip2;
    BOOL isshoushiaction;
    
    UIViewController *curintVc;
    
    UIPageViewController *pagevc;
    UIViewController *willtovc;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initui];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initui];
    }
    return self;
}
-(void)initui
{
    _transitionStyle=0;
    isshoushiaction=YES;
    
    tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapclick:)];
    tap.delegate = self;
    [self addGestureRecognizer:tap];
    
    swip1 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeclick:)];
    swip1.direction=UISwipeGestureRecognizerDirectionLeft;
    swip1.delegate = self;
    [self addGestureRecognizer:swip1];
    
    swip2 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeclick:)];
    swip2.direction=UISwipeGestureRecognizerDirectionRight;
    swip2.delegate = self;
    [self addGestureRecognizer:swip2];
    
    pagevc=[[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    pagevc.dataSource=self;
    pagevc.delegate=self;
    pagevc.doubleSided=YES;
    [self addSubview:pagevc.view];
    pagevc.view.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
}
-(void)setFanyeShouShiAction:(BOOL)action
{
    isshoushiaction=action;
    [self updatateactionss];
}
-(void)setTransitionStyle:(NSInteger)transitionStyle
{
    _transitionStyle=transitionStyle;
    [self updatateactionss];
}
-(void)updatateactionss
{
    if (_transitionStyle!=0) {
        for (UIGestureRecognizer *ges in pagevc.view.gestureRecognizers) {
            ges.enabled = NO;
        }
        if (isshoushiaction) {
            tap.enabled=YES;
            swip1.enabled=YES;
            swip2.enabled=YES;
        }else{
            tap.enabled=NO;
            swip1.enabled=NO;
            swip2.enabled=NO;
        }
    }else{
        
        tap.enabled=NO;
        swip1.enabled=NO;
        swip2.enabled=NO;
        
        if (isshoushiaction) {
            if (pagevc.view.hidden) {
                pagevc.view.hidden=NO;
                [curintVc.view removeFromSuperview];
                curintVc.view.tag=102;
                [pagevc setViewControllers:@[curintVc] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
            }
            for (UIGestureRecognizer *ges in pagevc.view.gestureRecognizers) {
                ges.enabled = YES;
            }
        }else{
            for (UIGestureRecognizer *ges in pagevc.view.gestureRecognizers) {
                if ([ges isKindOfClass:[UIPanGestureRecognizer class]]||[ges isKindOfClass:[UITapGestureRecognizer class]]) {
                    ges.enabled = NO;
                }
            }
        }
    }
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (!gestureRecognizer.enabled) {
        return NO;
    }
    if ([gestureRecognizer isKindOfClass:[UISwipeGestureRecognizer class]]) {
        return YES;
    }
    CGPoint po=[touch locationInView:self];
    
    CGFloat ww=ScreenWidth/TPUCHJULIWV;
    if (po.x>=ww&&po.x<=(ScreenWidth-ww)) {
        return NO;
    }
    return YES;
}
-(void)tapclick:(UITapGestureRecognizer *)tapc
{
    CGPoint po=[tapc locationInView:self];
    
    CGFloat ww=ScreenWidth/TPUCHJULIWV;
    
    BOOL iss;
    if (po.x<ww) {
        if (ScreenWidth==414) {//plus 设备 点击左边也跳下一页
            iss=[self gonext];
        }else{
            iss=[self goback];
        }
    }else{
        iss=[self gonext];
    }
    if (!iss) {
        if (self.delegate&&[self.delegate respondsToSelector:@selector(pageViewControllerFiledaction:)]) {
            [self.delegate pageViewControllerFiledaction:self];
        }
    }
}
-(void)swipeclick:(UISwipeGestureRecognizer *)swip
{
    BOOL iss;
    if (swip.direction==UISwipeGestureRecognizerDirectionRight) {
        iss=[self goback];
    }else{
        iss=[self gonext];
    }
    if (!iss) {
        if (self.delegate&&[self.delegate respondsToSelector:@selector(pageViewControllerFiledaction:)]) {
            [self.delegate pageViewControllerFiledaction:self];
        }
    }
}
-(void)setViewController:(UIViewController *_Nonnull)viewController
{
    [self setViewController:viewController comd:YES];
}
-(void)setViewController:(UIViewController *_Nonnull)viewController comd:(BOOL)cond
{
    if (curintVc) {
        [curintVc.view removeFromSuperview];
    }
    curintVc=viewController;
    
    if (self.transitionStyle==0) {
        [self setViewControllerPage:curintVc];
        return;
    }
    if (!pagevc.view.hidden) {
        pagevc.view.hidden=YES;
    }
    [self addSubview:curintVc.view];
    curintVc.view.frame=self.bounds;
    curintVc.view.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    if (cond) {
        if (self.delegate&&[self.delegate respondsToSelector:@selector(pageViewController:didTransitionTo:)]) {
            [self.delegate pageViewController:self didTransitionTo:curintVc];
        }
    }
}

-(BOOL)goback
{
    if (self.delegate&&[self.delegate respondsToSelector:@selector(pageViewController:viewControllerBeforeViewController:)]) {
        UIViewController *nextvc=[self.delegate pageViewController:self viewControllerBeforeViewController:curintVc];
        if (nextvc) {
            [self setViewController:nextvc comd:NO];
            switch (self.transitionStyle) {
                case 0:
                {
                }
                    break;
                case 1:
                {
                    [self transitionWithType:@"pageUnCurl" WithSubtype:kCATransitionFromRight];
                }
                    break;
                case 2:
                {
                    [self transitionWithType:kCATransitionFade WithSubtype:kCATransitionFromLeft];
                }
                    break;
                case 3:
                {
                    [self transitionWithType:kCATransitionPush WithSubtype:kCATransitionFromLeft];
                }
                    break;
                default:{
                    if (self.delegate&&[self.delegate respondsToSelector:@selector(pageViewController:didTransitionTo:)]) {
                        [self.delegate pageViewController:self didTransitionTo:curintVc];
                    }
                }
                    break;
            }
        }else{
            return NO;
        }
    }
    return YES;
}
-(BOOL)gonext
{
    if (self.delegate&&[self.delegate respondsToSelector:@selector(pageViewController:viewControllerAfterViewController:)]) {
        UIViewController *nextvc=[self.delegate pageViewController:self viewControllerAfterViewController:curintVc];
        if (nextvc) {
            [self setViewController:nextvc comd:NO];
            switch (self.transitionStyle) {
                case 0:
                {
                }
                    break;
                case 1:
                {
                    [self transitionWithType:@"pageCurl" WithSubtype:kCATransitionFromRight];
                }
                    break;
                case 2:
                {
                    [self transitionWithType:kCATransitionFade WithSubtype:kCATransitionFromRight];
                }
                    break;
                case 3:
                {
                    [self transitionWithType:kCATransitionPush WithSubtype:kCATransitionFromRight];
                }
                    break;
                default:
                {
                    if (self.delegate&&[self.delegate respondsToSelector:@selector(pageViewController:didTransitionTo:)]) {
                        [self.delegate pageViewController:self didTransitionTo:curintVc];
                    }
                }
                    break;
            }
        }else{
            return NO;
        }
    }
    return YES;
}

- (void) transitionWithType:(NSString *) type WithSubtype:(NSString *) subtype
{
    CATransition *animation = [CATransition animation];
    animation.duration = 0.25f;
    animation.type = type;
    if (subtype != nil) {
        animation.subtype = subtype;
    }
    animation.timingFunction =[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear] ;//UIViewAnimationOptionCurveEaseInOut
    animation.removedOnCompletion=YES;
    animation.delegate=self;

    [self.layer addAnimation:animation forKey:@"animation"];
    self.isdonghuaz=YES;
}
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    self.isdonghuaz=NO;
    if (self.delegate&&[self.delegate respondsToSelector:@selector(pageViewController:didTransitionTo:)]) {
        [self.delegate pageViewController:self didTransitionTo:curintVc];
    }
}

#pragma mark UIPageViewController
-(void)setViewControllerPage:(UIViewController *_Nonnull)viewController
{
    if (pagevc.view.hidden) {
        pagevc.view.hidden=NO;
    }
    viewController.view.tag=102;
    [pagevc setViewControllers:@[viewController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    if (self.delegate&&[self.delegate respondsToSelector:@selector(pageViewController:didTransitionTo:)]) {
        [self.delegate pageViewController:self didTransitionTo:viewController];
    }
}
- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    if (viewController.view.tag==102) {
        UIViewController *vc=[UIViewController new];
        vc.view.backgroundColor=viewController.view.backgroundColor;
        vc.view.tag=0;
        return vc;
    }
    UIViewController *beforevc=nil;
    if (self.delegate&&[self.delegate respondsToSelector:@selector(pageViewController:viewControllerBeforeViewController:)]) {
        beforevc=[self.delegate pageViewController:self viewControllerBeforeViewController:curintVc];
        beforevc.view.tag=102;
    }
    return beforevc;
}
- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    if (viewController.view.tag==102) {
        UIViewController *vc=[UIViewController new];
        vc.view.backgroundColor=viewController.view.backgroundColor;
        vc.view.tag=0;
        return vc;
    }
    UIViewController *nextvc=nil;
    if (self.delegate&&[self.delegate respondsToSelector:@selector(pageViewController:viewControllerAfterViewController:)]) {
        nextvc=[self.delegate pageViewController:self viewControllerAfterViewController:curintVc];
        nextvc.view.tag=102;
    }
    return nextvc;
}
- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers
{
    self.userInteractionEnabled=NO;
    willtovc=[pendingViewControllers firstObject];
    self.isdonghuaz=YES;
}
- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed
{
    self.userInteractionEnabled=YES;
    [self performSelector:@selector(cleardonghuaz) withObject:nil afterDelay:0.25];
    if (completed) {
        if (self.delegate&&[self.delegate respondsToSelector:@selector(pageViewController:didTransitionTo:)]) {
            [self.delegate pageViewController:self didTransitionTo:willtovc];
        }
        curintVc=willtovc;
    }
}
-(void)cleardonghuaz
{
    self.isdonghuaz=NO;
}

@end
