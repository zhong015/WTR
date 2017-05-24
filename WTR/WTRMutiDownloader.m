//
//  WTRMutiDownloader.m
//  CnkiIPhoneClient
//
//  Created by wfz on 2017/4/7.
//  Copyright © 2017年 net.cnki.www. All rights reserved.
//

#import "WTRMutiDownloader.h"
#import "WTRBaseDefine.h"

#define WTRMutiMaxfileSize 4  //下载单个文件最大大小 k
#define WTRMutiMaxNum 5  //最多同步下载个数


@interface WTRMutiDownloader ()

@property(nonatomic,strong)NSURLSession *urlSession;

@property(nonatomic,strong)NSMutableArray *downtaskArray;
@property(nonatomic,strong)NSLock *downtasklock;


+(WTRMutiDownloader *)shareInstence;


@end



@interface CNKIDownloadTask : NSObject

@property(nonatomic,copy)NSString *tagstr;

@property(nonatomic,strong)NSData *filedata;
@property(nonatomic,assign)BOOL isDown;

@property(nonatomic,assign)long long fromindex,toindex,totalbytes,numberofFenlie;

@property(nonatomic,strong)NSURLSessionDownloadTask *downtask;

@property(nonatomic,copy)void (^retcb)(NSData * filedata,NSString *tagstr, NSError * error);

-(void)cnkiDownloadTaskWithRequest:(NSURLRequest *)request completionHandler:(void (^)(NSData * filedata,NSString *tagstr, NSError * error))completionHandler;

@end

@implementation CNKIDownloadTask

-(void)cnkiDownloadTaskWithRequest:(NSURLRequest *)request completionHandler:(void (^)(NSData * filedata,NSString *tagstr, NSError * error))completionHandler;
{
    self.retcb=completionHandler;
    self.isDown=NO;
    self.filedata=nil;
    self.downtask=[[WTRMutiDownloader shareInstence].urlSession downloadTaskWithRequest:request];
    [self.downtask resume];
}
@end


static id _s;
@implementation WTRMutiDownloader

