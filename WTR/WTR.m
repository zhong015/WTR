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
#import <sqlite3.h>
#import <CommonCrypto/CommonCrypto.h>
#import <WebKit/WebKit.h>

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
+(BOOL)huishoujianpan
{
    [[WTR shareinstence] getcurintTfLink];
    if ([WTR shareinstence]->curinttf) {
        if ([[WTR shareinstence]->curinttf.textfiled isFirstResponder]) {
            [[WTR shareinstence]->curinttf.textfiled resignFirstResponder];
            return YES;
        }
    }
    return NO;
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

    CGRect rect=[curinttf.textfiled convertRect:curinttf.textfiled.bounds toView:[UIApplication sharedApplication].delegate.window];
    
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

+(NSDate *)dateWithISOFormatString:(NSString *)dateString {
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
        formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
    });
    return [formatter dateFromString:dateString];
}
+(NSString *)ISOFormatStringWithDate:(NSDate *)date {
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
        formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
    });
    return [formatter stringFromDate:date];
}
+(NSDate *)dateWithISOFormatStringZ:(NSString *)dateString {
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
        formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
    });
    return [formatter dateFromString:dateString];
}
+(NSString *)ISOFormatStringZWithDate:(NSDate *)date {
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
        formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
    });
    return [formatter stringFromDate:date];
}

+(NSString *)timestringof:(NSDate *)date
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

