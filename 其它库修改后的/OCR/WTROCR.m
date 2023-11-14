//
//  WTROCR.m
//  CnkiIPhoneClient
//
//  Created by wfz on 2023/10/8.
//  Copyright © 2023 net.cnki.www. All rights reserved.
//

#import "WTROCR.h"
#import "WTRWebView.h"
#import "GCDWebServer.h"
#import <CoreServices/CoreServices.h>

@interface WTROCR ()<GCDWebServerDelegate>

@property(nonatomic,assign)uint16_t locPort;

@property(nonatomic,strong)GCDWebServer *webServer;

@property(nonatomic,strong)NSString *dirPath;

@property(nonatomic,strong)UIImage *img;

@property(nonatomic,strong)WTRWebView *webv;

@property(nonatomic,strong)void (^retcb)(NSString *retStr);

@property(nonatomic,assign)int checknum;

@end

static WTROCR *oneocr=nil;
@implementation WTROCR

+(void)ocrimage:(UIImage *)image retcb:(void (^)(NSString *retStr))retcb
{
    if(oneocr){
        return;
    }
    oneocr=[WTROCR new];
    oneocr.img=image;
    oneocr.retcb = retcb;
    
    NSString *ocrcspath=[[NSBundle mainBundle] pathForResource:@"ocrcs" ofType:@""];
    NSString *tmpDir=[[WTRFilePath getTemporaryPath] stringByAppendingPathComponent:@"wtrocr"];
    [[NSFileManager defaultManager] removeItemAtPath:tmpDir error:nil];
    [[NSFileManager defaultManager] copyItemAtPath:ocrcspath toPath:tmpDir error:nil];
    NSLog(@"tmpDir:%@",tmpDir);
    oneocr.dirPath=tmpDir;
    
    [oneocr loadLocServ];
}
#pragma mark 本地服务
-(void)loadLocServ
{
    uint16_t port=1300;
    while ([WTR isAlreadyBindPort:port]) {
        port++;
        if (port>1400) {
            NSLog(@"\n\n找不到可用端口\n");
            return;
        }
    }
    self.locPort=port;
    
    self.webServer=[[GCDWebServer alloc] init];
    self.webServer.delegate=self;
    
    
//    直接静态文件夹
    [self.webServer addGETHandlerForBasePath:@"/" directoryPath:self.dirPath indexFilename:nil cacheAge:3600 allowRangeRequests:YES];
    
    [self.webServer startWithPort:self.locPort bonjourName:nil];
}
- (void)webServerDidStart:(GCDWebServer*)server
{
    if(self.webv){
        return;
    }
    self.webv=[WTRWebView newWebView];
    [WTR.curintViewController.view addSubview:self.webv];
    self.webv.frame=CGRectMake(ScreenWidth/2.0, 1, 1, 1);
    
    __WEAKSelf
    self.webv.didFinishNavigation = ^(WKNavigation * _Nonnull navigation, NSError * _Nullable error) {
        NSData *imda=UIImagePNGRepresentation(weakSelf.img);
        NSString *jsstr=[NSString stringWithFormat:@"ocr_recognize('data:image/png;base64,%@')",[imda base64EncodedString]];
        [weakSelf.webv evaluateJavaScript:jsstr completionHandler:^(NSString *retstr, NSError * _Nullable error) {
            weakSelf.checknum=60;
            [weakSelf checkres];
        }];
    };
    NSString *locurl=[NSString stringWithFormat:@"http://127.0.0.1:%d/ocr.html",self.locPort];
    NSLog(@"locurl:%@",locurl);
    [self.webv loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:locurl] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10]];
}
- (void)webServerDidStop:(GCDWebServer*)server
{
    NSLog(@"webServerDidStop");
    [self.webv removeFromSuperview];
    oneocr=nil;
}
- (void)stopAll
{
    [self.webv stopLoading];
    if (self.webServer) {
        [self.webServer stop];
    }
}
-(void)checkres
{
    if(_checknum<0){
        if(self.retcb){
            self.retcb(@"");
        }
        [self stopAll];
        return;
    }
    _checknum--;
    __WEAKSelf
    [self.webv evaluateJavaScript:@"retstr" completionHandler:^(NSString *retstr, NSError * _Nullable error) {
        NSLog(@"retstr:%@ num:%d",retstr,weakSelf.checknum);
        if(!ISString(retstr)){
            [weakSelf performSelector:@selector(checkres) withObject:nil afterDelay:0.5];
        }else{
            if(self.retcb){
                self.retcb(retstr);
            }
            [self stopAll];
        }
    }];
    
}

@end