+(WTRMutiDownloader *)shareInstence
{
    @synchronized(self){
        if (_s==nil) {
            _s=[[[self class]alloc]init];
        }
    }
    return _s;
}
-(id)init
{
    self=[super init];
    if (self) {
        NSURLSessionConfiguration* configuration= [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"net.cnki.www.CNKIClient"];
        
        configuration.HTTPMaximumConnectionsPerHost = WTRMutiMaxNum;

        self.urlSession = [NSURLSession sessionWithConfiguration:configuration delegate:(id)self delegateQueue:nil];
        
        self.downtaskArray=[NSMutableArray array];
        self.downtasklock=[[NSLock alloc] init];
    }
    return self;
}
- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
    WTRAppDelegate *appDelegate = (WTRAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if ([appDelegate respondsToSelector:@selector(backgroundSessionCompletionHandler)]) {
        if (appDelegate.backgroundSessionCompletionHandler) {
            
            void (^completionHandler)() = appDelegate.backgroundSessionCompletionHandler;
            
            appDelegate.backgroundSessionCompletionHandler = nil;
            
            completionHandler();
        }
    }
    NSLog(@"All tasks are finished");
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location
{
    if (downloadTask.state==NSURLSessionTaskStateCanceling) {
        return;
    }
    [self.downtasklock lock];
    
    for (int i=0; i<self.downtaskArray.count; i++) {
        CNKIDownloadTask *mytask=self.downtaskArray[i];
        if (mytask.downtask==downloadTask) {
            
            if (downloadTask.error) {
                [self.downtasklock unlock];
                [self removedoanloadtaskWith:mytask.tagstr];
                if (mytask.retcb) {
                    mytask.retcb(nil,mytask.tagstr,downloadTask.error);
                }
                return ;
            }

            mytask.filedata=[NSData dataWithContentsOfFile:location.path];
            mytask.isDown=YES;
            if (mytask.filedata&&mytask.filedata.length!=mytask.toindex-mytask.fromindex) {
                NSLog(@"字节错误");
            }
            [self.downtasklock unlock];
            [self hechehngDtask:mytask];
            return;
        }
    }
    [self.downtasklock unlock];
}
-(void)removedoanloadtaskWith:(NSString *)tagstr
{
    [self.downtasklock lock];
    for (int i=0; i<self.downtaskArray.count; i++) {
        CNKIDownloadTask *mytask=self.downtaskArray[i];
        if ([mytask.tagstr isEqualToString:tagstr]) {
            [self.downtaskArray removeObjectAtIndex:i];
            i--;
            [mytask.downtask cancel];
        }
    }
    [self.downtasklock unlock];
}

-(void)hechehngDtask:(CNKIDownloadTask *)mytaskcc
{
    NSMutableArray *fmuarr=[NSMutableArray array];
    
    [self.downtasklock lock];
    
    int numc=0;
    for (int i=0; i<self.downtaskArray.count; i++) {
        CNKIDownloadTask *mytask=self.downtaskArray[i];
        if ([mytask.tagstr isEqualToString:mytaskcc.tagstr]) {
            if (mytask.isDown) {
                numc++;
                [fmuarr addObject:mytask];
            }
        }
    }
    [self.downtasklock unlock];
    
    if (mytaskcc.numberofFenlie==numc) {
        
        NSMutableData *muda=[NSMutableData dataWithCapacity:0];
        
        [fmuarr sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            
            CNKIDownloadTask *mytask1=obj1;
            CNKIDownloadTask *mytask2=obj2;
            if (mytask1.fromindex<mytask2.fromindex) {
                return NSOrderedAscending;
            }
            else
                return NSOrderedDescending;
        }];

        [self.downtasklock lock];
        for (int i=0; i<fmuarr.count; i++) {
            CNKIDownloadTask *mytask=self.downtaskArray[i];
            [muda appendData:mytask.filedata];
        }
        [self.downtasklock unlock];
        
        if (mytaskcc.retcb) {
            mytaskcc.retcb(muda,mytaskcc.tagstr,nil);
        }
        
        [self removedoanloadtaskWith:mytaskcc.tagstr];
    }
}
+(CGFloat)getProgressWithTagStr:(NSString *)tagstr
{
    return [[WTRMutiDownloader shareInstence] getProgressWithTagStr:tagstr];
}
-(CGFloat)getProgressWithTagStr:(NSString *)tagstr
{
    if (!tagstr) {
        return 0.0;
    }
    long long curintd=0;
    
    [self.downtasklock lock];
    CNKIDownloadTask *lastdowntask=nil;
    for (int i=0; i<self.downtaskArray.count; i++) {
        CNKIDownloadTask *downtask=[self.downtaskArray objectAtIndex:i];
        if ([downtask.tagstr isEqualToString:tagstr]) {
            if (downtask.downtask.state==NSURLSessionTaskStateRunning&&downtask.downtask.countOfBytesExpectedToReceive>0) {
                curintd+=downtask.downtask.countOfBytesExpectedToReceive;
            }
            else if(downtask.isDown){
                curintd+=downtask.filedata.length;
            }
            lastdowntask=downtask;
        }
    }
    [self.downtasklock unlock];
    
    if (lastdowntask) {
        CGFloat progress=curintd*1.0/lastdowntask.totalbytes;
        if (isnan(progress)) {
            return 0.0;
        }
        if (progress>=0.0001&&progress<=1.0) {
            return progress;
        }
    }
    
    return 0.0;
}

+(void)downloadWithReq:(NSURLRequest *)request tagStr:(NSString *)tagstr TotalRange:(long long)total completionHandler:(void (^)(NSData * filedata,NSString *tagstr, NSError * error))completionHandler;
{
    
    long long totalbytes=total;
    
    long long foromindex=0;
    
    long long numberofFenlie=totalbytes/(WTRMutiMaxfileSize*1024-100)+1;
    
    long long jiangebt=totalbytes/numberofFenlie;
    
    for (int i=0; i<numberofFenlie; i++) {
        
        long long toindex=foromindex+jiangebt;
        
        if (i==numberofFenlie-1) {
            toindex = totalbytes;
        }
        
        NSString *acceptstr=[NSString stringWithFormat:@"bytes=%lld-%lld",foromindex,toindex];
        NSLog(@"Range:%@,,%lld---%lld   total:%lld",acceptstr,toindex-foromindex,numberofFenlie,total);
        
        NSMutableURLRequest * ssmrequ=[NSMutableURLRequest requestWithURL:request.URL];
        for (NSString *key in request.allHTTPHeaderFields) {
            [ssmrequ setValue:[request.allHTTPHeaderFields objectForKey:key] forHTTPHeaderField:key];
        }
        [ssmrequ addValue:acceptstr forHTTPHeaderField:@"Accept-Range"];
        
        [ssmrequ setHTTPMethod:@"GET"];
        
        CNKIDownloadTask *downtask=[[CNKIDownloadTask alloc]init];
        
        downtask.tagstr=tagstr;
   
        downtask.fromindex=foromindex;
        downtask.toindex=toindex;
        downtask.totalbytes=totalbytes;
        downtask.numberofFenlie=numberofFenlie;
    
        foromindex=toindex;
        
        [downtask cnkiDownloadTaskWithRequest:ssmrequ completionHandler:completionHandler];
        [[WTRMutiDownloader shareInstence].downtaskArray addObject:downtask];
    }
}

@end
