//
//  WTRWebView.m
//  Created by wfz on 2019/7/25.

#import "WTRWebView.h"
#import "WTRBaseDefine.h"

static void *WTRWebViewContentSizeContext = &WTRWebViewContentSizeContext;

@interface WTRWebView ()<WKUIDelegate,WKNavigationDelegate>

@property(nonatomic,strong)NSURLRequest *currentreq;

@property(nonatomic,assign)BOOL isAddObserver;

@end

@implementation WTRWebView

- (void)dealloc
{
    [self removeHHObserver];
    if (self.isLoading) {
        [self stopLoading];
    }
}
+(instancetype)newWebView//默认初始化情况
{
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    if (@available(iOS 10.0, *)) {
        config.mediaTypesRequiringUserActionForPlayback = YES;
        config.allowsAirPlayForMediaPlayback = YES;//允许AirPlay
    }
    config.allowsInlineMediaPlayback = YES;//是否允许内联(YES)或使用本机全屏控制器(NO)，默认是NO。
    
    WTRWebView *webView = [[WTRWebView alloc] initWithFrame:CGRectZero configuration:config];
    return webView;
}
- (instancetype)initWithFrame:(CGRect)frame configuration:(nonnull WKWebViewConfiguration *)configuration
{
    self = [super initWithFrame:frame configuration:configuration];
    if (self) {
        _isAddObserver=NO;
        _isChangeHeight=NO;
        [self loadui];
    }
    return self;
}
-(void)loadui
{
    self.UIDelegate=self;
    self.navigationDelegate=self;
    
    self.maxChangeHeight=-1;
    
    if (@available(iOS 11.0, *)) {
        self.scrollView.contentInsetAdjustmentBehavior=UIScrollViewContentInsetAdjustmentNever;
    }
    
#if DEBUG
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 160400
    if (@available(iOS 16.4, *)) {
        self.inspectable=YES;
    }
#endif
#endif

}
-(void)setIsChangeHeight:(BOOL)isChangeHeight
{
    _isChangeHeight=isChangeHeight;
    if (isChangeHeight) {
        [self addHHObserver];
    }else{
        [self removeHHObserver];
    }
}
-(void)addHHObserver
{
    if (self.isAddObserver) {
        return;
    }
    self.isAddObserver=YES;
    [self addObserver:self forKeyPath:@"scrollView.contentSize" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:WTRWebViewContentSizeContext];
    
    if(_isChangeHeight){
        //解决bug:内容的第一个元素的margin-top大于0时，更新web高度后，body会循环增大
        [self addUserScript:@"document.body.style.paddingTop='1px';" injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:NO];
        
        //如果最后一个元素margin-bottom>0那么最下面的空白不会显示到高度里，可以改成padding-bottom或者body增加padding-bottom: document.body.style.paddingTop='1px';
    }
}
-(void)removeHHObserver
{
    if (!self.isAddObserver) {
        return;
    }
    self.isAddObserver=NO;
    [self removeObserver:self forKeyPath:@"scrollView.contentSize"];
}
-(void)setCharsetUTF8
{
    ///<meta charset="UTF-8" />

    NSString* jScript = @"var meta = document.createElement('meta'); \
    meta.charset = 'UTF-8'; \
    var head = document.getElementsByTagName('head')[0];\
    head.appendChild(meta);";

    [self addUserScript:jScript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:NO];
}
-(void)setScalesPageToFitWithUserScalable:(BOOL)userScalable
{
    // <meta name="viewport" content="width=device-width,initial-scale=1;maximum-scale=1, minimum-scale=1, user-scalable=no" />
    
    // 手机端如果字体自动调整了可以设置这个
    // css: -webkit-text-size-adjust:none;
    // js: document.body.style.WebkitTextSizeAdjust='none'

    NSString* jScript;

    if (userScalable) {
        jScript = @"document.querySelectorAll('meta').forEach(function(meta) {if(meta.name=='viewport'){meta.parentNode.removeChild(meta);}});\
        var meta = document.createElement('meta'); \
        meta.name = 'viewport'; \
        meta.content = 'width=device-width, user-scalable=yes'; \
        var head = document.getElementsByTagName('head')[0];\
        head.appendChild(meta);";
    }else{
        jScript = @"document.querySelectorAll('meta').forEach(function(meta) {if(meta.name=='viewport'){meta.parentNode.removeChild(meta);}});\
        var meta = document.createElement('meta'); \
        meta.name = 'viewport'; \
        meta.content = 'width=device-width,initial-scale=1;maximum-scale=1, minimum-scale=1, user-scalable=no'; \
        var head = document.getElementsByTagName('head')[0];\
        head.appendChild(meta);";
    }
    [self addUserScript:jScript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:NO];
}
-(void)addUserScript:(NSString *)jScript injectionTime:(WKUserScriptInjectionTime)injectionTime forMainFrameOnly:(BOOL)forMainFrameOnly
{
    WKUserContentController *userContentController = self.configuration.userContentController;
    NSArray <WKUserScript *> *array = userContentController.userScripts;
    WKUserScript* fitWKUScript = nil;
    for (WKUserScript* wkUScript in array) {
        if ([wkUScript.source isEqual:jScript]) {
            fitWKUScript = wkUScript;
            break;
        }
    }
    if (!fitWKUScript) {
        fitWKUScript = [[WKUserScript alloc] initWithSource:jScript injectionTime:injectionTime forMainFrameOnly:forMainFrameOnly];
        [userContentController addUserScript:fitWKUScript];
    }
}
-(void)removeAllUserScripts
{
    [self.configuration.userContentController removeAllUserScripts];
}

