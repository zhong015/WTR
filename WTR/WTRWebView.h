//
//  WTRWebView.h
//  Created by wfz on 2019/7/25.

#import <WebKit/WebKit.h>

//可自动伸展全部web  self.height

/*初始化 例子
 
 必须使用 initWithFrame: configuration:
 
 WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
 if (@available(iOS 10.0, *)) {
     config.mediaTypesRequiringUserActionForPlayback = YES;
 } else {
     config.mediaPlaybackRequiresUserAction=YES;
 }//手动播放设置
 config.allowsInlineMediaPlayback = YES; //是否允许内联(YES)或使用本机全屏控制器(NO)，默认是NO。
 config.allowsAirPlayForMediaPlayback = YES; //允许AirPlay
 
 self.webView = [[WTRWebView alloc] initWithFrame:CGRectZero configuration:config];
 */

@interface WTRWebView : WKWebView

@property(nonatomic,assign)BOOL isChangeHeight;//是否跟随网页改变高度 默认NO
@property(nonatomic,copy)void (^retupdatefreame)(void);//高度改变


/*
 代理部分 如果替换就不会调用
 因为内部已经写了
 self.UIDelegate=self;
 self.navigationDelegate=self;
 */

@property(nonatomic,copy)BOOL (^shouldStartLoad)(NSURL *url);//是否跳转url

//开始跳转新链接
@property(nonatomic,copy)void (^didStartNavigation)(WKNavigation *navigation);

//链接加载完成会返回这两个中的一个
@property(nonatomic,copy)void (^didHaveErrorRes)(WKNavigationResponse *navigationResponse);
@property(nonatomic,copy)void (^didFinishNavigation)(WKNavigation *navigation);



-(void)setCharsetUTF8;
-(void)setScalesPageToFitWithUserScalable:(BOOL)userScalable;//适应手机显示模式

-(void)addUserScript:(NSString *)jScript injectionTime:(WKUserScriptInjectionTime)injectionTime forMainFrameOnly:(BOOL)forMainFrameOnly;
-(void)removeAllUserScripts;


@property(nonatomic,strong,readonly)NSURLRequest *currentreq;//当前请求

@end
