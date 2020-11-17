//
//  WTRStreamDManager.m
//  WTRMusic
//
//  Created by wfz on 2020/11/17.
//  Copyright © 2020 wfz. All rights reserved.
//

#import "WTRStreamDManager.h"

@interface WTRStreamDTask : NSObject

@property(nonatomic,copy)NSString *tagstr;

@property(nonatomic,assign)int64_t allLen,begin,end;

@property(nonatomic,copy)WTRStreamDHeadRet headret;
@property(nonatomic,copy)WTRStreamDDataRet dataret;
@property(nonatomic,copy)WTRStreamDCompletion completion;

@property(nonatomic,strong)NSURLSessionDataTask *datatask;

@end

@implementation WTRStreamDTask

@end

@interface WTRStreamDManager ()<NSURLSessionDataDelegate,NSURLSessionDelegate>

@property(nonatomic,strong)NSURLSession *urlSession;

@property(nonatomic,strong)NSMutableArray <WTRStreamDTask *>*dArray;
@property(nonatomic,strong)NSLock *dLock;

@end


static id _s=nil;
@implementation WTRStreamDManager

+(instancetype)shareInstence
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (_s==nil) {
            _s=[[[self class] alloc] init];
        }
    });
    return _s;
}
-(id)init
{
    self=[super init];
    if (self) {
        self.urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
        self.dArray=[NSMutableArray array];
        self.dLock=[NSLock new];
    }
    return self;
}
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
                                 didReceiveResponse:(NSURLResponse *)response
                                  completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
    NSHTTPURLResponse *resp=(NSHTTPURLResponse *)response;
    NSString *ContentRange=[resp.allHeaderFields objectForKey:@"Content-Range"];
    NSRange gang=[ContentRange rangeOfString:@"/"];
    NSString *alllen=[ContentRange substringFromIndex:gang.location+gang.length];

    [self.dLock lock];
    WTRStreamDTask *ct=nil;
    for (int i=0; i<self.dArray.count; i++) {
        ct=self.dArray[i];
        if (ct.datatask==dataTask) {
            break;
        }
    }
    [self.dLock unlock];
    if (ct) {
        ct.allLen=alllen.longLongValue;
        ct.headret(ct.tagstr, ct.allLen, ct.begin, ct.end, resp.allHeaderFields);
    }
    completionHandler(NSURLSessionResponseAllow);
}
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
                                     didReceiveData:(NSData *)data
{
    [self.dLock lock];
    for (int i=0; i<self.dArray.count; i++) {
        WTRStreamDTask *ct=self.dArray[i];
        if (ct.datatask==dataTask) {
            [self.dLock unlock];
            ct.dataret(ct.tagstr, data);
            return;
        }
    }
    [self.dLock unlock];
}
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
                                  willCacheResponse:(NSCachedURLResponse *)proposedResponse
                                  completionHandler:(void (^)(NSCachedURLResponse * _Nullable cachedResponse))completionHandler
{
    completionHandler(proposedResponse);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
                           didCompleteWithError:(nullable NSError *)error
{
    [self.dLock lock];
    for (int i=0; i<self.dArray.count; i++) {
        WTRStreamDTask *ct=self.dArray[i];
        if (ct.datatask==task) {
            [self.dArray removeObjectAtIndex:i];
            [self.dLock unlock];
            ct.completion(ct.tagstr, error);
            return;
        }
    }
    [self.dLock unlock];
}
-(void)getStream:(NSURL *)url tagstr:(NSString *)tagstr begin:(int64_t)begin end:(int64_t)end headret:(WTRStreamDHeadRet)headret dataret:(WTRStreamDDataRet)dataret completion:(WTRStreamDCompletion)completion
{
    WTRStreamDTask *ctask=[WTRStreamDTask new];
    ctask.tagstr = SafeStr(tagstr);
    ctask.begin=begin;
    ctask.end=end;
    ctask.headret = headret;
    ctask.dataret = dataret;
    ctask.completion = completion;
    
    NSMutableURLRequest *murq=[NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:10];
    
    [murq setValue:[NSString stringWithFormat:@"bytes=%lld-%lld",begin,end] forHTTPHeaderField:@"Range"];
    
    ctask.datatask=[self.urlSession dataTaskWithRequest:murq];
    
    [self.dLock lock];
    [self.dArray addObject:ctask];
    [self.dLock unlock];
    
    [ctask.datatask resume];
}

-(void)cancelTagstr:(NSString *)tagstr
{
    tagstr=SafeStr(tagstr);
    [self.dLock lock];
    for (int i=0; i<self.dArray.count; i++) {
        WTRStreamDTask *ct=self.dArray[i];
        if ([ct.tagstr isEqualToString:tagstr]) {
            [ct.datatask cancel];
        }
    }
    [self.dLock unlock];
}

@end
