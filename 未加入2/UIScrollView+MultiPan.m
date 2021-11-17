//
//  UIScrollView+MultiPan.m
//  CNKIKDApp
//
//  Created by wfz on 2021/7/8.
//  Copyright © 2021 cnki. All rights reserved.
//

#import "UIScrollView+MultiPan.h"

@implementation UIScrollView (MultiPan)

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if (![gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]||![otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        return NO;
    }
    if (self.bounces) {//弹性时不响应其它
        return NO;
    }
    
    CGPoint tp = [(UIPanGestureRecognizer*)gestureRecognizer translationInView:self];
    if (ABS(tp.y)>ABS(tp.x)) {
        //纵向滑动
        
        if (!(self.contentSize.height>self.frame.size.height-self.contentInset.top-self.contentInset.bottom+1)) {
            return NO;//当前不是纵向滑动
        }
        
        BOOL isScrollToTopEdge = ABS(self.contentOffset.y-self.contentInset.top)<=1;
        BOOL isScrollToBottomEdge = ABS(self.contentOffset.y+self.frame.size.height-(self.contentSize.height + self.contentInset.bottom))<=1;
        BOOL isScrollToEdge  = (isScrollToTopEdge && tp.y>0) || (isScrollToBottomEdge && tp.y<0);
        if (!isScrollToEdge) {
            return NO;//不是滑动到上下边缘
        }
        
        //响应其它纵向ScrollView
        if ([otherGestureRecognizer.view isKindOfClass:UIScrollView.class]) {
            UIScrollView *scView = (UIScrollView*)otherGestureRecognizer.view;
            if (scView.contentSize.height>scView.frame.size.height-scView.contentInset.top-scView.contentInset.bottom+1) {
                return YES;
            }
        }
        
    }else{
        //横向滑动
        
        if (!(self.contentSize.width>self.frame.size.width-self.contentInset.left-self.contentInset.right+1)) {
            return NO;//当前不是横向滑动
        }
        
        BOOL isScrollToLeftEdge = ABS(self.contentOffset.x-self.contentInset.left)<=1;
        BOOL isScrollToRightEdge = ABS(self.contentOffset.x+self.frame.size.width-(self.contentSize.width + self.contentInset.right))<=1;
        BOOL isScrollToEdge  = (isScrollToLeftEdge && tp.x>0) || (isScrollToRightEdge && tp.x<0);
        if (!isScrollToEdge) {
            return NO;//不是滑动到左右边缘
        }
        
        //响应其它横向ScrollView
        if ([otherGestureRecognizer.view isKindOfClass:UIScrollView.class]) {
            UIScrollView *scView = (UIScrollView*)otherGestureRecognizer.view;
            if (scView.contentSize.width>scView.frame.size.width-scView.contentInset.left-scView.contentInset.right+1) {
                return YES;
            }
        }
    }
    
    //全屏返回手势
    if ([otherGestureRecognizer.view isKindOfClass:NSClassFromString(@"UILayoutContainerView")]) {
        return YES;
    }
    
    return NO;
}

@end
