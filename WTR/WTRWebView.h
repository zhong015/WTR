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

NS_ASSUME_NONNULL_BEGIN

@interface WTRWebView : WKWebView

//生成完整html
+(NSString *)htmlStrWithBodyXml:(NSString *)bodyXml fontSize:(CGFloat)fontSize;

+(instancetype)newWebView;//默认初始化情况

@property(nonatomic,assign)BOOL isChangeHeight;//是否跟随网页改变高度 默认NO
@property(nonatomic,assign)CGFloat maxChangeHeight;//最大高度 默认-1 不限制高度
@property(nonatomic,copy,nullable)void (^retupdatefreame)(void);//高度改变


/*
 代理部分 如果替换就不会调用
 因为内部已经写了
 self.UIDelegate=self;
 self.navigationDelegate=self;
 */

/*
 拦截不了跳转的话可以给a标签加上 target='_blank'
 webv.didFinishNavigation = ^(WKNavigation * _Nonnull navigation, NSError * _Nullable error) {
     [weakWebv evaluateJavaScript:@"document.querySelectorAll('a').forEach(function(one) {one.target='_blank';});" completionHandler:nil];
 };
 */
@property(nonatomic,copy,nullable)BOOL (^shouldStartLoad)(NSURL *url);//是否跳转url

@property(nonatomic,copy,nullable)void (^didStartNavigation)(WKNavigation *navigation);
@property(nonatomic,copy,nullable)void (^didFinishNavigation)(WKNavigation *navigation,NSError * _Nullable error);



-(void)setCharsetUTF8;
-(void)setScalesPageToFitWithUserScalable:(BOOL)userScalable;//适应手机显示模式

-(void)addUserScript:(NSString *)jScript injectionTime:(WKUserScriptInjectionTime)injectionTime forMainFrameOnly:(BOOL)forMainFrameOnly;
-(void)removeAllUserScripts;


@property(nonatomic,strong,readonly,nullable)NSURLRequest *currentreq;//当前请求

@end

NS_ASSUME_NONNULL_END
