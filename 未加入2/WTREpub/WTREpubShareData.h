//
//  WTREpubShareData.h
//  WTREpubReader
//
//  Created by wfz on 2017/3/16.
//  Copyright © 2017年 wfz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WTREpubShareData : NSObject

+(WTREpubShareData *)shareInstence;


- (NSData *)objectForKey:(NSString *)key;
- (void)setObject:(NSData *)data forKey:(NSString *)key;

- (NSString *)objectStrForKey:(NSString *)key;
- (void)setObjectStr:(NSString *)str forKey:(NSString *)key;

- (NSArray *)objectArrForKey:(NSString *)key;
- (void)setObjectArr:(NSArray *)arr forKey:(NSString *)key;

- (NSDictionary *)objectDicForKey:(NSString *)key;
- (void)setObjectDic:(NSDictionary *)dic forKey:(NSString *)key;

-(void)deletedataWithKey:(NSString *)key;


@end
