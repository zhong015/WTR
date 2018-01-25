//
//  WTR.m
//  WTRGitCs
//
//  Created by wfz on 2017/5/24.
//  Copyright © 2017年 wfz. All rights reserved.
//

#import "WTR.h"
#include <ifaddrs.h>
#include <arpa/inet.h>
#include <net/if.h>
#import "WTRBaseDefine.h"

#import <CommonCrypto/CommonCrypto.h>

@interface TextFieldLinkViewWTR : NSObject

@property(nonatomic,weak)UIView <UIKeyInput>* textfiled;
@property(nonatomic,weak)UIView *transView;
@property(nonatomic,assign)CGFloat adh;

@end

@implementation TextFieldLinkViewWTR

@end

@interface WTR ()

@property(nonatomic,strong)NSMutableArray *textfLinkArray;

@end

static id _s;
@implementation WTR
{
    TextFieldLinkViewWTR *curinttf;
}

+(WTR *)shareinstence
{
    @synchronized(self){
        if (_s==nil) {
            _s=[[[self class]alloc]init];
        }
    }
    return _s;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}
-(id)init
{
    self=[super init];
    if (self) {
        self.textfLinkArray=[NSMutableArray arrayWithCapacity:0];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardwillshow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardwillhide:) name:UIKeyboardWillHideNotification object:nil];
        
    }
    return self;
}