#pragma mark webv代理
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if (context==WTRWebViewContentSizeContext) {
        [self updateframe];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}
-(void)updateframe
{
    if (!self.isChangeHeight) {
        return;
    }
    if (ABS(self.height-self.scrollView.contentSize.height)<0.1) {
        return;
    }
    
    //scrollView.contentSize.height 可能最小是屏幕高 而且不会自动变小 这时需要自己再获取document.body.clientHeight实际网页高
    
    if (self.maxChangeHeight>1&&self.scrollView.contentSize.height>self.maxChangeHeight) {
        if (self.height<self.maxChangeHeight) {
            self.height=self.maxChangeHeight;
            if (self.retupdatefreame) {
                self.retupdatefreame();
            }
        }
        return;
    }
    self.height=self.scrollView.contentSize.height;
    if (self.retupdatefreame) {
        self.retupdatefreame();
    }
    
    /*
     如果这里循环调用，说明内容的第一个元素的 margin-top大于0 可以移除或者改成 padding-top 或者给body加上 style="padding-top: 1px;"
     */
}
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation
{
    if (self.didStartNavigation) {
        self.didStartNavigation(navigation);
    }
}
-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    if (self.didFinishNavigation) {
        self.didFinishNavigation(navigation,nil);
    }
}
- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error
{
    if (self.didFinishNavigation) {
        self.didFinishNavigation(navigation,error);
    }
}
//- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler
//{
//    if ([navigationResponse.response isKindOfClass:[NSHTTPURLResponse class]]) {
//        NSHTTPURLResponse *resp=(NSHTTPURLResponse *)navigationResponse.response;
//        if (resp.statusCode!=200) {//可能会有302重定向什么的 还有其它正确返回类型 所以不能只判断200
//            decisionHandler(WKNavigationResponsePolicyCancel);
//            return;
//        }
//    }
//    decisionHandler (WKNavigationResponsePolicyAllow);
//}

//打开新网页时 直接替换到当前页
- (nullable WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
    if (!navigationAction.targetFrame.isMainFrame) {
        BOOL resultBOOL = [self shouldStartLoadWithRequest:navigationAction.request navigationType:navigationAction.navigationType];
        if (resultBOOL) {
            [webView loadRequest:navigationAction.request];
        }
    }
    return nil;
}

-(void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    BOOL resultBOOL = [self shouldStartLoadWithRequest:navigationAction.request navigationType:navigationAction.navigationType];
    if(resultBOOL)
    {
        self.currentreq=navigationAction.request;
        if(!navigationAction.targetFrame) //|| !navigationAction.targetFrame.mainFrame
        {
            [webView loadRequest:navigationAction.request];
        }
        decisionHandler(WKNavigationActionPolicyAllow);
    }
    else
    {
        decisionHandler(WKNavigationActionPolicyCancel);
    }
}
-(BOOL)shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(WKNavigationType)navigationType
{
    if (self.shouldStartLoad) {
        return self.shouldStartLoad(request.URL);
    }
    return YES;
}

//#pragma mark 额外的信息 可继承本类去实现
/**
 *  web界面中有弹出警告框时调用
 *
 *  webView           实现该代理的webview
 *  message           警告框中的内容
 *  completionHandler 警告框消失调用
 */
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    NSLog(@"message:%@",message);
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:SafeStr(message) message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }]];
    [WTR.curintViewController presentViewController:alertController animated:YES completion:nil];
}
// 确认框
//JavaScript调用confirm方法后回调的方法 confirm是js中的确定框，需要在block中把用户选择的情况传递进去
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler
{
    NSLog(@"message:%@",message);
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:SafeStr(message) message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }])];
    [alertController addAction:([UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }])];
    [WTR.curintViewController presentViewController:alertController animated:YES completion:nil];
}
// 输入框
//JavaScript调用prompt方法后回调的方法 prompt是js中的输入框 需要在block中把用户输入的信息传入
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:SafeStr(prompt) message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = defaultText;
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(alertController.textFields[0].text?:@"");
    }]];
    [WTR.curintViewController presentViewController:alertController animated:YES completion:nil];
}

@end
