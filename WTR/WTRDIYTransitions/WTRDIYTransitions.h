//
//  WTRDIYTransitions.h
//  WTRGitCs
//
//  Created by wfz on 2017/5/24.
//  Copyright © 2017年 wfz. All rights reserved.
//

//自定义转场动画

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface pushTransitioningWWAl : NSObject<UIViewControllerAnimatedTransitioning>
@end

@interface popTransitioningWWAl : NSObject<UIViewControllerAnimatedTransitioning>
@end


@interface pushTransitioningWW : NSObject<UIViewControllerAnimatedTransitioning>
@end

@interface popTransitioningWW : NSObject<UIViewControllerAnimatedTransitioning>
@end




@interface WTRDIYTransitions : NSObject

/*
 
 // 转场动画特效用法
 - (id<UIViewControllerAnimatedTransitioning>) navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
 {
    if (operation == UINavigationControllerOperationPush) {
        if ([toVC isKindOfClass:[CorpusFliteVC class]]||[toVC isKindOfClass:[WenCuiLeiBieViewController class]]) {
            return [WTRDIYTransitions shareinstance].pushTransitionw;
        }
    }else{
        if ([fromVC isKindOfClass:[CorpusFliteVC class]]||[fromVC isKindOfClass:[WenCuiLeiBieViewController class]]) {
            return [WTRDIYTransitions shareinstance].popTransitionw;
        }
    }
    return nil;
 }
 
 // 交互 可以不用 一般不用
 //- (id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController*)navigationController                           interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>)animationController
 //{
 //
 //     *  在非交互式动画效果中，该方法返回 nil
 //     *  交互时 用 UIPercentDrivenInteractiveTransition 类 使用这个类里面的updateInteractiveTransition： 控制进度 cancelInteractiveTransition; finishInteractiveTransition;控制取消和完成
 //    return nil;
 //}

 */

+(WTRDIYTransitions *)shareinstance;

@property(nonatomic,strong)pushTransitioningWW *pushTransitionw; //从下到上覆盖
@property(nonatomic,strong)popTransitioningWW *popTransitionw;

@property(nonatomic,strong)pushTransitioningWWAl *pushTransitionwal; //透明度
@property(nonatomic,strong)popTransitioningWWAl *popTransitionwal;

@end
