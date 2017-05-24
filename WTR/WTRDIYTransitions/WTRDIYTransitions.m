//
//  WTRDIYTransitions.m
//  WTRGitCs
//
//  Created by wfz on 2017/5/24.
//  Copyright © 2017年 wfz. All rights reserved.
//

#import "WTRDIYTransitions.h"
#import "WTRDefine.h"

@implementation pushTransitioningWWAl

// This is used for percent driven interactive transitions, as well as for container controllers that have companion animations that might need to
// synchronize with the main animation.
- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return 0.35;
}
// This method can only  be a nop if the transition is interactive and not a percentDriven interactive transition.
- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    // 可以看做为destination ViewController
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    // 可以看做为source ViewController
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    // 添加toView到容器上
    [[transitionContext containerView] addSubview:toViewController.view];
    
    toViewController.view.alpha=0;
    fromViewController.view.transform=CGAffineTransformIdentity;
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        toViewController.view.alpha=1;
        fromViewController.view.transform=CGAffineTransformIdentity;
        
    } completion:^(BOOL finished) {
        fromViewController.view.transform=CGAffineTransformIdentity;
        toViewController.view.transform = CGAffineTransformIdentity;
        
        // 声明过渡结束-->记住，一定别忘了在过渡结束时调用 completeTransition: 这个方法
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        
    }];
}

@end

@implementation popTransitioningWWAl

// This is used for percent driven interactive transitions, as well as for container controllers that have companion animations that might need to
// synchronize with the main animation.
- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return 0.35;
}
// This method can only  be a nop if the transition is interactive and not a percentDriven interactive transition.
- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    // 可以看做为destination ViewController
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    // 可以看做为source ViewController
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    // 添加toView到容器上
    [[transitionContext containerView] insertSubview:toViewController.view belowSubview:fromViewController.view];
    
    toViewController.view.transform=CGAffineTransformIdentity;
    fromViewController.view.transform=CGAffineTransformIdentity;
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        toViewController.view.transform=CGAffineTransformIdentity;
        fromViewController.view.alpha=0;
        
    }completion:^(BOOL finished) {
        fromViewController.view.transform=CGAffineTransformIdentity;
        toViewController.view.transform = CGAffineTransformIdentity;
        
        // 声明过渡结束-->记住，一定别忘了在过渡结束时调用 completeTransition: 这个方法
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}

@end



@implementation pushTransitioningWW

// This is used for percent driven interactive transitions, as well as for container controllers that have companion animations that might need to
// synchronize with the main animation.
- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return 0.35;
}
// This method can only  be a nop if the transition is interactive and not a percentDriven interactive transition.
- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    // 可以看做为destination ViewController
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    // 可以看做为source ViewController
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    // 添加toView到容器上
    [[transitionContext containerView] addSubview:toViewController.view];
    
    toViewController.view.transform=CGAffineTransformMakeTranslation(0,ScreenHeight);
    fromViewController.view.transform=CGAffineTransformIdentity;
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        toViewController.view.transform=CGAffineTransformIdentity;
        fromViewController.view.transform=CGAffineTransformIdentity;
        
    } completion:^(BOOL finished) {
        fromViewController.view.transform=CGAffineTransformIdentity;
        toViewController.view.transform = CGAffineTransformIdentity;
        
        // 声明过渡结束-->记住，一定别忘了在过渡结束时调用 completeTransition: 这个方法
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        
    }];
}

@end

@implementation popTransitioningWW

// This is used for percent driven interactive transitions, as well as for container controllers that have companion animations that might need to
// synchronize with the main animation.
- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return 0.35;
}
// This method can only  be a nop if the transition is interactive and not a percentDriven interactive transition.
- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    // 可以看做为destination ViewController
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    // 可以看做为source ViewController
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    // 添加toView到容器上
    [[transitionContext containerView] insertSubview:toViewController.view belowSubview:fromViewController.view];
    
    toViewController.view.transform=CGAffineTransformIdentity;
    fromViewController.view.transform=CGAffineTransformIdentity;
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        toViewController.view.transform=CGAffineTransformIdentity;
        fromViewController.view.transform=CGAffineTransformMakeTranslation(0, ScreenHeight);
        
    }completion:^(BOOL finished) {
        fromViewController.view.transform=CGAffineTransformIdentity;
        toViewController.view.transform = CGAffineTransformIdentity;
        
        // 声明过渡结束-->记住，一定别忘了在过渡结束时调用 completeTransition: 这个方法
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}

@end


static id _s;
@implementation WTRDIYTransitions

+(WTRDIYTransitions *)shareinstance
{
    @synchronized(self){
        if (_s==nil) {
            _s=[[[self class]alloc]init];
            
        }
    }
    return _s;
}
-(id)init
{
    self=[super init];
    if (self) {
        self.pushTransitionw=[[pushTransitioningWW alloc]init];
        self.popTransitionw=[[popTransitioningWW alloc]init];
        self.pushTransitionwal=[[pushTransitioningWWAl alloc]init];
        self.popTransitionwal=[[popTransitioningWWAl alloc]init];
    }
    return self;
}

//使用 [self presentViewController:sousuo animated:YES completion:nil];方法时用到的
// sousuo.transitioningDelegate=[WZDYTransitions shareinstance];
- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    return self.pushTransitionw;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return self.popTransitionw;
}

//控制速度的代理
//- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)animator
//{
//
//}
//
//- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator
//{
//    
//


@end