+(void)addKeyboardTransform:(UIView <UIKeyInput>*)textfiledOrTextView TransView:(UIView *)view
{
    [self addKeyboardTransform:textfiledOrTextView TransView:view addHeight:0.0];
}
+(void)addKeyboardTransform:(UIView <UIKeyInput>*)textfiledOrTextView TransView:(UIView *)view addHeight:(CGFloat )adh
{
    if (!textfiledOrTextView||!view) {
        return;
    }
    TextFieldLinkViewWTR *one=[[TextFieldLinkViewWTR alloc]init];
    one.textfiled=textfiledOrTextView;
    one.transView=view;
    one.adh=adh;
    [[WTR shareinstence].textfLinkArray addObject:one];
}
+(void)removeKeyboardTransform:(id <UIKeyInput>)textfiledOrTextView
{
    for (int i=0; i<[WTR shareinstence].textfLinkArray.count; i++) {
        TextFieldLinkViewWTR *one=[[WTR shareinstence].textfLinkArray objectAtIndex:i];
        if (one.textfiled==textfiledOrTextView) {
            if ([one.textfiled isFirstResponder]) {
                [one.textfiled resignFirstResponder];
                one.transView.transform=CGAffineTransformIdentity;
            }
            [[WTR shareinstence].textfLinkArray removeObjectAtIndex:i];
        }
    }
}
-(void)getcurintTfLink
{
    curinttf=nil;
    for (int i=0; i<[WTR shareinstence].textfLinkArray.count; i++) {
        TextFieldLinkViewWTR *one=[[WTR shareinstence].textfLinkArray objectAtIndex:i];
        if (one.textfiled&&[one.textfiled isKindOfClass:[UIView class]]&&one.textfiled.superview&&one.transView&&[one.textfiled isFirstResponder]) {
            curinttf=one;
        }
        one.transView.transform=CGAffineTransformIdentity;
    }
}
+(void)huishoujianpan
{
    [[WTR shareinstence] getcurintTfLink];
    if ([WTR shareinstence]->curinttf) {
        [[WTR shareinstence]->curinttf.textfiled resignFirstResponder];
    }
}
#pragma mark 键盘消息
-(void)keyboardwillshow:(NSNotification *)noti
{
    [self getcurintTfLink];
    
    if (!curinttf) {
        return;
    }
    
    CGFloat height=[[noti.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    if (height<0.2) {
        return;
    }
    
    height=height+curinttf.adh;
    
    WTRAppDelegate *delegate = (WTRAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    CGRect rect=[curinttf.textfiled convertRect:curinttf.textfiled.bounds toView:delegate.window];
    
    CGFloat hh=ScreenHeight-rect.origin.y-rect.size.height;
    if (hh<height) {
        if ([curinttf.transView isKindOfClass:[UIScrollView class]]) {
            UIScrollView *scrolv=(UIScrollView *)curinttf.transView;
            [scrolv setContentOffset:CGPointMake(0, scrolv.contentOffset.y+(height-hh+20)) animated:YES];
        }else{
            curinttf.transView.transform=CGAffineTransformMakeTranslation(0, -(height-hh+20));
        }
    }
}
-(void)keyboardwillhide:(NSNotification *)noti
{
    [self getcurintTfLink];
    curinttf=nil;
}

#pragma mark 计算文字大小
+(CGSize)getsizeOfStr:(NSString *)str Fontsize:(UIFont *)tyfont Width:(CGFloat )ww
{
    return [WTR getsizeOfStr:str Attributes:@{NSFontAttributeName:tyfont} Width:ww];
}
+(CGSize)getsizeOfStr:(NSString *)str Attributes:(NSDictionary *)attributes Width:(CGFloat )ww
{
    return [str boundingRectWithSize:CGSizeMake(ww,4000) options:NSStringDrawingUsesFontLeading|NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
}
+(CGSize)getSizeOfStr:(NSAttributedString *)attString Size:(CGSize)size
{
    return [attString boundingRectWithSize:size options:NSStringDrawingUsesFontLeading|NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin context:nil].size;
}

#pragma mark 计算文字栏
+(NSArray *)getPagesAttributedString:(NSAttributedString *)attString size:(CGSize)bbsize
{
    if (!attString||![attString isKindOfClass:[NSAttributedString class]]||attString.length==0) {
        return nil;
    }
    NSMutableArray *muarr=[NSMutableArray arrayWithCapacity:0];
    
    NSInteger attrlength=attString.length;
    NSInteger curintb=0;
    
    while (curintb<attrlength) {
        NSAttributedString *curtes=[attString attributedSubstringFromRange:NSMakeRange(curintb, attrlength-curintb)];
        CGSize curtessize=[WTR getSizeOfStr:curtes Size:CGSizeMake(bbsize.width, 9000)];
        
        while (curtessize.height>bbsize.height) {
            NSInteger curintle=curtes.length;
            if (curintle-1<=0) {
                break;
            }
            NSInteger leftnum=curintle-1;
            CGFloat bili=curtessize.height/bbsize.height;
            if (bili>1.1) {
                leftnum=curtes.length/bili;
            }
            curtes=[curtes attributedSubstringFromRange:NSMakeRange(0,leftnum)];
            curtessize=[WTR getSizeOfStr:curtes Size:CGSizeMake(bbsize.width, 9000)];
        }
        if (curtes.length>0) {
            NSRange cra=NSMakeRange(curintb, curtes.length);
            curintb=curintb+curtes.length;
            NSValue *value=[NSValue valueWithRange:cra];
            [muarr addObject:value];
        }
        else
        {
            NSLog(@"errorAttString");
            return nil;
        }
    }
    if (curintb==attrlength) {
        NSLog(@"解析成功");
    }
    return muarr;
}

+ (NSDate *)dateWithISOFormatString:(NSString *)dateString {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
    return [formatter dateFromString:dateString];
}

+ (NSDate *)dateWithISOFormatStringZ:(NSString *)dateString {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
    return [formatter dateFromString:dateString];
}

+ (NSString *)timestringof:(NSDate *)date
{
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];//设置为中文显示
    NSTimeZone *timezone=[NSTimeZone systemTimeZone];//系统时区
    
    NSDateFormatter *datef=[[NSDateFormatter alloc]init];
    [datef setLocale:locale];
    [datef setTimeZone:timezone];
    [datef setDateFormat:@"d"];
    
    int day=ABS([datef stringFromDate:date].intValue-[datef stringFromDate:[NSDate date]].intValue);
    
    NSTimeInterval timeinterv=ABS([[NSDate date] timeIntervalSinceDate:date]);
    
    if (timeinterv>60*60*24*364||day>364) {
        NSDateFormatter *fmt3=[[NSDateFormatter alloc]init];
        [fmt3 setLocale:locale];
        [fmt3 setTimeZone:timezone];
        [fmt3 setDateFormat:@"yyyy年M月d日"];
        return [fmt3 stringFromDate:date];
    }
    else if (timeinterv>60*60*24*7||day>6) {
        NSDateFormatter *fmt3=[[NSDateFormatter alloc]init];
        [fmt3 setLocale:locale];
        [fmt3 setTimeZone:timezone];
        [fmt3 setDateFormat:@"M月d日"];
        return [fmt3 stringFromDate:date];
    }
    else if(timeinterv>60*60*24*2||day>=2)
    {
        NSDateFormatter *fmt3=[[NSDateFormatter alloc]init];
        [fmt3 setLocale:locale];
        [fmt3 setTimeZone:timezone];
        [fmt3 setDateFormat:@"EEEE"];//星期五
        return [fmt3 stringFromDate:date];
    }
    else if(timeinterv>60*60*24||day>0)
    {
        return @"昨天";
    }
    else
    {
        if (timeinterv>60) {
            NSDateFormatter *fmt1=[[NSDateFormatter alloc]init];
            [fmt1 setLocale:locale];
            [fmt1 setTimeZone:timezone];
            [fmt1 setDateFormat:@"aa h:mm"];
            return [fmt1 stringFromDate:date];
        }
        return [NSString stringWithFormat:@"%d秒前",(int)ABS(timeinterv)];
    }
}

+ (BOOL)isContainsEmoji:(NSString *)string {
    __block BOOL isEomji = NO;
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        const unichar hs = [substring characterAtIndex:0];
        // surrogate pair
        if (0xd800 <= hs && hs <= 0xdbff) {
            if (substring.length > 1) {
                const unichar ls = [substring characterAtIndex:1];
                const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                if (0x1d000 <= uc && uc <= 0x1f77f) {
                    isEomji = YES;
                }
            }
        } else {
            // non surrogate
            if (0x2100 <= hs && hs <= 0x27ff && hs != 0x263b) {
                isEomji = YES;
            } else if (0x2B05 <= hs && hs <= 0x2b07) {
                isEomji = YES;
            } else if (0x2934 <= hs && hs <= 0x2935) {
                isEomji = YES;
            } else if (0x3297 <= hs && hs <= 0x3299) {
                isEomji = YES;
            } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50|| hs == 0x231a ) {
                isEomji = YES;
            }
            if (!isEomji && substring.length > 1) {
                const unichar ls = [substring characterAtIndex:1];
                if (ls == 0x20e3) {
                    isEomji = YES;
                }
            }
        }
    }];
    return isEomji;
}
+ (BOOL)version:(NSString *)_oldver lessthan:(NSString *)_newver
{
    if ([_oldver compare:_newver options:NSNumericSearch] == NSOrderedAscending)
    {
        return YES;
    }
    return NO;
}

