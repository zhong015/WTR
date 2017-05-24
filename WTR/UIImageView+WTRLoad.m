//
//  UIImageView+WTRLoad.m
//  asdasd
//
//  Created by wfz on 16/9/13.
//  Copyright © 2016年 wfz. All rights reserved.
//

#import "UIImageView+WTRLoad.h"
#import "WTRDefine.h"

@interface WTRImageLoadOb : NSObject

@property(nonatomic,strong)NSMutableArray <UIImageView *>* imvArray; //需要加载图片的imv
@property(nonatomic,strong)NSURLSessionDownloadTask *downTask;

@property(nonatomic,copy)NSString *urlstr;
@property(nonatomic,assign)long long datalength;
@property(nonatomic,strong)UIImage *im;

@end

@interface WTRLoad :NSObject <NSURLSessionDelegate>

@property(nonatomic,strong)NSURLSession *urlsession;
@property(nonatomic,strong)NSMutableArray *loadArray;
@property(nonatomic,strong)NSLock *loadArraylock;

@property(nonatomic,strong)NSMutableArray *ImMemeArray;
+ (dispatch_queue_t)WTRImageLoadQueue;

+(WTRLoad *)shareInstence;
-(void)addOneWTRImageLoadWithImageV:(UIImageView *)imv imstr:(NSString *)imstr placeholder:(UIImage *)placeholder;
- (void)CancelCurintImageLoad:(UIImageView *)imv;

@end

@implementation WTRImageLoadOb

-(id)initWithUrlStr:(NSString *)urlstr ischeck:(BOOL)ischeck
{
    self=[super init];
    if (self) {
        self.datalength=-1;
        
        self.urlstr=urlstr;
        self.imvArray=[NSMutableArray array];
        if (ischeck) {
            NSMutableURLRequest *req=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlstr]];
            [req setHTTPMethod:@"HEAD"];
            self.downTask=[[WTRLoad shareInstence].urlsession downloadTaskWithRequest:req];
        }
        else
            self.downTask=[[WTRLoad shareInstence].urlsession downloadTaskWithURL:[NSURL URLWithString:urlstr]];
        [self.downTask resume];
    }
    return self;
}
-(void)reloadurlstr
{
    self.downTask=[[WTRLoad shareInstence].urlsession downloadTaskWithURL:[NSURL URLWithString:self.urlstr]];
    [self.downTask resume];
}
- (void)CancelCurintImageLoad
{
    [self.downTask cancel];
    [self.imvArray removeAllObjects];
}

@end


@implementation UIImageView (WTRLoad)

- (void)setImageWTRLoadWithURLStr:(NSString *)imageURLStr
{
    [self setImagWTRLoadeWithURLStr:imageURLStr placeholder:nil];
}
- (void)setImagWTRLoadeWithURLStr:(NSString *)imageURLStr placeholder:(UIImage *)placeholder
{
    __WEAKSelf
    dispatch_async([WTRLoad WTRImageLoadQueue], ^{
        [[WTRLoad shareInstence] addOneWTRImageLoadWithImageV:weakSelf imstr:imageURLStr placeholder:placeholder];
    });
}
- (void)CancelWTRLoadCurintImageLoad
{
    [[WTRLoad shareInstence] CancelCurintImageLoad:self];
}
+(void)clearImageWTRLoadCacheWithURLStr:(NSString *)imageURLStr
{
    if (ISString(imageURLStr)) {
        NSString *filename=[[imageURLStr dataUsingEncoding:NSUTF8StringEncoding] md5jiami];
        NSString *filepath=[[WTRFilePath getCachePath] stringByAppendingPathComponent:filename];
        [[NSFileManager defaultManager]removeItemAtPath:filepath error:nil];
    }
}
@end

static id _s;
@implementation WTRLoad

+(WTRLoad *)shareInstence
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
        self.loadArray=[NSMutableArray array];
        self.loadArraylock=[[NSLock alloc]init];
        self.ImMemeArray=[NSMutableArray array];
        
        self.urlsession=[NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue new]];
    }
    return self;
}

+ (dispatch_queue_t)WTRImageLoadQueue {
    static dispatch_queue_t queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("WTRImageLoad", DISPATCH_QUEUE_SERIAL);
        dispatch_set_target_queue(queue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0));
    });
    return queue;
}

