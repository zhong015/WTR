//
//  WTRZX.m
//  PocketUniversity
//
//  Created by wangfuzhong on 15/7/16.
//  Copyright (c) 2015年 CY. All rights reserved.
//

#import "WTRZX.h"
#include <ifaddrs.h>
#include <arpa/inet.h>

#import "WTRDefine.h"

@interface TextFieldLinkViewWTR : NSObject

@property(nonatomic,weak)UIView *textfiled;
@property(nonatomic,weak)UIView *transView;

@end

@implementation TextFieldLinkViewWTR

@end

@interface WTRZX ()

@property(nonatomic,strong)NSMutableArray *textfLinkArray;

@end

static id _s;
@implementation WTRZX
{
    TextFieldLinkViewWTR *curinttf;
}

+(WTRZX *)shareinstence
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

+(void)addKeyboardTransform:(UIView *)textfiledOrTextView TransView:(UIView *)view
{
    if (!textfiledOrTextView||!view) {
        return;
    }
   
    TextFieldLinkViewWTR *one=[[TextFieldLinkViewWTR alloc]init];
    one.textfiled=textfiledOrTextView;
    one.transView=view;
    [[WTRZX shareinstence].textfLinkArray addObject:one];
}
+(void)removeKeyboardTransform:(UIView *)textfiledOrTextView
{
    for (int i=0; i<[WTRZX shareinstence].textfLinkArray.count; i++) {
        TextFieldLinkViewWTR *one=[[WTRZX shareinstence].textfLinkArray objectAtIndex:i];
        if (one.textfiled==textfiledOrTextView) {
            if ([one.textfiled isFirstResponder]) {
                [one.textfiled resignFirstResponder];
                one.transView.transform=CGAffineTransformIdentity;
            }
            [[WTRZX shareinstence].textfLinkArray removeObjectAtIndex:i];
        }
    }
}

-(void)getcurintTfLink
{
    curinttf=nil;
    for (int i=0; i<[WTRZX shareinstence].textfLinkArray.count; i++) {
        TextFieldLinkViewWTR *one=[[WTRZX shareinstence].textfLinkArray objectAtIndex:i];
        if (one.textfiled&&[one.textfiled isKindOfClass:[UIView class]]&&one.textfiled.superview&&one.transView&&[one.textfiled isFirstResponder]) {
            curinttf=one;
        }
        one.transView.transform=CGAffineTransformIdentity;
    }
}
+(void)huishoujianpan
{
    [[WTRZX shareinstence] getcurintTfLink];
    if ([WTRZX shareinstence]->curinttf) {
        [[WTRZX shareinstence]->curinttf.textfiled resignFirstResponder];
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

    WTRAppDelegate *delegate = (WTRAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    CGRect rect=[curinttf.textfiled convertRect:curinttf.textfiled.bounds toView:delegate.window];
    
    CGFloat hh=ScreenHeight-rect.origin.y-rect.size.height;
    if (hh<height) {
        curinttf.transView.transform=CGAffineTransformMakeTranslation(0, -(height-hh+20));
    }
}
-(void)keyboardwillhide:(NSNotification *)noti
{
    [self getcurintTfLink];
    curinttf=nil;
}
+(CGSize)getsizeOfStr:(NSString *)str Fontsize:(UIFont *)tyfont Width:(CGFloat )ww
{
    return [WTRZX getsizeOfStr:str Attributes:@{NSFontAttributeName:tyfont} Width:ww];
}

+(CGSize)getsizeOfStr:(NSString *)str Attributes:(NSDictionary *)attributes Width:(CGFloat )ww
{
    return [str boundingRectWithSize:CGSizeMake(ww,4000) options:NSStringDrawingUsesFontLeading|NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
}
#pragma mark 计算文字栏

+(CGSize)getSizeOfStr:(NSAttributedString *)attString Size:(CGSize)size
{
    return [attString boundingRectWithSize:size options:NSStringDrawingUsesFontLeading|NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin context:nil].size;
}

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
        CGSize curtessize=[WTRZX getSizeOfStr:curtes Size:CGSizeMake(bbsize.width, 9000)];
        
        while (curtessize.height>bbsize.height) {
            NSInteger curintle=curtes.length;
//            NSLog(@"%d",curintle);
            if (curintle-1<=0) {
                break;
            }
            
            NSInteger leftnum=curintle-1;
            CGFloat bili=curtessize.height/bbsize.height;
            if (bili>1.1) {
                leftnum=curtes.length/bili;
            }
            curtes=[curtes attributedSubstringFromRange:NSMakeRange(0,leftnum)];
            curtessize=[WTRZX getSizeOfStr:curtes Size:CGSizeMake(bbsize.width, 9000)];
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

+(void)showmsge:(NSString *)msg
{
    [WTRZX showmsge:msg time:1];
}
+(void)showmsge:(NSString *)msg time:(NSTimeInterval )timint
{
    if (!msg||![msg isKindOfClass:[NSString class]]) {
        return;
    }
    
    UILabel *showmsgla=[UILabel new];
    showmsgla.textColor=[UIColor whiteColor];//UIColorFromRGB(0x999999);
    showmsgla.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.9];
    showmsgla.textAlignment=NSTextAlignmentCenter;
    showmsgla.text=msg;
    showmsgla.numberOfLines=0;
    showmsgla.font=[UIFont systemFontOfSize:15];
    LayerMakeCorner(showmsgla, 5);
    
    WTRAppDelegate *delegate = (WTRAppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate.window addSubview:showmsgla];
    showmsgla.alpha=0;
    
    CGSize ss=[WTRZX getsizeOfStr:msg Fontsize:showmsgla.font Width:ScreenWidth-20];
    
    ss.height=ss.width;
    if (ss.height>80) {
        ss.height=80;
    }
    
    CGFloat jww=(ScreenWidth-ss.width-20)/2.0,jhh=(ScreenHeight-ss.height-20)/2.0;
    
    showmsgla.frame=CGRectMake(jww, jhh-50, ss.width+20, ss.height+20);
    
    [UIView animateWithDuration:0.25 animations:^{
        showmsgla.alpha=1;
    }completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 delay:timint options:UIViewAnimationOptionCurveEaseIn animations:^{
            showmsgla.alpha=0.1;
        } completion:^(BOOL finished) {
            [showmsgla removeFromSuperview];
        }];
    }];
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
    
    if (timeinterv>60*60*24*7||day>6) {
        NSDateFormatter *fmt3=[[NSDateFormatter alloc]init];
        [fmt3 setLocale:locale];
        [fmt3 setTimeZone:timezone];
        [fmt3 setDateFormat:@"dd/MM/yy"];
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
+ (NSString *)getIPAddress
{
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0)
    {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while (temp_addr != NULL)
        {
            if (temp_addr->ifa_addr->sa_family == AF_INET)
            {
                // Check if interface is en0 which is the wifi connection on the iPhone
                NSString *interfaceName = [NSString stringWithUTF8String:temp_addr->ifa_name];
                if ([interfaceName isEqualToString:@"en0"] || [interfaceName isEqualToString:@"en1"])
                {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    // Free memory
    freeifaddrs(interfaces);
    return address;
}

#pragma mark 清除缓存
+(void)clearAllCaches
{
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

@end