//验证QQ
+ (BOOL)isQQNum:(NSString *)QQNum;
{
    if (!QQNum||![QQNum isKindOfClass:[NSString class]]) {
        return NO;
    }
    
    NSString *CM= @"^[0-9]{4,13}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",CM];
    BOOL isMatch = [pred evaluateWithObject:QQNum];
    return isMatch;
}
//验证手机号
+ (BOOL)isPhoneNum:(NSString *)phoneNum;
{
    if (!phoneNum||![phoneNum isKindOfClass:[NSString class]]||phoneNum.length!=11) {
        return NO;
    }
    
    NSString *CM= @"^1[3|4|5|7|8][0-9]{9}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",CM];
    BOOL isMatch = [pred evaluateWithObject:phoneNum];
    return isMatch;
}
+(BOOL)isEmail:(NSString *)email
{
    if (!email||![email isKindOfClass:[NSString class]]) {
        return NO;
    }
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}
+(BOOL)isNeedURLEncoding:(NSString *)inurlstr
{
    /*
     RFC 3986                   URI Generic Syntax               January 2005
     
     reserved    = gen-delims / sub-delims
     
     gen-delims  = ":" / "/" / "?" / "#" / "[" / "]" / "@"
     
     sub-delims  = "!" / "$" / "&" / "'" / "(" / ")"
     / "*" / "+" / "," / ";" / "="
     
     uric           | unreserved / pct-encoded / ";" / "?" / ":"       |
     |                |  / "@" / "&" / "=" / "+" / "$" / "," / "/"       |
     |                |                                                  |
     | uric_no_slash  | unreserved / pct-encoded / ";" / "?" / ":"       |
     |                |  / "@" / "&" / "=" / "+" / "$" / ","             |
     |                |                                                  |
     | mark           | "-" / "_" / "." / "!" / "~" / "*" / "'"          |
     |                |  / "(" / ")"
     
     
     ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_.~!*'();:@&=+$,/?#[] //允许的字符
     
     */
    if (!inurlstr||![inurlstr isKindOfClass:[NSString class]]||inurlstr.length==0) {
        NSLog(@"inurlstr 输入错误");
        return NO;
    }
    NSString *yxstr=@"-_.~!*'();:@&=+$,/?#[]";//允许的特殊字符
    BOOL isneed=NO;
    for (int i=0; i<inurlstr.length; i++) {
        unichar c=[inurlstr characterAtIndex:i];
        if ((c>='A'&&c<='Z')||(c>='a'&&c<='z')||(c>='0'&&c<='9')) {
            continue;
        }
        BOOL istsyz=NO;
        for (int j=0; j<yxstr.length; j++) {
            unichar yc=[yxstr characterAtIndex:j];
            if (yc==c) {
                istsyz=YES;
                break;
            }
        }
        if (istsyz) {
            continue;
        }
        if (c=='%') {
            if (i+2<inurlstr.length) {
                unichar c1=[inurlstr characterAtIndex:i+1];
                unichar c2=[inurlstr characterAtIndex:i+2];
                if (((c1>='0'&&c1<='9')||(c1>='A'&&c1<='F')||(c1>='a'&&c1<='f'))&&((c2>='0'&&c2<='9')||(c2>='A'&&c2<='F')||(c2>='a'&&c2<='f'))) {
                    continue;
                }
            }
        }
        isneed=YES;
        break;
    }
    return isneed;
}

