//
//  UIView+WTRFrame.h
//  WTRGitCs
//
//  Created by wfz on 2017/5/24.
//  Copyright © 2017年 wfz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIView (WTRFrame)

@property (nonatomic, assign) CGFloat x;

@property (nonatomic, assign) CGFloat y;

@property (nonatomic, assign) CGFloat centerX;

@property (nonatomic, assign) CGFloat centerY;

@property (nonatomic, assign) CGFloat width;

@property (nonatomic, assign) CGFloat height;

@property (assign, nonatomic) CGSize size;

@property (assign, nonatomic) CGPoint origin;

@property (assign, nonatomic,readonly) CGFloat right;

@property (assign, nonatomic,readonly) CGFloat bottom;

@end
