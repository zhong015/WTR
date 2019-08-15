//
//  WTRWebView.h
//  CnkiIPhoneClient
//
//  Created by wfz on 2019/7/25.
//  Copyright © 2019 net.cnki.www. All rights reserved.
//

#import <WebKit/WebKit.h>

//自动伸展全部web  self.height

NS_ASSUME_NONNULL_BEGIN

@interface WTRWebView : WKWebView

@property(nonatomic,assign)BOOL isOpenImage;//是否可以放大图片 默认YES
@property(nonatomic,assign)BOOL isImageAnimate;//是否有放大动画 默认YES


@property(nonatomic,assign)BOOL isChangeHeight;//是否跟随网页改变高度 默认NO
@property(nonatomic,copy)void (^retupdatefreame)(void);//高度改变


@property(nonatomic,copy)BOOL (^shouldStartLoad)(NSString *urlstr);//是否跳转url


@property(nonatomic,copy)void (^didStartNavigation)(WKNavigation *navigation);
@property(nonatomic,copy)void (^didFinishNavigation)(WKNavigation *navigation);


-(void)setCharsetUTF8;
-(void)setScalesPageToFitWithUserScalable:(BOOL)userScalable;//适应手机宽

-(void)addUserScript:(NSString *)jScript injectionTime:(WKUserScriptInjectionTime)injectionTime forMainFrameOnly:(BOOL)forMainFrameOnly;
-(void)removeAllUserScripts;


@end

NS_ASSUME_NONNULL_END
