//
//  WTRPageView.h
//  PDFTXTREADER
//
//  Created by wfz on 2017/10/23.
//  Copyright © 2017年 wfz. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WTRPageViewDataSource;

@interface WTRPageView : UIView

@property (nullable, nonatomic, weak) id <WTRPageViewDataSource> delegate;

@property(nonatomic,assign) NSInteger transitionStyle;//翻页模式

-(void)setViewController:(UIViewController *_Nonnull)viewController;

-(BOOL)goback;
-(BOOL)gonext;


@property(nonatomic,assign)BOOL isdonghuaz;//动画中

-(void)setFanyeShouShiAction:(BOOL)action;//设置是否打开翻页手势

@end


@protocol WTRPageViewDataSource <NSObject>

- (nullable UIViewController *)pageViewController:(WTRPageView *_Nonnull)pageView viewControllerBeforeViewController:(UIViewController *_Nonnull)viewController;
- (nullable UIViewController *)pageViewController:(WTRPageView *_Nonnull)pageView viewControllerAfterViewController:(UIViewController *_Nonnull)viewController;

- (void)pageViewController:(WTRPageView *_Nonnull)pageViewController didTransitionTo:(UIViewController *_Nonnull)viewController;

- (void)pageViewControllerFiledaction:(WTRPageView *_Nonnull)pageViewController;

@end
