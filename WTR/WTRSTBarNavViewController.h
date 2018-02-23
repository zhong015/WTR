//
//  WTRSTBarNavViewController.h
//  WTRGitCs
//
//  Created by wfz on 2018/2/23.
//  Copyright © 2018年 wfz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WTRSTBarNavViewController : UINavigationController

@property(nonatomic,assign)BOOL StatusBarIsBlack;//状态栏文字是否是黑色 默认NO (修改的时候 推荐 写在界面init方法里,可以提前改变状态)
@end