-(void)setimvImage:(NSDictionary *)dic
{
    UIImageView *imv=[dic objectForKey:@"imv"];
    UIImage *im=[dic objectForKey:@"im"];
    imv.image=im;
}
-(void)addOneWTRImageLoadWithImageV:(UIImageView *)imv imstr:(NSString *)imstr placeholder:(UIImage *)placeholder
{
    BOOL ischeck=YES;
    long long datalength=-1;
    
    UIImage *im=[self getimagewithkey:imstr];
    if (im) {
         [self performSelectorOnMainThread:@selector(setimvImage:) withObject:@{@"imv":imv,@"im":im} waitUntilDone:YES modes:@[NSRunLoopCommonModes]];
    }
    else
    {
        NSString *filename=[[imstr dataUsingEncoding:NSUTF8StringEncoding] md5jiami];
        NSString *filepath=[[WTRFilePath getCachePath] stringByAppendingPathComponent:filename];
        if ([[NSFileManager defaultManager] fileExistsAtPath:filepath]) {
            NSData *da=[NSData dataWithContentsOfFile:filepath];
            datalength=da.length;
            UIImage *im=[UIImage imageWithData:da scale:[UIScreen mainScreen].scale];
            
            WTRImageLoadOb *one=[[WTRImageLoadOb alloc]init];
            one.im=im;
            one.urlstr=imstr;
            [self setImMemeArraywith:one];
            
            [self performSelectorOnMainThread:@selector(setimvImage:) withObject:@{@"imv":imv,@"im":im} waitUntilDone:YES modes:@[NSRunLoopCommonModes]];
        }
        else if (placeholder) {
            ischeck=NO;
            [self performSelectorOnMainThread:@selector(setimvImage:) withObject:@{@"imv":imv,@"im":placeholder} waitUntilDone:YES modes:@[NSRunLoopCommonModes]];
        }
    }
    
    [self clearimvFrome:imv];
    if (ISString(imstr)) {
        [self.loadArraylock lock];
        
        for (int i=0; i<self.loadArray.count; i++) {
            WTRImageLoadOb *one=self.loadArray[i];
            if ([imstr isEqualToString:one.downTask.currentRequest.URL.absoluteString]) {
                [one.imvArray addObject:imv];
                [self.loadArraylock unlock];
                return;
            }
        }
        WTRImageLoadOb *one=[[WTRImageLoadOb alloc] initWithUrlStr:imstr ischeck:ischeck];
        one.datalength=datalength;
        [one.imvArray addObject:imv];
        [self.loadArray addObject:one];
        
        [self.loadArraylock unlock];
        return;
    }
}
-(void)clearimvFrome:(UIImageView *)imv
{
    [self.loadArraylock lock];
    
    for (int i=0; i<self.loadArray.count; i++) {
        WTRImageLoadOb *one=self.loadArray[i];
        for (int j=0; j<one.imvArray.count; j++) {
            UIImageView *cimv=one.imvArray[j];
            if (cimv==imv) {
                [one.imvArray removeObjectAtIndex:j];
                [self.loadArraylock unlock];
                return;
            }
        }
    }
    [self.loadArraylock unlock];
}
- (void)CancelCurintImageLoad:(UIImageView *)imv
{
    [self.loadArraylock lock];
    
    for (int i=0; i<self.loadArray.count; i++) {
        WTRImageLoadOb *one=self.loadArray[i];
        for (int j=0; j<one.imvArray.count; j++) {
            UIImageView *cimv=one.imvArray[j];
            if (cimv==imv) {
                [one CancelCurintImageLoad];
                [self.loadArray removeObjectAtIndex:i];
                [self.loadArraylock unlock];
                return;
            }
        }
    }
    [self.loadArraylock unlock];
}
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location
{
    NSData *da=[NSData dataWithContentsOfFile:location.path];
    UIImage *im=[UIImage imageWithData:da scale:[UIScreen mainScreen].scale];
    
    [self.loadArraylock lock];

    for (int i=0; i<self.loadArray.count; i++) {
        WTRImageLoadOb *one=self.loadArray[i];
        if (one.downTask==downloadTask) {
            if (im) {
                NSString *filename=[[one.downTask.currentRequest.URL.absoluteString dataUsingEncoding:NSUTF8StringEncoding] md5jiami];
                NSString *filepath=[[WTRFilePath getCachePath] stringByAppendingPathComponent:filename];
                [da writeToFile:filepath atomically:YES];
                one.im=im;
                [self performSelectorOnMainThread:@selector(setimgeVarr:) withObject:one waitUntilDone:YES modes:@[NSRunLoopCommonModes]];
            }
            else if(one.datalength>0)
            {
                NSString *ContentLength=[((NSHTTPURLResponse *)downloadTask.response).allHeaderFields objectForKey:@"Content-Length"];
                
                if (ISNumberStr(ContentLength)) {
                    long long ClongLongValue=ContentLength.longLongValue;
                    if (ClongLongValue!=one.datalength&&ClongLongValue>0) {
                        [one reloadurlstr];
                        [self.loadArraylock unlock];
                        return;
                    }
                }
            }
            [one CancelCurintImageLoad];
            [self.loadArray removeObjectAtIndex:i];
            [self.loadArraylock unlock];
            return;
        }
    }
    
    [self.loadArraylock unlock];
}
-(void)setimgeVarr:(WTRImageLoadOb *)one
{
    for (int j=0; j<one.imvArray.count; j++) {
        UIImageView *cimv=one.imvArray[j];
        if (cimv&&[cimv isKindOfClass:[UIImageView class]]) {
            cimv.image=one.im;
        }
    }
}
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error
{
    [self.loadArraylock lock];
    for (int i=0; i<self.loadArray.count; i++) {
        WTRImageLoadOb *one=self.loadArray[i];
        if (one.downTask==task) {
            [one CancelCurintImageLoad];
            [self.loadArray removeObjectAtIndex:i];
            
            [self.loadArraylock unlock];
            return;
        }
    }
    [self.loadArraylock unlock];
}
-(UIImage *)getimagewithkey:(NSString *)key
{
    for (int i=0; i<self.ImMemeArray.count; i++) {
        WTRImageLoadOb *one=self.ImMemeArray[i];
        if ([one.urlstr isEqualToString:key]) {
            return one.im;
        }
    }
    return nil;
}
-(void)setImMemeArraywith:(WTRImageLoadOb *)one
{
    if (!one.im||!ISString(one.urlstr)) {
        return;
    }
    for (int i=0; i<self.ImMemeArray.count; i++) {
        WTRImageLoadOb *cone=self.ImMemeArray[i];
        if ([cone.urlstr isEqualToString:one.urlstr]) {
            [self.ImMemeArray removeObjectAtIndex:i];
            break;
        }
    }
    [self.ImMemeArray insertObject:one atIndex:0];
    if (self.ImMemeArray.count>15) {
        [self.ImMemeArray removeLastObject];
    }
}
@end
