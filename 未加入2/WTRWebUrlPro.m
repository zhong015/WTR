//
//  WTRWebUrlPro.m
//  CnkiIPhoneClient
//
//  Created by wfz on 2019/7/12.
//  Copyright © 2019 net.cnki.www. All rights reserved.
//

#import "WTRWebUrlPro.h"
#import <WebKit/WebKit.h>

Class ContextControllerClass() {
    static Class cls;
    if (!cls) {
        cls = [[[WKWebView new] valueForKey:@"browsingContextController"] class];
    }
    return cls;
}
SEL RegisterSchemeSelector() {
    return NSSelectorFromString(@"registerSchemeForCustomProtocol:");
}
SEL UnregisterSchemeSelector() {
    return NSSelectorFromString(@"unregisterSchemeForCustomProtocol:");
}

@implementation WTRWebUrlPro
{
    NSURLSessionDataTask *_task;
}
+(void)zhuce
{
    Class cls = ContextControllerClass();
    SEL sel = RegisterSchemeSelector();
    if ([(id)cls respondsToSelector:sel]) {
        // 放弃编辑器警告
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [(id)cls performSelector:sel withObject:WTRWebUrlProScheme];
#pragma clang diagnostic pop
    }
}
+(void)quxiao
{
    Class cls = ContextControllerClass();
    SEL sel = UnregisterSchemeSelector();
    if ([(id)cls respondsToSelector:sel]) {
        // 放弃编辑器警告
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [(id)cls performSelector:sel withObject:WTRWebUrlProScheme];
#pragma clang diagnostic pop
    }
}

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    if ([request.URL.scheme isEqualToString:WTRWebUrlProScheme]) {
        return YES;
    }
    return NO;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {

    NSMutableURLRequest *mutableReqeust = [request mutableCopy];
    //这边可用干你想干的事情。。更改地址，提取里面的请求内容，或者设置里面的请求头。。
    return mutableReqeust;
}

//两个请求是否一样 用于缓存
+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b{
    if ([a.URL.absoluteString isEqualToString:b.URL.absoluteString]) {
        return YES;
    }
    return NO;
}

- (void)startLoading
{
    NSURLRequest *reqeust =[self request];

    NSCachedURLResponse *cach=[[NSURLCache sharedURLCache] cachedResponseForRequest:[NSURLRequest requestWithURL:reqeust.URL]];

    if (cach&&cach.data){
        NSData *data = cach.data;
        NSURLResponse *wresponse = [[NSURLResponse alloc] initWithURL:reqeust.URL MIMEType:[self sd_contentTypeForImageData:data] expectedContentLength:data.length textEncodingName:nil];
        [self.client URLProtocol:self
              didReceiveResponse:wresponse
              cacheStoragePolicy:NSURLCacheStorageNotAllowed];
        [self.client URLProtocol:self didLoadData:data];
        [self.client URLProtocolDidFinishLoading:self];
    }else{

        NSString *urlstr=reqeust.URL.absoluteString;
        urlstr=[urlstr stringByReplacingOccurrencesOfString:WTRWebUrlProScheme withString:@"http"];
        _task=[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:urlstr] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error) {
                [self.client URLProtocol:self didFailWithError:error];
            }else{
                NSURLResponse *wresponse = [[NSURLResponse alloc] initWithURL:reqeust.URL MIMEType:[self sd_contentTypeForImageData:data] expectedContentLength:data.length textEncodingName:nil];
                [self.client URLProtocol:self didReceiveResponse:wresponse cacheStoragePolicy:NSURLCacheStorageNotAllowed];
                [self.client URLProtocol:self didLoadData:data];
                [self.client URLProtocolDidFinishLoading:self];

                NSCachedURLResponse *cach=[[NSCachedURLResponse alloc] initWithResponse:wresponse data:data];
                [[NSURLCache sharedURLCache] storeCachedResponse:cach forRequest:[NSURLRequest requestWithURL:reqeust.URL]];
            }
        }];
        [_task resume];
    }
}
- (NSString *)sd_contentTypeForImageData:(NSData *)data {
    uint8_t c;
    [data getBytes:&c length:1];
    switch (c) {
        case 0xFF:
            return @"image/jpeg";
        case 0x89:
            return @"image/png";
        case 0x47:
            return @"image/gif";
        case 0x49:
        case 0x4D:
            return @"image/tiff";
        case 0x52:
            // R as RIFF for WEBP
            if ([data length] < 12) {
                return nil;
            }

            NSString *testString = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(0, 12)] encoding:NSASCIIStringEncoding];
            if ([testString hasPrefix:@"RIFF"] && [testString hasSuffix:@"WEBP"]) {
                return @"image/webp";
            }

            return nil;
    }
    return nil;
}

- (void)stopLoading
{
    if (_task) {
        [_task cancel];
    }
}

@end