//搭个服务器，以php为例，输出 $_SERVER['REMOTE_ADDR'] 就是用户的外网IP了（如果要考虑代理服务器的情况就稍微麻烦点）
+(NSString *)getIPAddress
{
    NSDictionary *addresses = [self getIPAddresses];
    NSLog(@"addresses: %@", addresses);
    
    NSString *address=nil;
    
    //ipv6
    for (NSString *key in addresses.allKeys) {
        NSString *ipdz=addresses[key];
        if ([key hasPrefix:@"en"]&&[key rangeOfString:@"ipv6"].length>0) {
            if ([ipdz hasPrefix:@"fe80"]) {
                continue;
            }
            address=ipdz;
            break;
        }
    }
    if (address) {
        return address;
    }
    
    //ipv4
    for (NSString *key in addresses.allKeys) {
        NSString *ipdz=addresses[key];
        if ([key hasPrefix:@"en"]&&[ipdz hasPrefix:@"192.168"]) {
            address=ipdz;
            break;
        }
    }
    
    if (address) {
        return address;
    }
    
    for (NSString *key in addresses.allKeys) {
        NSString *ipdz=addresses[key];
        if ([ipdz hasPrefix:@"192.168"]) {
            address=ipdz;
            break;
        }
    }
    if (address) {
        return address;
    }
    
    for (NSString *key in addresses.allKeys) {
        NSString *ipdz=addresses[key];
        if ([key rangeOfString:@"ipv4"].length>0) {
            if ([ipdz isEqualToString:@"127.0.0.1"]||[ipdz hasPrefix:@"169.254"]) {
                continue;
            }
            address=ipdz;
            break;
        }
    }
    if (address) {
        return address;
    }
    
    //ipv6
    for (NSString *key in addresses.allKeys) {
        NSString *ipdz=addresses[key];
        if ([key rangeOfString:@"ipv6"].length>0) {
            if ([ipdz hasPrefix:@"fe80"]) {
                continue;
            }
            address=ipdz;
            break;
        }
    }
    
    return address;
}

+(NSDictionary *)getIPAddresses
{
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
    
    // retrieve the current interfaces - returns 0 on success
    struct ifaddrs *interfaces;
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        struct ifaddrs *interface;
        for(interface=interfaces; interface; interface=interface->ifa_next) {
            if(!(interface->ifa_flags & IFF_UP) /* || (interface->ifa_flags & IFF_LOOPBACK) */ ) {
                continue; // deeply nested code harder to read
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
            char addrBuf[ MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN) ];
            if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                NSString *type;
                if(addr->sin_family == AF_INET) {
                    if(inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
                        type = @"ipv4";
                    }
                } else {
                    const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6*)interface->ifa_addr;
                    if(inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
                        type = @"ipv6";
                    }
                }
                if(type) {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
                }
            }
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    return [addresses count] ? addresses : nil;
}