+(BOOL)isContainsEmoji:(NSString *)string {
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
+(BOOL)version:(NSString *)_oldver lessthan:(NSString *)_newver
{
    if ([_oldver compare:_newver options:NSNumericSearch] == NSOrderedAscending)
    {
        return YES;
    }
    return NO;
}

//验证QQ
+(BOOL)isQQNum:(NSString *)QQNum;
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
+(BOOL)isPhoneNum:(NSString *)phoneNum;
{
    if (!phoneNum||![phoneNum isKindOfClass:[NSString class]]||phoneNum.length!=11) {
        return NO;
    }
    
    NSString *CM= @"^1[0-9]{10}$";
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

+(uint16_t)getFreePortWithBasePort:(uint16_t)basePort
{
    for (int i=basePort; i<65536; i++) {
        if (![self isAlreadyBindPort:i]) {
            return i;
        }
    }
    return basePort;
}
+(BOOL)isAlreadyBindPort:(uint16_t)port
{
    struct sockaddr_in servaddr;
    int cfd = socket(AF_INET, SOCK_STREAM, 0);
    if (cfd<0) {
        NSLog(@"创建socket失败\n");
        return YES;
    }
    bzero(&servaddr, sizeof(servaddr));
    servaddr.sin_family = AF_INET;
    servaddr.sin_addr.s_addr = htonl(INADDR_ANY);
    servaddr.sin_port = htons(port);
    int bindret=bind(cfd, (struct sockaddr *)&servaddr, sizeof(servaddr));
    if (bindret<0) {
        NSLog(@"已占用端口:%d\n",port);
        return YES;
    }
    close(cfd);
    return NO;
}


+(NSString *)SortedJsonStr:(id)dicOrArr
{
    if ([dicOrArr isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic=dicOrArr;
        
        NSMutableString *mustr=[NSMutableString string];
        
        NSArray *allkey=[dic.allKeys sortedArrayUsingSelector:@selector(compare:)];
        for (int i=0; i<allkey.count; i++) {
            NSString *key=allkey[i];
            NSString *value=[dic objectForKey:key];
            
            BOOL isda=NO;
            
            if ([value isKindOfClass:[NSDictionary class]]||[value isKindOfClass:[NSArray class]]) {
                value=[self SortedJsonStr:value];
                isda=YES;
            }
            if (isda) {
                if (mustr.length==0) {
                    [mustr appendFormat:@"{\"%@\":%@",key,value];
                }else{
                    [mustr appendFormat:@",\"%@\":%@",key,value];
                }
            }else{
                if (mustr.length==0) {
                    [mustr appendFormat:@"{\"%@\":\"%@\"",key,value];
                }else{
                    [mustr appendFormat:@",\"%@\":\"%@\"",key,value];
                }
            }
        }
        [mustr appendString:@"}"];
        return mustr;
    }else if ([dicOrArr isKindOfClass:[NSArray class]]){
        
        NSArray *arr=dicOrArr;
        
        NSMutableString *mustr=[NSMutableString string];
        
        for (int i=0; i<arr.count; i++) {
            NSString *value=arr[i];
            
            BOOL isda=NO;
            
            if ([value isKindOfClass:[NSDictionary class]]||[value isKindOfClass:[NSArray class]]) {
                value=[self SortedJsonStr:value];
                isda=YES;
            }
            if (isda) {
                if (mustr.length==0) {
                    [mustr appendFormat:@"[%@",value];
                }else{
                    [mustr appendFormat:@",%@",value];
                }
            }else{
                if (mustr.length==0) {
                    [mustr appendFormat:@"[\"%@\"",value];
                }else{
                    [mustr appendFormat:@",\"%@\"",value];
                }
            }
        }
        [mustr appendString:@"]"];
        return mustr;
    }
    return @"";
}
+(NSString *)CovertLogToJson:(NSString *)inlogstr
{
    if (!inlogstr||![inlogstr isKindOfClass:[NSString class]]||inlogstr.length==0) {
        return @"";
    }
    NSString *logstr=inlogstr;

    logstr=[logstr stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    logstr=[logstr stringByReplacingOccurrencesOfString:@" " withString:@""];
    logstr=[logstr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    logstr=[logstr stringByReplacingOccurrencesOfString:@"\r" withString:@""];

    unichar fc=[logstr characterAtIndex:0];
    unichar lc=[logstr characterAtIndex:logstr.length-1];

    if (fc=='('&&lc==')') {
        //数组
        NSMutableArray *muarr=[NSMutableArray array];//t: 1  字典  2 数组

        NSMutableString *onestr=[NSMutableString string];

        for (NSInteger h=1; h<logstr.length-1; h++) {
            unichar hc=[logstr characterAtIndex:h];

            if (hc=='{') {
                NSInteger dep=1; //括号深度
                NSInteger i=h+1;
                for (; i<logstr.length; i++) {
                    unichar kc=[logstr characterAtIndex:i];
                    if (kc=='{') {
                        dep++;
                    }
                    if (kc=='}') {
                        dep--;
                        if (dep==0) {
                            break;
                        }
                    }
                }
                if (dep==0) {
                    NSString *substr=[logstr substringWithRange:NSMakeRange(h, i-h+1)];
                    substr=[self CovertLogToJson:substr];
                    [muarr addObject:@{@"v":substr,@"t":@(1)}];
                    h=i;
                }
            }else if (hc=='(') {
                NSInteger dep=1; //括号深度
                NSInteger i=h+1;
                for (; i<logstr.length; i++) {
                    unichar kc=[logstr characterAtIndex:i];
                    if (kc=='(') {
                        dep++;
                    }
                    if (kc==')') {
                        dep--;
                        if (dep==0) {
                            break;
                        }
                    }
                }
                if (dep==0) {
                    NSString *substr=[logstr substringWithRange:NSMakeRange(h, i-h+1)];
                    substr=[self CovertLogToJson:substr];
                    [muarr addObject:@{@"v":substr,@"t":@(2)}];
                    h=i;
                }
            }else if(hc==','){
                if (onestr.length>0) {
                    [muarr addObject:@{@"v":onestr,@"t":@(0)}];
                    onestr=[NSMutableString string];
                }
            }else{
                [onestr appendFormat:@"%C",hc];
            }
        }
        if (onestr.length>0) {
            [muarr addObject:@{@"v":onestr,@"t":@(0)}];
        }

        NSMutableString *mustr=[NSMutableString string];
        for (int i=0; i<muarr.count; i++) {
            NSDictionary *ccdic=muarr[i];
            NSString *value=[ccdic objectForKey:@"v"];
            NSNumber *t=[ccdic objectForKey:@"t"];
            if (t.intValue>0) {
                if (mustr.length==0) {
                    [mustr appendFormat:@"[%@",value];
                }else{
                    [mustr appendFormat:@",%@",value];
                }
            }else{
                if (mustr.length==0) {
                    [mustr appendFormat:@"[\"%@\"",value];
                }else{
                    [mustr appendFormat:@",\"%@\"",value];
                }
            }
        }
        [mustr appendString:@"]"];
        return mustr;
    }

    if (fc=='{'&&lc=='}') {

        //字典
        NSMutableArray *muarr=[NSMutableArray array];//t: 1  字典  2 数组

        NSMutableString *onename=[NSMutableString string];
        NSMutableString *onestr=[NSMutableString string];

        BOOL isnamec=1;//是否是name收集

        for (NSInteger h=1; h<logstr.length-1; h++) {
            unichar hc=[logstr characterAtIndex:h];

            if (hc=='{') {
                NSInteger dep=1; //括号深度
                NSInteger i=h+1;
                for (; i<logstr.length; i++) {
                    unichar kc=[logstr characterAtIndex:i];
                    if (kc=='{') {
                        dep++;
                    }
                    if (kc=='}') {
                        dep--;
                        if (dep==0) {
                            break;
                        }
                    }
                }
                if (dep==0) {
                    NSString *substr=[logstr substringWithRange:NSMakeRange(h, i-h+1)];
                    substr=[self CovertLogToJson:substr];
                    [muarr addObject:@{@"v":substr,@"t":@(1),@"n":onename}];
                    onename=[NSMutableString string];
                    h=i;
                }
            }else if (hc=='(') {
                NSInteger dep=1; //括号深度
                NSInteger i=h+1;
                for (; i<logstr.length; i++) {
                    unichar kc=[logstr characterAtIndex:i];
                    if (kc=='(') {
                        dep++;
                    }
                    if (kc==')') {
                        dep--;
                        if (dep==0) {
                            break;
                        }
                    }
                }
                if (dep==0) {
                    NSString *substr=[logstr substringWithRange:NSMakeRange(h, i-h+1)];
                    substr=[self CovertLogToJson:substr];
                    [muarr addObject:@{@"v":substr,@"t":@(2),@"n":onename}];
                    onename=[NSMutableString string];
                    h=i;
                }
            }else if(hc=='='){
                isnamec=0;
            }else if(hc==';'){
                isnamec=1;
                if (onestr.length>0&&onename.length>0) {
                    [muarr addObject:@{@"v":onestr,@"t":@(0),@"n":onename}];
                    onestr=[NSMutableString string];
                    onename=[NSMutableString string];
                }
            }else{
                if (isnamec) {
                    [onename appendFormat:@"%C",hc];
                }else{
                    [onestr appendFormat:@"%C",hc];
                }
            }
        }
        if (onestr.length>0&&onename.length>0) {
            [muarr addObject:@{@"v":onestr,@"t":@(0),@"n":onename}];
        }

        NSMutableString *mustr=[NSMutableString string];
        for (int i=0; i<muarr.count; i++) {
            NSDictionary *ccdic=muarr[i];
            NSString *value=[ccdic objectForKey:@"v"];
            NSNumber *t=[ccdic objectForKey:@"t"];
            NSString *n=[ccdic objectForKey:@"n"];

            if (t.intValue>0) {
                if (mustr.length==0) {
                    [mustr appendFormat:@"{\"%@\":%@",n,value];
                }else{
                    [mustr appendFormat:@",\"%@\":%@",n,value];
                }
            }else{
                if (mustr.length==0) {
                    [mustr appendFormat:@"{\"%@\":\"%@\"",n,value];
                }else{
                    [mustr appendFormat:@",\"%@\":\"%@\"",n,value];
                }
            }
        }
        [mustr appendString:@"}"];
        return mustr;
    }

    return logstr;
}
-(void)clearAllCookie
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    for (NSHTTPCookie *cookie in [NSHTTPCookieStorage sharedHTTPCookieStorage].cookies) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }
    [[NSFileManager defaultManager] removeItemAtPath:[[WTRFilePath getLibraryPath] stringByAppendingPathComponent:@"Cookies"] error:nil];
    
    if (@available(iOS 9.0, *)) {
        [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:[NSSet setWithArray:@[WKWebsiteDataTypeCookies,WKWebsiteDataTypeSessionStorage]] modifiedSince:[NSDate dateWithTimeIntervalSince1970:0] completionHandler:^{
        }];
    }
    
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
    NSFileManager* manager = [NSFileManager defaultManager];
    NSString *cachefile=[WTRFilePath getCachePath];
    NSArray *arr=[manager subpathsAtPath:cachefile];
    if (arr&&arr.count>0) {
        for (int i=0; i<arr.count; i++) {
            NSString *fileName=arr[i];
            NSString *fileAbsolutePath = [cachefile stringByAppendingPathComponent:fileName];
            [manager removeItemAtPath:fileAbsolutePath error:nil];
        }
    }
}
+(unsigned long long)AllCachesSize
{
    NSString * cachesPath=[WTRFilePath getCachePath];
    return [self folderSizeAtPath:cachesPath];
}
//文件夹内文件大小
+(unsigned long long)folderSizeAtPath:(NSString*)folderPath
{
    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folderPath]) return 0;
    unsigned long long folderSize=0;
    NSArray *arr=[manager subpathsAtPath:folderPath];
    if (arr&&arr.count>0) {
        for (int i=0; i<arr.count; i++) {
            NSString *fileName=arr[i];
            if ([fileName hasPrefix:@"."]||[fileName rangeOfString:@"/."].length>0) {
                continue;
            }
            NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
            folderSize += [self fileSizeAtPath:fileAbsolutePath];
        }
    }
    return folderSize;
}
+(unsigned long long)fileSizeAtPath:(NSString*)filePath
{
    NSFileManager* manager = [NSFileManager defaultManager];
    BOOL isdicr;
    BOOL isz=[manager fileExistsAtPath:filePath isDirectory:&isdicr];
    if (!isdicr&&isz){
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}
+(double)getFreeDiskSize
{
    NSDictionary *infodic=[[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    if (infodic) {
        NSNumber * fileSystemFreeSize = [infodic objectForKey:NSFileSystemFreeSize];
        return fileSystemFreeSize.doubleValue/1024.0f/1024.0f/1024.0f;
    }
    return 0;
}
+(double)getTotalDiskSize
{
    NSDictionary *infodic=[[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    if (infodic) {
        NSNumber * fileSystemFreeSize = [infodic objectForKey:NSFileSystemSize];
        return fileSystemFreeSize.doubleValue/1024.0f/1024.0f/1024.0f;
    }
    return 0;
}

+(UIViewController *)curintViewController
{
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    UIViewController *topViewController = [window rootViewController];
    while (true) {
        if (topViewController.presentedViewController&&![topViewController.presentedViewController isKindOfClass:[UIAlertController class]]&&(topViewController.presentedViewController.modalPresentationStyle==UIModalPresentationFullScreen)) {
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
+(UIViewController *)curintViewControllerNotInVcClassArray:(NSArray <Class>*)vcClassArray
{
    //当前ViewController 链碰到到vcClassArray里的某一项就停止 返回上一个
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    UIViewController *topViewController = [window rootViewController];
    while (true) {
        if (topViewController.presentedViewController&&![topViewController.presentedViewController isKindOfClass:[UIAlertController class]]&&(topViewController.presentedViewController.modalPresentationStyle==UIModalPresentationFullScreen)) {
            if ([self isCurintViewController:topViewController.presentedViewController InVcClassArray:vcClassArray]) {
                break;
            }
            topViewController = topViewController.presentedViewController;
        } else if ([topViewController isKindOfClass:[UINavigationController class]] && [(UINavigationController*)topViewController topViewController]) {
            if ([self isCurintViewController:[(UINavigationController *)topViewController topViewController] InVcClassArray:vcClassArray]) {
                break;
            }
            topViewController = [(UINavigationController *)topViewController topViewController];
        } else if ([topViewController isKindOfClass:[UITabBarController class]]) {
            if ([self isCurintViewController:((UITabBarController *)topViewController).selectedViewController InVcClassArray:vcClassArray]) {
                break;
            }
            UITabBarController *tab = (UITabBarController *)topViewController;
            topViewController = tab.selectedViewController;
        } else {
            break;
        }
    }
    return topViewController;
}
+(BOOL)isCurintViewController:(UIViewController *)cvc InVcClassArray:(NSArray <Class>*)vcClassArray
{
    if (!vcClassArray||![vcClassArray isKindOfClass:[NSArray class]]||vcClassArray.count==0) {
        return NO;
    }
    for (Class cclas in vcClassArray) {
        if ([cvc isKindOfClass:cclas]) {
            return YES;
        }
    }
    return NO;
}


+(NSArray *)GetAllDataWithDbPath:(NSString *)path tablename:(NSString *)tablename columnArray:(NSArray <NSString *>*)columnArray
{
    sqlite3 *_dbHandle;
    NSMutableArray *marr=[NSMutableArray array];
    
    if (sqlite3_open([path UTF8String],&_dbHandle)==SQLITE_OK) {
        NSString *sql=[NSString stringWithFormat:@"select * from %@;",tablename];
        
        sqlite3_stmt *statment;
        if (sqlite3_prepare_v2(_dbHandle, [sql UTF8String], -1, &statment, NULL)==SQLITE_OK) {
            
            while(sqlite3_step(statment) == SQLITE_ROW) {
                
                NSMutableDictionary *mudic=[NSMutableDictionary dictionary];
                
                for (int i=0; i<columnArray.count; i++) {
                    NSString *column=[columnArray objectAtIndex:i];
                    if (sqlite3_column_type(statment, i)!= SQLITE_NULL) {
                        const unsigned char *cName = sqlite3_column_text(statment, i);
                        NSString *strValue=[NSString stringWithCString:(const char *)cName encoding:NSUTF8StringEncoding];
                        if (strValue) {
                            [mudic setObject:strValue forKey:column];
                        }else{
                            NSNumber *num=[NSNumber numberWithInt:sqlite3_column_int(statment, i)];
                            if (num) {
                                [mudic setObject:num forKey:column];
                            }
                        }
                    }
                }
                
                [marr addObject:mudic];
            }
            
            sqlite3_finalize(statment);
            sqlite3_close(_dbHandle);
        }else{
            sqlite3_close(_dbHandle);
        }
    }
    return marr;
}

#pragma mark 数字转汉字
+(NSString *)numtohanzi:(uint64_t)index
{
    NSMutableString *allstr=[self numtohanziR:index];
    if (allstr.length>1&&[[allstr substringFromIndex:allstr.length-1] isEqualToString:@"零"]) {
        [allstr replaceCharactersInRange:NSMakeRange(allstr.length-1, 1) withString:@""];
    }
    if (allstr.length>2&&[[allstr substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"一十"]) {
        [allstr replaceCharactersInRange:NSMakeRange(0, 2) withString:@"十"];
    }
    return allstr;
}
+(NSMutableString *)numtohanziR:(uint64_t)index
{
    NSArray *shuzi=@[@"零",@"一",@"二",@"三",@"四",@"五",@"六",@"七",@"八",@"九"];
    NSArray *danwei=@[@"十",@"百",@"千",@"万",@"亿"];
    NSArray *danweiJs=@[@(10),@(100),@(1000),@(10000),@(100000000)];

    if (index/10==0) {
        NSUInteger ccindex=(NSUInteger)index;
        return shuzi[ccindex];
    }

    NSMutableString *allstr=[NSMutableString string];
    uint64_t shang=0;
    uint64_t yushu=index;
    NSInteger ji=danweiJs.count-1;
    while (ji>=0) {
        NSNumber *jishunum=danweiJs[ji];
        uint64_t jishu=jishunum.unsignedLongLongValue;
        shang=yushu/jishu;
        if (shang>0) {
            [allstr appendFormat:@"%@%@",[self numtohanziR:shang],danwei[ji]];
            yushu=yushu%jishu;
            uint64_t jishuxia=jishu/10;
            NSString *yushustr=[self numtohanziR:yushu];
            if ((jishuxia<10)||(yushu/jishuxia>0)) {
                [allstr appendString:yushustr];
            }else{
                [allstr appendFormat:@"零%@",yushustr];
            }
            if (allstr.length>0&&[[allstr substringFromIndex:allstr.length-1] isEqualToString:@"零"]) {
                [allstr replaceCharactersInRange:NSMakeRange(allstr.length-1, 1) withString:@""];
            }
            return allstr;
        }
        ji--;
    }
    NSLog(@"数字转文字出错");
    return nil;
}

//Keychain操作
+(NSMutableDictionary *)newkSecDictionary:(NSString *)identifier Account:(NSString *)Account Group:(NSString *)Group
{
    return [self newkSecDictionary:identifier Account:Account Group:Group Accessible:(id)kSecAttrAccessibleAfterFirstUnlock];
}
+(NSMutableDictionary *)newkSecDictionary:(NSString *)identifier Account:(NSString *)Account Group:(NSString *)Group Accessible:(NSString *)kSecAttrAccessibleStr
{
    NSMutableDictionary *searchDictionary = [NSMutableDictionary dictionary];
    //指定item的类型为GenericPassword
    [searchDictionary setObject:(id)kSecClassGenericPassword forKey:(id)kSecClass];

    //id
    [searchDictionary setObject:identifier forKey:(id)kSecAttrService];

    //账户名
    [searchDictionary setObject:Account forKey:(id)kSecAttrAccount];

    if (kSecAttrAccessibleStr) {
        //pdmn = ck; kSecAttrAccessibleAfterFirstUnlock
        [searchDictionary setObject:kSecAttrAccessibleStr forKey:(id)kSecAttrAccessible];
    }
    
    /*
     公用组名 要保证真机 并且Capabilities下打开工程的Keychain Sharing按钮 并在开发者网站id中配置 证书
     accessGroup = "[YOUR APP ID PREFIX].com.example.apple-samplecode.GenericKeychainShared"

     For information on App ID prefixes, see:
     https://developer.apple.com/library/ios/documentation/General/Conceptual/DevPedia-CocoaCore/AppID.html
     and:
     https://developer.apple.com/library/ios/technotes/tn2311/_index.html
     */
    //例子 "ED6U86NK2U.wfz.asd.asdasd"
    //[searchDictionary setObject:Group forKey:(id)kSecAttrAccessGroup];

    return searchDictionary;
}

+(NSData *)readKeychainId:(NSString *)identifier
{
    return [self readKeychainId:identifier Account:identifier Group:identifier];
}
+(NSData *)readKeychainId:(NSString *)identifier kSecReturnType:(NSString *)kSecReturnType
{
    return [self readKeychainId:identifier Account:identifier Group:identifier kSecReturnType:kSecReturnType];
}
+(NSData *)readKeychainId:(NSString *)identifier Account:(NSString *)Account Group:(NSString *)Group
{
    return [self readKeychainId:identifier Account:Account Group:Group kSecReturnType:(id)kSecReturnData];
}
+(NSData *)readKeychainId:(NSString *)identifier Account:(NSString *)Account Group:(NSString *)Group kSecReturnType:(NSString *)kSecReturnType
{
    NSMutableDictionary *searchDictionary=[self newkSecDictionary:identifier Account:Account Group:Group];
    [searchDictionary setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];

    /*
     kSecReturnType:
        kSecReturnData 直接返回原数据，返回值类型是CFDataRef
        kSecReturnAttributes 返回该条目的属性，返回值是字典类型CFDictionaryRef
        kSecReturnRef 返回条目的引用，根据条目所属类别，返回值类型可能是：SecKeychainItemRef, SecKeyRef,SecCertificateRef, SecIdentityRef.
        kSecReturnPersistentRef 返回条目的引用，返回值类型是CFDataRef（配置VPN等要钥匙串时需要用 系统库需要的是引用值）
     */
    [searchDictionary setObject:(id)kCFBooleanTrue forKey:kSecReturnType];

    CFTypeRef outdata = nil;

    if (SecItemCopyMatching((CFDictionaryRef)searchDictionary,&outdata)==errSecSuccess) {
        NSData *ret = [NSData dataWithData:(__bridge NSData *)outdata];
        if (outdata) {
            CFRelease(outdata);
            return ret;
        }
    };
    return nil;
}
+(BOOL)writeData:(NSData *)data KeychainId:(NSString *)identifier
{
    return [self writeData:data KeychainId:identifier Account:identifier Group:identifier];
}
+(BOOL)writeData:(NSData *)data KeychainId:(NSString *)identifier Account:(NSString *)Account Group:(NSString *)Group
{
    NSMutableDictionary *searchDictionary=[self newkSecDictionary:identifier Account:Account Group:Group];

    if ([self readKeychainId:identifier Account:Account Group:Group]) {
        NSMutableDictionary *attributesToUpdate=[NSMutableDictionary dictionary];
        [attributesToUpdate setObject:data forKey:(id)kSecValueData];

        if (SecItemUpdate((CFDictionaryRef)searchDictionary, (CFDictionaryRef)attributesToUpdate)==errSecSuccess) {
            return YES;
        }
    }else{
        [searchDictionary setObject:data forKey:(id)kSecValueData];
        if (SecItemAdd((CFDictionaryRef)searchDictionary, nil)==errSecSuccess) {
            return YES;
        }
    }
    return NO;
}
+(BOOL)deleteKeychainId:(NSString *)identifier
{
    return [self deleteKeychainId:identifier Account:identifier Group:identifier];
}
+(BOOL)deleteKeychainId:(NSString *)identifier Account:(NSString *)Account Group:(NSString *)Group
{
    NSMutableDictionary *searchDictionary=[self newkSecDictionary:identifier Account:Account Group:Group];
    if (SecItemDelete((CFDictionaryRef)searchDictionary)==errSecSuccess) {
        return YES;
    }
    return NO;
}

#pragma mark 验证内购
+(void)verifyReceiptWithData:(NSData *)receiptData isSANDBOX:(BOOL)isSANDBOX completionHandler:(void (^)(NSDictionary * retdic, NSURLResponse * response, NSError * error))completionHandler
{
    NSString *encodeStr = [receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];

    NSURL *url;
    if (isSANDBOX) {
        url = [NSURL URLWithString:@"https://sandbox.itunes.apple.com/verifyReceipt"];
    }else{
        url = [NSURL URLWithString:@"https://buy.itunes.apple.com/verifyReceipt"];
    }
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15.0f];

    NSString *payload = [NSString stringWithFormat:@"{\"receipt-data\" : \"%@\"}", encodeStr];
    NSData *payloadData = [payload dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:payloadData];
    [request setHTTPMethod:@"POST"];

    NSURLSessionDataTask *task=[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data) {
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            //status 为0 时 验证正确
            if (completionHandler) {
                completionHandler(jsonDict,response,error);
            }
        }else{
            if (completionHandler) {
                completionHandler(nil,response,error);
            }
        }
    }];
    [task resume];
}

#pragma mark 从数组中随机取连续的几个
+(NSMutableArray *)getSomeObjWithInArr:(NSArray *)yarr num:(NSInteger)num
{
    if (!yarr||![yarr isKindOfClass:[NSArray class]]) {
        return nil;
    }
    
    NSMutableArray *muarr=[NSMutableArray array];
    if (yarr.count<=num) {
        [muarr addObjectsFromArray:yarr];
        return muarr;
    }

    NSInteger indexc=arc4random()%yarr.count;

    for (int i=0; i<num; i++) {
        [muarr addObject:yarr[indexc]];
        indexc++;
        if (indexc>=yarr.count) {
            indexc=0;
        }
    }
    return muarr;
}

#pragma mark 去除空行
+(NSString *)quchukonghang:(NSString *)str
{
    if (!str||str.length==0) {
        return str;
    }

    NSMutableString *mustr=[NSMutableString stringWithString:str];

    int ishn=0;

    for (int i=0; i<mustr.length; i++) {
        unichar c=[mustr characterAtIndex:i];
        if (!ishn&&(c=='\n'||c=='\r')) {
            ishn=1;
            continue;
        }
        if (ishn&&(c=='\n'||c=='\r')) {
            [mustr deleteCharactersInRange:NSMakeRange(i, 1)];
            i--;
        }
        else if (ishn>0)
        {
            ishn=0;
        }
    }
    return  mustr;//[mustr stringByReplacingOccurrencesOfString:@"\r" withString:@"\n"];
}
#pragma mark 去除首行缩进空格回车空行
+(NSString *)quchuShkongge:(NSString *)str
{
    if (!str||str.length==0) {
        return str;
    }

    NSMutableString *mustr=[NSMutableString stringWithString:str];

    int ishn=0;

    for (int i=0; i<mustr.length; i++) {
        unichar c=[mustr characterAtIndex:i];
        if (!ishn&&(c=='\n'||c=='\r')) {
            ishn=1;
            continue;
        }
        NSString *cstr=[NSString stringWithFormat:@"%C",c];
        if (ishn&&(c=='\n'||c=='\r'||c==' '||c=='\t'||[cstr isEqualToString:@"\u3000"])) {
            [mustr deleteCharactersInRange:NSMakeRange(i, 1)];
            i--;
        }
        else if (ishn>0)
        {
            ishn=0;
        }
    }
    return  mustr;//[mustr stringByReplacingOccurrencesOfString:@"\r" withString:@"\n"];
}
#pragma mark 去除tagStr后的空白和空行
+(NSString *)quchuKBKH:(NSString *)str tagStr:(NSString *)tagStr
{
    if (!str||str.length==0||!tagStr||tagStr.length==0) {
        return str;
    }

    NSMutableString *mustr=[NSMutableString stringWithString:str];

    NSRange brrange=[mustr rangeOfString:tagStr options:NSCaseInsensitiveSearch range:NSMakeRange(0, mustr.length)];
    while (brrange.length>0) {
        NSInteger i=brrange.location+brrange.length;
        for (; i<mustr.length; i++) {
            unichar c=[mustr characterAtIndex:i];
            NSString *cstr=[NSString stringWithFormat:@"%C",c];
            if (c=='\n'||c=='\r'||c==' '||c=='\t'||[cstr isEqualToString:@"\u3000"]) {
                [mustr deleteCharactersInRange:NSMakeRange(i, 1)];
                i--;
            }else{
                break;
            }
        }
        if (i<mustr.length-1) {
            brrange=[mustr rangeOfString:tagStr options:NSCaseInsensitiveSearch range:NSMakeRange(i, mustr.length-i)];
        }else{
            break;
        }
    }
    return  mustr;
}
#pragma mark 过滤所有标签
+(NSString *)filterAllHTMLTag:(NSString *)html
{
    if (!ISString(html)) {
        return @"";
    }
    NSScanner * scanner = [NSScanner scannerWithString:html];
    NSString * text = nil;
    while([scanner isAtEnd]==NO)
    {
        [scanner scanUpToString:@"<" intoString:nil];
        [scanner scanUpToString:@">" intoString:&text];
        if (text&&text.length>0) {
            html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>",text] withString:@""];
        }
    }
    return html;
}
#pragma mark 过滤某个标签头
+(NSString *)filterHTML:(NSString *)html oneTag:(NSString *)oneTag
{
    NSString *bqt=[NSString stringWithFormat:@"<%@",oneTag];
    NSScanner * scanner = [NSScanner scannerWithString:html];
    NSString * text = nil;
    while([scanner isAtEnd]==NO)
    {
        [scanner scanUpToString:bqt intoString:nil];
        [scanner scanUpToString:@">" intoString:&text];
        if (text&&text.length>0) {
            html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>",text] withString:@""];
        }
    }
    return html;
}
#pragma mark 过滤标签和标签内东西
+(NSString *)filterHTML:(NSString *)html biaoqian:(NSString *)biaoqian
{
    NSString *biaoqt=[NSString stringWithFormat:@"<%@",biaoqian];
    NSString *biaoqw=[NSString stringWithFormat:@"/%@>",biaoqian];

    NSScanner * scanner = [NSScanner scannerWithString:html];
    NSString * text = nil;
    while([scanner isAtEnd]==NO)
    {
        [scanner scanUpToString:biaoqt intoString:nil];
        [scanner scanUpToString:biaoqw intoString:&text];
        if (text&&text.length>0) {
            html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@%@",text,biaoqw] withString:@""];
            text=nil;
        }
    }
    return html;
}
#pragma mark 转意html字符
+(NSString *)htmlzhuanyizifu:(NSString *)html
{
    if (!ISString(html)) {
        return @"";
    }
    //这只是大部分概率的 不是全部转换
    html=[html stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
    html=[html stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
    html=[html stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    html=[html stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
    html=[html stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];

    return html;
}
#pragma mark 只留html中展示文字，去除所有标签、回车和空白
+(NSString *)jianHuaHtml:(NSString *)html
{
    html=[self filterAllHTMLTag:html];
    html=[self htmlzhuanyizifu:html];

    html=[html stringByReplacingOccurrencesOfString:@" " withString:@""];
    html=[html stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    html=[html stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    html=[html stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    html=[html stringByReplacingOccurrencesOfString:@"\u3000" withString:@""];
    return html;
}
#pragma mark 通用html处理-html显示优化
+(NSString *)htmlConvert:(NSString *)html
{
    if (!ISString(html)) {
        return @"";
    }
    html=[html stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n"];
    html=[html stringByReplacingOccurrencesOfString:@"</br>" withString:@"\n"];
    html=[html stringByReplacingOccurrencesOfString:@"</p>" withString:@"\n"];
    html=[self filterAllHTMLTag:html];
    html=[self htmlzhuanyizifu:html];
    html=[html stringByReplacingOccurrencesOfString:@"\r" withString:@"\n"];
    html=[html stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\r\n\t \u3000"]];
    html=[self quchuShkongge:html];
    return html;
}
#pragma mark 给出现文字设置属性
+(void)AddAttributeStr:(NSMutableAttributedString *)allstr Attributes:(NSDictionary *)atr inStr:(NSString *)str
{
    if (!allstr||![allstr isKindOfClass:[NSMutableAttributedString class]]||!ISString(str)) {
        return;
    }
    NSRange crange=[allstr.string rangeOfString:str];
    while (crange.length>0) {
        [allstr addAttributes:atr range:crange];
        if (crange.location+crange.length>=allstr.string.length) {
            break;
        }
        crange=[allstr.string rangeOfString:str options:NSCaseInsensitiveSearch range:NSMakeRange(crange.location+crange.length, allstr.string.length-(crange.location+crange.length))];
    }
}
#pragma mark 汉字转拼音
+(NSString *)HanZiToPinYin:(NSString *)hanzi
{
    if (!ISString(hanzi)) {
        return @"";
    }
    NSMutableString *source = [hanzi mutableCopy];
    CFStringTransform((__bridge CFMutableStringRef)source, NULL, kCFStringTransformMandarinLatin, NO);
    CFStringTransform((__bridge CFMutableStringRef)source, NULL, kCFStringTransformStripDiacritics, NO);
    return source;
}

+(NSString *)getPriceStr:(NSString *)inPrice
{
    if (!ISNumberStr(inPrice)) {
        return @"";
    }
    NSString *retstr=@"";
    long long Pricelong=roundf(inPrice.doubleValue*100);

    retstr=[NSString stringWithFormat:@"%.2f",Pricelong*1.0/100];

    return retstr;
}
+(NSString *)getPriceStr2:(NSString *)inPrice
{
    if (!ISNumberStr(inPrice)) {
        return @"";
    }
    NSString *retstr=@"";
    long long Pricelong=roundf(inPrice.doubleValue*100);
    if (Pricelong%100>0) {
        if (Pricelong%10>0) {
            retstr=[NSString stringWithFormat:@"%.2f",Pricelong*1.0/100];
        }else{
            retstr=[NSString stringWithFormat:@"%.1f",Pricelong*1.0/100];
        }
    }else{
        retstr=[NSString stringWithFormat:@"%.0f",Pricelong*1.0/100];
    }
    return retstr;
}

+(void)switchNewOrientation:(UIInterfaceOrientation)newOrientation
{
    NSNumber *yzor1=[NSNumber numberWithInteger:UIInterfaceOrientationUnknown];
    [[UIDevice currentDevice] setValue:yzor1 forKey:@"orientation"];
    NSNumber *yzor2=[NSNumber numberWithInteger:newOrientation];
    [[UIDevice currentDevice] setValue:yzor2 forKey:@"orientation"];
}

+(void)reMoveTableViewAutoSet:(UITableView *)tableView
{
    tableView.estimatedRowHeight=0;
    tableView.estimatedSectionFooterHeight=0;
    tableView.estimatedSectionHeaderHeight=0;
    if (@available(iOS 13.0, *)) {
        tableView.automaticallyAdjustsScrollIndicatorInsets=NO;
    }
    if (@available(iOS 11.0, *)) {
        tableView.contentInsetAdjustmentBehavior=UIScrollViewContentInsetAdjustmentNever;
    }
}
+(void)reMoveTextfAutoSet:(id<UITextInputTraits>)textf
{
    textf.autocapitalizationType=UITextAutocapitalizationTypeNone;//首字母大写情况
    textf.autocorrectionType=UITextAutocorrectionTypeNo;//自动更正
//    textf.spellCheckingType=UITextSpellCheckingTypeNo;//拼写检查
    if (@available(iOS 11.0, *)) {
        textf.smartQuotesType=UITextSmartQuotesTypeNo;//自动引号
        textf.smartDashesType=UITextSmartDashesTypeNo;//自动破折号
    }
}

+(void)showmsge:(NSString *)msg
{
    [self showmsge:msg time:1];
}
+(void)showmsge:(NSString *)msgin time:(NSTimeInterval)timint
{
    __block NSString *msg=[msgin copy];
    if (!msg||![msg isKindOfClass:[NSString class]]) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        msg=[msg WTR_stringByURLDecode];
        
        UILabel *showmsgla=[UILabel new];
        showmsgla.textColor=[UIColor whiteColor];//UIColorFromRGB(0x999999);
        showmsgla.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.9];
        showmsgla.textAlignment=NSTextAlignmentCenter;
        showmsgla.text=msg;
        showmsgla.numberOfLines=0;
        showmsgla.font=[UIFont systemFontOfSize:15];
        LayerMakeCorner(showmsgla, 5);
        
        [[UIApplication sharedApplication].delegate.window addSubview:showmsgla];
        showmsgla.alpha=0;
        
        CGSize ss=[self getsizeOfStr:msg Fontsize:showmsgla.font Width:ScreenWidth-20];
        
        ss.height=ss.width-20;
        if (ss.height>80) {
            ss.height=80;
        }
        CGFloat jiange=20;
        if (ISPadWTR) {
            jiange=30;
        }
        
        CGFloat jww=(ScreenWidth-ss.width-jiange)/2.0,jhh=(ScreenHeight-ss.height-20)/2.0;
        
        showmsgla.frame=CGRectMake(jww, jhh-30, ss.width+jiange, ss.height+20);
        
        [UIView animateWithDuration:0.25 animations:^{
            showmsgla.alpha=1;
        }completion:^(BOOL finished) {
            [UIView animateWithDuration:0.5 delay:timint options:UIViewAnimationOptionCurveEaseIn animations:^{
                showmsgla.alpha=0.1;
            } completion:^(BOOL finished) {
                [showmsgla removeFromSuperview];
            }];
        }];
    });
}

@end


int32_t const WTRCHUNK_SIZE = 8 * 1024;

@implementation NSData (WTRMDJiaMi)

+ (NSString *)WTRConvertMd5Bytes2String:(unsigned char *)md5Bytes {
    return [NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            md5Bytes[0], md5Bytes[1], md5Bytes[2], md5Bytes[3],
            md5Bytes[4], md5Bytes[5], md5Bytes[6], md5Bytes[7],
            md5Bytes[8], md5Bytes[9], md5Bytes[10], md5Bytes[11],
            md5Bytes[12], md5Bytes[13], md5Bytes[14], md5Bytes[15]
            ];
}
-(NSString *)WTRMD5String
{
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5([self bytes], (CC_LONG)[self length], result);
    
    return [NSData WTRConvertMd5Bytes2String:result];
}
+ (NSData *)WTRfileMD5:(NSString*)path
{
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:path];
    if(handle == nil) {
        return nil;
    }
    CC_MD5_CTX md5;
    CC_MD5_Init(&md5);
    BOOL done = NO;
    while(!done) {
        @autoreleasepool{
            NSData* fileData = [handle readDataOfLength:WTRCHUNK_SIZE];
            CC_MD5_Update(&md5, [fileData bytes], (CC_LONG)[fileData length]);
            if([fileData length] == 0) {
                done = YES;
            }
        }
    }
    unsigned char digestResult[CC_MD5_DIGEST_LENGTH * sizeof(unsigned char)];
    CC_MD5_Final(digestResult, &md5);
    return [NSData dataWithBytes:(const void *)digestResult length:CC_MD5_DIGEST_LENGTH * sizeof(unsigned char)];
}
+ (NSString *)WTRfileMD5String:(NSString *)path {
    BOOL isDirectory = NO;
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory];
    if (isDirectory || !isExist) {
        NSLog(@"文件不存在：%@", path);
        return nil;
    }
    unsigned char * md5Bytes = (unsigned char *)[[self WTRfileMD5:path] bytes];
    return [self WTRConvertMd5Bytes2String:md5Bytes];
}

+(NSData *)WTR_dataWithHexString:(NSString *)hexStr
{
    hexStr = [hexStr stringByReplacingOccurrencesOfString:@"<" withString:@""];
    hexStr = [hexStr stringByReplacingOccurrencesOfString:@">" withString:@""];
    hexStr = [hexStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    hexStr = [hexStr lowercaseString];
    NSUInteger len = hexStr.length;
    if (!len) return nil;
    unichar *buf = malloc(sizeof(unichar) * len);
    if (!buf) return nil;
    [hexStr getCharacters:buf range:NSMakeRange(0, len)];

    NSMutableData *result = [NSMutableData data];
    unsigned char bytes;
    char str[3] = { '\0', '\0', '\0' };
    int i;
    for (i = 0; i < len / 2; i++) {
        str[0] = buf[i * 2];
        str[1] = buf[i * 2 + 1];
        bytes = strtol(str, NULL, 16);
        [result appendBytes:&bytes length:1];
    }
    free(buf);
    return result;
}
-(NSString *)WTR_hexString
{
    NSUInteger length = self.length;
    NSMutableString *result = [NSMutableString stringWithCapacity:length * 2];
    const unsigned char *byte = self.bytes;
    for (int i = 0; i < length; i++, byte++) {
        [result appendFormat:@"%02X", *byte];
    }
    return result;
}

-(NSData *)WTR_sha1
{
    unsigned char hash[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1([self bytes],(CC_LONG)[self length],hash);
    return [NSData dataWithBytes:hash length: CC_SHA1_DIGEST_LENGTH];
}
-(NSString *)WTR_sha1String
{
    NSData *shada=[self WTR_sha1];
    NSString *retStr=[shada base64EncodedStringWithOptions:0];//base64
    return retStr;
}
-(NSData *)WTR_hmac_sha1WithKey:(NSString *)key
{
    const char *cKey  = [key cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cData = self.bytes;

    char cHMAC[CC_SHA1_DIGEST_LENGTH];

    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, self.length, cHMAC);

    return [[NSData alloc] initWithBytes:cHMAC length:CC_SHA1_DIGEST_LENGTH];
}
-(NSString *)WTR_hmac_sha1StrWithKey:(NSString *)key
{
    NSData *shada=[self WTR_hmac_sha1WithKey:key];
    NSString *retStr=[shada base64EncodedStringWithOptions:0];//base64
    return retStr;
}
-(NSData *)WTR_hmac_md5WithKey:(NSString *)key
{
    const char *cKey  = [key cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cData = self.bytes;

    char cHMAC[CC_MD5_DIGEST_LENGTH];

    CCHmac(kCCHmacAlgMD5, cKey, strlen(cKey), cData, self.length, cHMAC);

    return [[NSData alloc] initWithBytes:cHMAC length:CC_MD5_DIGEST_LENGTH];
}
-(NSString *)WTR_hmac_md5StrWithKey:(NSString *)key
{
    NSData *md5da=[self WTR_hmac_md5WithKey:key];
    NSString *retStr=[md5da base64EncodedStringWithOptions:0];//base64
    return retStr;
}

@end


@implementation NSString (WTRStr)

/*
 这里只适用于值中不需要对 !$&'()*+,;= 加密的

 如果值中带有&=什么的特殊符号 （例如 example.com?name=asd&qwe） 其中&不会被Encode

 只能每项拿出来单独URLEncode；
 单独URLEncode时请使用stringByURLEncodeReal
 */
-(NSString*)WTR_stringByURLEncode
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    NSString *temp = [SafeStr(self) stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
#pragma clang diagnostic pop
    return temp;
}
-(NSString*)WTR_stringByURLDecode
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    NSString *temp = [SafeStr(self) stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
#pragma clang diagnostic pop
    return temp;
}
-(NSString*)WTR_stringByURLEncodeReal
{
    NSString *string=SafeStr(self);

    //AF的AFPercentEscapedStringFromString
    static NSString * const kAFCharactersGeneralDelimitersToEncode = @":#[]@"; // does not include "?" or "/" due to RFC 3986 - Section 3.4
    static NSString * const kAFCharactersSubDelimitersToEncode = @"!$&'()*+,;=";

    NSMutableCharacterSet * allowedCharacterSet = [[NSCharacterSet URLQueryAllowedCharacterSet] mutableCopy];
    [allowedCharacterSet removeCharactersInString:[kAFCharactersGeneralDelimitersToEncode stringByAppendingString:kAFCharactersSubDelimitersToEncode]];

    static NSUInteger const batchSize = 50;

    NSUInteger index = 0;
    NSMutableString *escaped = @"".mutableCopy;

    while (index < string.length) {
        NSUInteger length = MIN(string.length - index, batchSize);
        NSRange range = NSMakeRange(index, length);

        // To avoid breaking up character sequences such as 👴🏻👮🏽
        range = [string rangeOfComposedCharacterSequencesForRange:range];

        NSString *substring = [string substringWithRange:range];
        NSString *encoded = [substring stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet];
        [escaped appendString:encoded];

        index += range.length;
    }
    return escaped;
}
-(NSString*)WTR_stringByURLDecodeReal
{
    return SafeStr(self).stringByRemovingPercentEncoding;
}

#pragma mark 字符串解码
+(NSString *)WTR_deCodeStrWithData:(NSData *)da
{
    NSString *retstr=[[NSString alloc] initWithData:da encoding:NSUTF8StringEncoding];
    if (!retstr) {
        NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        retstr = [[NSString alloc] initWithData:da encoding:enc];
    }
    if (!retstr) {
        NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_2312_80);
        retstr = [[NSString alloc] initWithData:da encoding:enc];
    }
    if (!retstr) {
        NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGBK_95);
        retstr = [[NSString alloc] initWithData:da encoding:enc];
    }
    if (!retstr) {
        NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingDOSChineseSimplif);
        retstr = [[NSString alloc] initWithData:da encoding:enc];
    }
    if (!retstr) {
        NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingMacChineseSimp);
        retstr = [[NSString alloc] initWithData:da encoding:enc];
    }
    
    if (!retstr) {
        NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingDOSChineseTrad);
        retstr = [[NSString alloc] initWithData:da encoding:enc];
    }
    if (!retstr) {
        NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingISO_2022_CN_EXT);
        retstr = [[NSString alloc] initWithData:da encoding:enc];
    }
    if (!retstr) {
        NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingISO_2022_CN);
        retstr = [[NSString alloc] initWithData:da encoding:enc];
    }
    //判断BOM
    /*
     Unicode
        在UTF-16（小端）中BOM为FF FE，UTF-16（大端）中BOM为FE FF。这个其实很好记，大端还有另外一个名字叫大尾端（小端同理），FF显然比FE大，所以在大尾端中它的尾巴是FF，即大端BOM为FEFF。
     
     　　在UTF-32中，小端BOM为FFFE0000，大端BOM为0000FEFF。

     　　在UTF-8带BOM的版本中，BOM为EF BB BF。
     */
    if (!retstr) {
        //这里会自动判断 BOM Unicode
        retstr = [[NSString alloc] initWithData:da encoding:NSUnicodeStringEncoding];;
    }
    
    if (!retstr) {
        NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingHZ_GB_2312);
        retstr = [[NSString alloc] initWithData:da encoding:enc];
    }
    if (!retstr) {
        NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingEUC_CN);
        retstr = [[NSString alloc] initWithData:da encoding:enc];
    }
    if (!retstr) {
        NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingBig5);
        retstr = [[NSString alloc] initWithData:da encoding:enc];
    }
    if (!retstr) {
        NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingUnicode);
        retstr = [[NSString alloc] initWithData:da encoding:enc];
    }
    if (!retstr) {
        retstr = [[NSString alloc] initWithData:da encoding:NSUTF16StringEncoding];
    }
    return retstr;
}

@end
