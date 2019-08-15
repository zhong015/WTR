//
//  WTRWebView.m
//  CnkiIPhoneClient
//
//  Created by wfz on 2019/7/25.
//  Copyright © 2019 net.cnki.www. All rights reserved.
//

#import "WTRWebView.h"
#import "WTRImageListShow.h"

#import "UIImageView+AFNetworking.h"
#import "AFImageDownloader.h"

//#import "WTRWebUrlPro.h"

static void *WTRWebViewContentSizeContext = &WTRWebViewContentSizeContext;

@interface WTRWebView ()<WKUIDelegate,WKNavigationDelegate>

@end

@implementation WTRWebView
{
    NSArray *_imageArray;

    NSURLRequest *_currentreq;
}
- (void)dealloc
{
    if (self.isLoading) {
        [self stopLoading];
    }
    [self removeObserver:self forKeyPath:@"scrollView.contentSize"];
    //    [NSURLProtocol unregisterClass:[WTRWebUrlPro class]];
    //    [WTRWebUrlPro quxiao];

    //    [[UIImageView sharedImageDownloader].imageCache removeAllImages];
    //    [[UIImageView sharedImageDownloader].sessionManager.session.configuration.URLCache removeAllCachedResponses];
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self loadui];
    }
    return self;
}
-(void)loadui
{
    self.isOpenImage=YES;
    self.isImageAnimate=YES;
    self.isChangeHeight=NO;
    _imageArray=nil;

    self.UIDelegate=self;
    self.navigationDelegate=self;

    if (@available(iOS 11.0, *)) {
        self.scrollView.contentInsetAdjustmentBehavior=UIScrollViewContentInsetAdjustmentNever;
    }

    [self addObserver:self forKeyPath:@"scrollView.contentSize" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:WTRWebViewContentSizeContext];

}
-(void)setCharsetUTF8
{
    //<meta charset="UTF-8">

    NSString* jScript = @"var meta = document.createElement('meta'); \
    meta.charset = 'UTF-8'; \
    var head = document.getElementsByTagName('head')[0];\
    head.appendChild(meta);";

    [self addUserScript:jScript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:NO];
}
-(void)setScalesPageToFitWithUserScalable:(BOOL)userScalable
{
    //<meta name="viewport" content="width=device-width,initial-scale=1;maximum-scale=1, minimum-scale=1, user-scalable=no" />

    NSString* jScript;

    if (userScalable) {
        jScript = @"var meta = document.createElement('meta'); \
        meta.name = 'viewport'; \
        meta.content = 'width=device-width, user-scalable=yes'; \
        var head = document.getElementsByTagName('head')[0];\
        head.appendChild(meta);";
    }else{
        jScript = @"var meta = document.createElement('meta'); \
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
    self.height=self.scrollView.contentSize.height;
    if (self.retupdatefreame) {
        self.retupdatefreame();
    }
}
-(void)getimagelist
{
    if (!self.isOpenImage) {
        return;
    }
    NSString *imlistjs=@"var wtrimgarr = document.getElementsByTagName('img');\
    var wtrimsrcarr=[];\
    for (var i = 0; i < wtrimgarr.length; i++) {\
    var cimg=wtrimgarr[i];\
    (function (cimg){\
    wtrimgarr[i].onclick = function() {\
    var reactObj = cimg.getBoundingClientRect();\
    window.location.href='imageclick://'+escape(JSON.stringify({\"react\":reactObj,\"src\":cimg.getAttribute(\"src\")}));\
    };\
    })(cimg);\
    wtrimsrcarr.push(cimg.getAttribute(\"src\"));\
    }\
    wtrimsrcarr";

    [self evaluateJavaScript:imlistjs completionHandler:^(NSArray *arrimg, NSError * _Nullable error) {
        if (arrimg&&[arrimg isKindOfClass:[NSArray class]]&&arrimg.count>0) {
            NSMutableArray *muarr=[NSMutableArray array];
            for (int i=0; i<arrimg.count; i++) {
                NSString *cimurl=arrimg[i];
                if (cimurl&&[cimurl isKindOfClass:[NSString class]]) {
                    cimurl=[self getrighturl:cimurl];
                    [muarr addObject:cimurl];
                }
            }
            _imageArray=muarr;
        }
    }];
}
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation
{
    if (self.didStartNavigation) {
        self.didStartNavigation(navigation);
    }
}
-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    [self getimagelist];
    if (self.didFinishNavigation) {
        self.didFinishNavigation(navigation);
    }
}
- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error
{
    if (self.didFinishNavigation) {
        self.didFinishNavigation(navigation);
    }
}
-(void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    BOOL resultBOOL = [self shouldStartLoadWithRequest:navigationAction.request navigationType:navigationAction.navigationType];
    if(resultBOOL)
    {
        _currentreq=navigationAction.request;
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
    NSString *urlstr=request.URL.absoluteString;
    if ([self showimage:urlstr]) {
        return NO;
    }
    if (self.shouldStartLoad) {
        return self.shouldStartLoad(urlstr);
    }
    return NO;
}

#pragma mark 展示图片
-(BOOL)showimage:(NSString *)imageurlstr
{
    if (!self.isOpenImage||!ISString(imageurlstr)||!_imageArray) {
        return NO;
    }
    imageurlstr=[imageurlstr stringByURLDecode];
    if ([imageurlstr hasPrefix:@"imageclick://"]) {
        imageurlstr=[imageurlstr stringByReplacingOccurrencesOfString:@"imageclick://" withString:@""];
        NSDictionary *dic=[imageurlstr JSONObject];
        if (dic&&[dic isKindOfClass:[NSDictionary class]]) {
            imageurlstr=[dic objectForKey:@"src"];

            imageurlstr=[self getrighturl:imageurlstr];

            NSDictionary *react=[dic objectForKey:@"react"];

            CGFloat x=[[react objectForKey:@"x"] floatValue];
            CGFloat y=[[react objectForKey:@"y"] floatValue];
            CGFloat width=[[react objectForKey:@"width"] floatValue];
            CGFloat height=[[react objectForKey:@"height"] floatValue];

            CGPoint rpo=[self convertPoint:CGPointMake(x,y-self.scrollView.contentOffset.y) toView:[CommonMethod curintViewController].view];

            if (self.isImageAnimate) {
                [WTRImageListShow ShowImageList:_imageArray current:imageurlstr Rect:CGRectMake(rpo.x, rpo.y, width, height) configeOne:^(UIImageView * _Nonnull imv, NSString * _Nonnull imageurl) {

                    //                NSCachedURLResponse *cach=[[NSURLCache sharedURLCache] cachedResponseForRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:imageurl]]];
                    //                if (cach&&cach.data) {
                    //                    UIImage *imc=[UIImage imageWithData:cach.data];
                    //                    if (imc) {
                    //                        imv.image=imc;
                    //                        return ;
                    //                    }
                    //                }
                    //                NSString *cimurl=[imageurl stringByReplacingOccurrencesOfString:WTRWebUrlProScheme withString:@"http"];
                    [imv setImageWithURL:[NSURL URLWithString:imageurl] placeholderImage:[UIImage imageNamed:@"limitFree"]];
                } completion:^{

                }];
            }else{
                [WTRImageListShow ShowImageList:_imageArray current:imageurlstr configeOne:^(UIImageView * _Nonnull imv, NSString * _Nonnull imageurl) {

                    //                NSCachedURLResponse *cach=[[NSURLCache sharedURLCache] cachedResponseForRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:imageurl]]];
                    //                if (cach&&cach.data) {
                    //                    UIImage *imc=[UIImage imageWithData:cach.data];
                    //                    if (imc) {
                    //                        imv.image=imc;
                    //                        return ;
                    //                    }
                    //                }
                    //                NSString *cimurl=[imageurl stringByReplacingOccurrencesOfString:WTRWebUrlProScheme withString:@"http"];
                    [imv setImageWithURL:[NSURL URLWithString:imageurl] placeholderImage:[UIImage imageNamed:@"limitFree"]];
                } completion:^{

                }];
            }
            return YES;
        }
    }
    return NO;
}

#pragma mark 拼接正确的链接
-(NSString *)getrighturl:(NSString *)inurl
{
    if (!ISString(inurl)) {
        return @"";
    }
    if (![inurl hasPrefix:@"http"]) {
        NSURL *yinurl=[NSURL URLWithString:inurl];
        if (ISString(yinurl.host)) {
            inurl=[NSString stringWithFormat:@"http://%@%@",yinurl.host,yinurl.path];
        }else{
            NSString *yurl=_currentreq.URL.absoluteString;
            yurl=[yurl stringByReplacingOccurrencesOfString:_currentreq.URL.path withString:yinurl.path];
            inurl=yurl;
        }
    }
    return inurl;
}


//#pragma mark 额外的信息
/**
 *  web界面中有弹出警告框时调用
 *
 *  @param webView           实现该代理的webview
 *  @param message           警告框中的内容
 *  @param completionHandler 警告框消失调用
 */
//- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
//{
//    NSLog(@"message:%@",message);
//    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"HTML的弹出框" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
//    [alertController addAction:([UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        completionHandler();
//    }])];
//    [self presentViewController:alertController animated:YES completion:nil];
//}
// 确认框
//JavaScript调用confirm方法后回调的方法 confirm是js中的确定框，需要在block中把用户选择的情况传递进去
//- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler
//{
//    NSLog(@"message:%@",message);
////    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
////    [alertController addAction:([UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
////        completionHandler(NO);
////    }])];
////    [alertController addAction:([UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
////        completionHandler(YES);
////    }])];
////    [self presentViewController:alertController animated:YES completion:nil];
//}
// 输入框
//JavaScript调用prompt方法后回调的方法 prompt是js中的输入框 需要在block中把用户输入的信息传入
//- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler{
////    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt message:@"" preferredStyle:UIAlertControllerStyleAlert];
////    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
////        textField.text = defaultText;
////    }];
////    [alertController addAction:([UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
////        completionHandler(alertController.textFields[0].text?:@"");
////    }])];
////    [self presentViewController:alertController animated:YES completion:nil];
//}
//// 页面是弹出窗口 _blank 处理
//- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
//{
//    if (!navigationAction.targetFrame.isMainFrame) {
//        [webView loadRequest:navigationAction.request];
//    }
//    return nil;
//}

@end
