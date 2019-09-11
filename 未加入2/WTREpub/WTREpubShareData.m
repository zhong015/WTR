//
//  WTREpubShareData.m
//  WTREpubReader
//
//  Created by wfz on 2017/3/16.
//  Copyright © 2017年 wfz. All rights reserved.
//

#import "WTREpubShareData.h"

static id _s;
@implementation WTREpubShareData
{
    NSString *readerChachpath;
}

+(WTREpubShareData *)shareInstence
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
        readerChachpath=[NSHomeDirectory() stringByAppendingString:@"/Library/WTREpubChach"];
        [[NSFileManager defaultManager]createDirectoryAtPath:readerChachpath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return self;
}
- (NSData *)objectForKey:(NSString *)key
{
    NSString *drpath=[readerChachpath stringByAppendingPathComponent:key];
    NSData *da=[NSData dataWithContentsOfFile:drpath];
    return da;
}
- (void)setObject:(NSData *)data forKey:(NSString *)key
{
    NSString *drpath=[readerChachpath stringByAppendingPathComponent:key];
    if (data) {
        [data writeToFile:drpath atomically:YES];
    }
}
- (NSString *)objectStrForKey:(NSString *)key
{
    NSString *drpath=[readerChachpath stringByAppendingPathComponent:key];
    NSString *da=[NSString stringWithContentsOfFile:drpath encoding:NSUTF8StringEncoding error:nil];
    return da;
}
- (void)setObjectStr:(NSString *)str forKey:(NSString *)key
{
    NSString *drpath=[readerChachpath stringByAppendingPathComponent:key];
    if (str) {
        [str writeToFile:drpath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
}
- (NSArray *)objectArrForKey:(NSString *)key
{
    NSString *drpath=[readerChachpath stringByAppendingPathComponent:key];
    NSArray *da=[NSArray arrayWithContentsOfFile:drpath];
    return da;
}
- (void)setObjectArr:(NSArray *)arr forKey:(NSString *)key
{
    NSString *drpath=[readerChachpath stringByAppendingPathComponent:key];
    if (arr) {
        [arr writeToFile:drpath atomically:YES];
    }
}

- (NSDictionary *)objectDicForKey:(NSString *)key
{
    NSString *drpath=[readerChachpath stringByAppendingPathComponent:key];
    NSDictionary *da=[NSDictionary dictionaryWithContentsOfFile:drpath];
    return da;
}
- (void)setObjectDic:(NSDictionary *)dic forKey:(NSString *)key
{
    NSString *drpath=[readerChachpath stringByAppendingPathComponent:key];
    if (dic) {
        [dic writeToFile:drpath atomically:YES];
    }
}
-(void)deletedataWithKey:(NSString *)key
{
    NSString *drpath=[readerChachpath stringByAppendingPathComponent:key];
    [[NSFileManager defaultManager] removeItemAtPath:drpath error:nil];
}

@end
