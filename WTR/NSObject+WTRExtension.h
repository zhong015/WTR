//
//  NSObject+WTRExtension.h
//  WTRGitCs
//
//  Created by wfz on 2019/9/6.
//  Copyright © 2019 wfz. All rights reserved.
//

//MJExtension 的简化版 不支持忽略属性 不支持NSManagedObject

#import <Foundation/Foundation.h>

@protocol WTRKeyValue <NSObject>
@optional
/**
 *  数组中需要转换的模型类
 *
 *  @return 字典中的key是数组属性名，value是数组中存放模型的Class（Class类型或者NSString类型）
 */
+ (NSDictionary *)WTR_objectClassInArray;
@end

@interface WTRProperty : NSObject

/** 成员属性的名字 */
@property (nonatomic, readonly) NSString *name;
/** 成员属性来源于哪个类（可能是父类） */
@property (nonatomic, assign) Class srcClass;

@end

/**
 *  遍历成员变量用的block
 *
 *  @param property 成员的包装对象
 *  @param stop   YES代表停止遍历，NO代表继续遍历
 */
typedef void (^WTRPropertiesEnumeration)(WTRProperty *property, BOOL *stop);


@interface NSObject (WTRExtension) <WTRKeyValue>

#pragma mark 常用方法
+ (instancetype)WTR_ObjectWithKeyValues:(id)keyValues;
+ (NSMutableArray *)WTR_ObjectArrayWithKeyValuesArray:(id)keyValuesArray;

- (NSMutableDictionary *)WTR_keyValues;
+ (NSMutableArray *)WTR_keyValuesArrayWithObjectArray:(NSArray *)objectArray;

- (NSString *)WTR_JSONString;


#pragma mark - 遍历
/**
 *  遍历所有的属性
 */
+ (void)WTR_enumerateProperties:(WTRPropertiesEnumeration)enumeration;


@end