#pragma mark 清除缓存
+(void)clearAllCaches
{
    /*
     AF 需要提前运行这两个
     [[UIImageView sharedImageDownloader].imageCache removeAllImages];
     [[UIImageView sharedImageDownloader].sessionManager.session.configuration.URLCache removeAllCachedResponses];  //单个移除不管用从iOS8.0之后
     */
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    NSFileManager *manager=[NSFileManager defaultManager];
    NSString * cachespath=[NSHomeDirectory() stringByAppendingString:@"/Library/Caches"];
    NSArray * array2=[manager subpathsAtPath:cachespath];
    for (NSString*str in array2) {
        NSString *path=[cachespath stringByAppendingPathComponent:str];
        BOOL isdicr,isz;
        isz=[manager fileExistsAtPath:path isDirectory:&isdicr];
        if (!isdicr&&isz) {
            if ([str rangeOfString:@"Snapshots"].length>0||[str rangeOfString:@"LaunchImages"].length>0) {
                continue;
            }
            NSError *err;
            BOOL isyes= [manager removeItemAtPath:path error:&err];
            NSLog(@"清理%d:%@",isyes,str);
            if (!isyes) {
                NSLog(@"%@",err);
            }
        }
    }
}
+(NSString *)AllCachesSize
{
    NSString * cachesPath=[NSHomeDirectory() stringByAppendingString:@"/Library/Caches"];
    return [NSString stringWithFormat:@"%.1f M",[self folderSizeAtPath:cachesPath]];
}

//文件夹内文件大小
+ (float)folderSizeAtPath:(NSString*) folderPath
{
    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folderPath]) return 0;
    
    NSArray *arr=[manager subpathsAtPath:folderPath];
    
    NSEnumerator *childFilesEnumerator = [arr objectEnumerator];//从前向后枚举器
    NSString* fileName;
    long long folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        
        if ([fileName rangeOfString:@"Snapshots"].length>0||[fileName rangeOfString:@"LaunchImages"].length>0) {
            continue;
        }
        
        NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        folderSize += [self fileSizeAtPath:fileAbsolutePath];
    }
    return folderSize/(1024.0*1024.0);
}

+ (CGFloat) getFileSize:(NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    float filesize = -1.0;
    if ([fileManager fileExistsAtPath:path]) {
        NSDictionary *fileDic = [fileManager attributesOfItemAtPath:path error:nil];
        unsigned long long size = [[fileDic objectForKey:NSFileSize] longLongValue];
        filesize = 1.0*size/1024.0/1024.0;
    }
    return filesize;
}
+ (long long) fileSizeAtPath:(NSString*) filePath
{
    NSFileManager* manager = [NSFileManager defaultManager];
    BOOL isdicr;
    BOOL isz=[manager fileExistsAtPath:filePath isDirectory:&isdicr];
    if (!isdicr&&isz){
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}

+(UIViewController *)curintViewController
{
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    UIViewController *topViewController = [window rootViewController];
    while (true) {
        if (topViewController.presentedViewController&&![topViewController.presentedViewController isKindOfClass:[UIAlertController class]]) {
            topViewController = topViewController.presentedViewController;
        } else if ([topViewController isKindOfClass:[UINavigationController class]] && [(UINavigationController*)topViewController topViewController]) {
            topViewController = [(UINavigationController *)topViewController topViewController];
        } else if ([topViewController isKindOfClass:[UITabBarController class]]) {
            UITabBarController *tab = (UITabBarController *)topViewController;
            topViewController = tab.selectedViewController;
        } else {
            break;
        }
    }
    return topViewController;
}

//+(UIViewController *)curintViewController
//{
//    WTRAppDelegate *appdele=(WTRAppDelegate *)[UIApplication sharedApplication].delegate;
//
//    return [self curintViewControllerWith:appdele.window.rootViewController];
//}
//+(UIViewController *)curintViewControllerWith:(UIViewController *)viewController
//{
//    UITabBarController *cutabc=(UITabBarController *)viewController;
//    if ([cutabc isKindOfClass:[UITabBarController class]]) {
//        return [self curintViewControllerWith:cutabc.viewControllers[cutabc.selectedIndex]];
//    }
//    else if ([cutabc isKindOfClass:[UINavigationController class]]){
//        return [self curintViewControllerWith:[cutabc.viewControllers lastObject]];
//    }
//    else if(cutabc.presentedViewController&&![cutabc.presentedViewController isKindOfClass:[UIAlertController class]]){
//        return [self curintViewControllerWith:cutabc.presentedViewController];
//    }else {
//        return cutabc;
//    }
//}

@end


@implementation NSData (WTRMDJiaMi)

-(NSString *)md5jiami
{
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5([self bytes], (CC_LONG)[self length], result);
    
    return [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ]; //lowercaseString] 小写
}
@end

