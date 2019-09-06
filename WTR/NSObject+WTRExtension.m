//
//  NSObject+WTRExtension.m
//  WTRGitCs
//
//  Created by wfz on 2019/9/6.
//  Copyright © 2019 wfz. All rights reserved.
//

#import "NSObject+WTRExtension.h"
#import <CoreData/CoreData.h>
#import <objc/runtime.h>

/**
 *  遍历所有类的block（父类）
 */
typedef void (^WTRClassesEnumeration)(Class c, BOOL *stop);

//是否是基础类
bool isClassFromFoundation(Class c)
{
    if (c == [NSObject class] || c == [NSManagedObject class]) return YES;

    static NSSet *foundationClasses;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 集合中没有NSObject，因为几乎所有的类都是继承自NSObject，具体是不是NSObject需要特殊判断
        foundationClasses = [NSSet setWithObjects:
                             [NSURL class],
                             [NSDate class],
                             [NSValue class],
                             [NSData class],
                             [NSError class],
                             [NSArray class],
                             [NSDictionary class],
                             [NSString class],
                             [NSAttributedString class], nil];
    });

    __block BOOL result = NO;
    [foundationClasses enumerateObjectsUsingBlock:^(Class foundationClass, BOOL *stop) {
        if ([c isSubclassOfClass:foundationClass]) {
            result = YES;
            *stop = YES;
        }
    }];
    return result;
}
//是否是NSObject的property
bool isFromNSObjectProtocolProperty(NSString *propertyName)
{
    if (!propertyName) return NO;

    static NSSet<NSString *> *objectProtocolPropertyNames;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        unsigned int count = 0;
        objc_property_t *propertyList = protocol_copyPropertyList(@protocol(NSObject), &count);
        NSMutableSet *propertyNames = [NSMutableSet setWithCapacity:count];
        for (int i = 0; i < count; i++) {
            objc_property_t property = propertyList[i];
            NSString *propertyName = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
            if (propertyName) {
                [propertyNames addObject:propertyName];
            }
        }
        objectProtocolPropertyNames = [propertyNames copy];
        free(propertyList);
    });

    return [objectProtocolPropertyNames containsObject:propertyName];
}


/**
 *  成员变量类型（属性类型）
 */
NSString *const WTRPropertyTypeInt = @"i";
NSString *const WTRPropertyTypeShort = @"s";
NSString *const WTRPropertyTypeFloat = @"f";
NSString *const WTRPropertyTypeDouble = @"d";
NSString *const WTRPropertyTypeLong = @"l";
NSString *const WTRPropertyTypeLongLong = @"q";
NSString *const WTRPropertyTypeChar = @"c";
NSString *const WTRPropertyTypeBOOL1 = @"c";
NSString *const WTRPropertyTypeBOOL2 = @"b";
NSString *const WTRPropertyTypePointer = @"*";

NSString *const WTRPropertyTypeIvar = @"^{objc_ivar=}";
NSString *const WTRPropertyTypeMethod = @"^{objc_method=}";
NSString *const WTRPropertyTypeBlock = @"@?";
NSString *const WTRPropertyTypeClass = @"#";
NSString *const WTRPropertyTypeSEL = @":";
NSString *const WTRPropertyTypeId = @"@";



@interface WTRProperty()

/** 成员属性 */
@property (nonatomic, assign) objc_property_t property;

@property (assign, nonatomic) Class objectClassIfArray; //数组对应的类型名

/** 类型标识符 */
@property (nonatomic, copy) NSString *code;

/** 是否为id类型 */
@property (nonatomic, readonly, getter=isIdType) BOOL idType;

/** 是否为基本数字类型：int、float等 */
@property (nonatomic, readonly, getter=isNumberType) BOOL numberType;

/** 是否为BOOL类型 */
@property (nonatomic, readonly, getter=isBoolType) BOOL boolType;

/** 对象类型（如果是基本数据类型，此值为nil） */
@property (nonatomic, readonly) Class typeClass;

/** 类型是否来自于Foundation框架，比如NSString、NSArray */
@property (nonatomic, readonly, getter = isFromFoundation) BOOL fromFoundation;
/** 类型是否不支持KVC */
@property (nonatomic, readonly, getter = isKVCDisabled) BOOL KVCDisabled;


@end

@implementation WTRProperty

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.objectClassIfArray=nil;
    }
    return self;
}
/**
 *  获得成员变量的值
 */
- (id)valueForObject:(id)object
{
    if (self.KVCDisabled) return [NSNull null];

    id value = [object valueForKey:self.name];

    // 32位BOOL类型转换json后成Int类型
    /** https://github.com/CoderMJLee/MJExtension/issues/545 */
    // 32 bit device OR 32 bit Simulator
#if defined(__arm__) || (TARGET_OS_SIMULATOR && !__LP64__)
    if (self.isBoolType) {
        value = @([(NSNumber *)value boolValue]);
    }
#endif

    return value;
}

/**
 *  设置成员变量的值
 */
- (void)setValue:(id)value forObject:(id)object
{
    if (self.KVCDisabled || value == nil) return;
    [object setValue:value forKey:self.name];
}


- (void)setProperty:(objc_property_t)property
{
    _property = property;

    if (!property) {
        return;
    }

    // 1.属性名
    _name = @(property_getName(property));

    // 2.成员类型
    NSString *attrs = @(property_getAttributes(property));
    NSUInteger dotLoc = [attrs rangeOfString:@","].location;
    NSString *code = nil;
    NSUInteger loc = 1;
    if (dotLoc == NSNotFound) { // 没有,
        code = [attrs substringFromIndex:loc];
    } else {
        code = [attrs substringWithRange:NSMakeRange(loc, dotLoc - loc)];
    }

    self.code=code;
}
- (void)setCode:(NSString *)code
{
    _code = code;

    if (!code) {
        return;
    }

    if ([code isEqualToString:WTRPropertyTypeId]) {
        _idType = YES;
    } else if (code.length == 0) {
        _KVCDisabled = YES;
    } else if (code.length > 3 && [code hasPrefix:@"@\""]) {
        // 去掉@"和"，截取中间的类型名称
        _code = [code substringWithRange:NSMakeRange(2, code.length - 3)];
        _typeClass = NSClassFromString(_code);
        _fromFoundation = isClassFromFoundation(_typeClass);
        _numberType = [_typeClass isSubclassOfClass:[NSNumber class]];

    } else if ([code isEqualToString:WTRPropertyTypeSEL] ||
               [code isEqualToString:WTRPropertyTypeIvar] ||
               [code isEqualToString:WTRPropertyTypeMethod]) {
        _KVCDisabled = YES;
    }

    // 是否为数字类型
    NSString *lowerCode = _code.lowercaseString;
    NSArray *numberTypes = @[WTRPropertyTypeInt, WTRPropertyTypeShort, WTRPropertyTypeBOOL1, WTRPropertyTypeBOOL2, WTRPropertyTypeFloat, WTRPropertyTypeDouble, WTRPropertyTypeLong, WTRPropertyTypeLongLong, WTRPropertyTypeChar];
    if ([numberTypes containsObject:lowerCode]) {
        _numberType = YES;

        if ([lowerCode isEqualToString:WTRPropertyTypeBOOL1]
            || [lowerCode isEqualToString:WTRPropertyTypeBOOL2]) {
            _boolType = YES;
        }
    }
}

@end



@implementation NSObject (WTRExtension)


+ (Class)WTR_ClassInArrayName:(NSString *)propertyName
{
    id clazz = nil;
    if ([self respondsToSelector:@selector(WTR_objectClassInArray)]) {
        clazz = [self WTR_objectClassInArray][propertyName];
    }

    // 如果是NSString类型
    if (clazz&&[clazz isKindOfClass:[NSString class]]) {
        clazz = NSClassFromString(clazz);
    }
    return clazz;
}

#pragma mark - 遍历

//遍历继承链
+ (void)WTR_enumerateClasses:(WTRClassesEnumeration)enumeration
{
    // 1.没有block就直接返回
    if (enumeration == nil) return;

    // 2.停止遍历的标记
    BOOL stop = NO;

    // 3.当前正在遍历的类
    Class c = self;

    // 4.开始遍历每一个类
    while (c && !stop) {
        // 4.1.执行操作
        enumeration(c, &stop);

        // 4.2.获得父类
        c = class_getSuperclass(c);

        if (isClassFromFoundation(c)) break;
    }
}
+ (NSMutableArray *)WTR_properties
{
//    缓存
    static NSMutableDictionary *cachedPropertiesDict;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cachedPropertiesDict = [NSMutableDictionary dictionary];
    });

    NSMutableArray *cachedProperties=cachedPropertiesDict[NSStringFromClass(self)];

    if (!cachedProperties) {
        cachedProperties = [NSMutableArray array];

        [self WTR_enumerateClasses:^(__unsafe_unretained Class c, BOOL *stop) {
            // 1.获得所有的成员变量
            unsigned int outCount = 0;
            objc_property_t *properties = class_copyPropertyList(c, &outCount);

            // 2.遍历每一个成员变量
            for (unsigned int i = 0; i<outCount; i++) {
                WTRProperty *property = [WTRProperty new];
                property.property = properties[i];
                property.srcClass = c;

                // 过滤掉Foundation框架类里面的属性
                if (isClassFromFoundation(property.srcClass)) continue;
                // 过滤掉`hash`, `superclass`, `description`, `debugDescription`
                if (isFromNSObjectProtocolProperty(property.name)) continue;


                //如果是数组 获取数组对应的类型名
                if ([property.code isEqualToString:@"NSArray"]||[property.code isEqualToString:@"NSMutableArray"]) {
                    property.objectClassIfArray=[self WTR_ClassInArrayName:property.name];
                }


                [cachedProperties addObject:property];
            }

            // 3.释放内存
            free(properties);
        }];

        cachedPropertiesDict[NSStringFromClass(self)]=cachedProperties;
    }

    return cachedProperties;
}
/**
 *  遍历所有的属性
 */
+ (void)WTR_enumerateProperties:(WTRPropertiesEnumeration)enumeration
{
    static dispatch_semaphore_t signalSemaphore;
    static dispatch_once_t onceTokenSemaphore;
    dispatch_once(&onceTokenSemaphore, ^{
        signalSemaphore = dispatch_semaphore_create(1);
    });

    dispatch_semaphore_wait(signalSemaphore, DISPATCH_TIME_FOREVER);
    NSArray *cachedProperties = [self WTR_properties];// 获得成员变量 需要线程锁
    dispatch_semaphore_signal(signalSemaphore);

    // 遍历成员变量
    BOOL stop = NO;
    for (WTRProperty *property in cachedProperties) {
        enumeration(property, &stop);
        if (stop) break;
    }
}


#pragma mark - 转换为JSON
- (NSData *)WTR_JSONData
{
    if ([self isKindOfClass:[NSString class]]) {
        return [((NSString *)self) dataUsingEncoding:NSUTF8StringEncoding];
    } else if ([self isKindOfClass:[NSData class]]) {
        return (NSData *)self;
    }
    return [NSJSONSerialization dataWithJSONObject:[self WTR_JSONObject] options:kNilOptions error:nil];
}

- (id)WTR_JSONObject
{
    if ([self isKindOfClass:[NSString class]]) {
        return [NSJSONSerialization JSONObjectWithData:[((NSString *)self) dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    } else if ([self isKindOfClass:[NSData class]]) {
        return [NSJSONSerialization JSONObjectWithData:(NSData *)self options:kNilOptions error:nil];
    }

    return self.WTR_keyValues;
}

- (NSString *)WTR_JSONString
{
    if ([self isKindOfClass:[NSString class]]) {
        return (NSString *)self;
    } else if ([self isKindOfClass:[NSData class]]) {
        return [[NSString alloc] initWithData:(NSData *)self encoding:NSUTF8StringEncoding];
    }

    return [[NSString alloc] initWithData:[self WTR_JSONData] encoding:NSUTF8StringEncoding];
}

#pragma mark - 模型 -> 字典
- (NSMutableDictionary *)WTR_keyValues
{
    if ([self isMemberOfClass:NSNull.class]) {
        return nil;//NSNull不处理
    }
    if (isClassFromFoundation([self class])) {
        return (NSMutableDictionary *)self;//基础类不处理
    }

    NSMutableDictionary *keyValues = [NSMutableDictionary dictionary];

    Class clazz = [self class];

    [clazz WTR_enumerateProperties:^(WTRProperty *property, BOOL *stop) {
        @try {

            // 1.取出属性值
            id value = [property valueForObject:self];
            if (!value||[value isKindOfClass:[NSNull class]]) return;

            // 2.如果是模型属性
            Class propertyClass = property.typeClass;
            if (!property.isFromFoundation && propertyClass) {
                value = [value WTR_keyValues];
            } else if ([value isKindOfClass:[NSArray class]]) {
                // 3.处理数组里面有模型的情况
                value = [NSObject WTR_keyValuesArrayWithObjectArray:value];
            } else if (propertyClass == [NSURL class]) {
                value = [value absoluteString];
            }

            keyValues[property.name] = value;

        } @catch (NSException *exception) {
            NSLog(@"WTR_keyValues错误:%@",exception);
        }
    }];

    return keyValues;
}
+ (NSMutableArray *)WTR_keyValuesArrayWithObjectArray:(NSArray *)objectArray
{
    if (![objectArray isKindOfClass:[NSArray class]]) {
//        NSLog(@"objectArray参数不是一个数组");
        return nil;
    }
    NSMutableArray *keyValuesArray = [NSMutableArray array];
    for (id object in objectArray) {
        id convertedObj = [object WTR_keyValues];
        if (convertedObj) {
            [keyValuesArray addObject:convertedObj];
        }
    }
    return keyValuesArray;
}

+ (NSMutableArray *)WTR_ObjectArrayWithKeyValuesArray:(id)keyValuesArray
{
    // 如果是JSON字符串
    keyValuesArray = [keyValuesArray WTR_JSONObject];

    if (![keyValuesArray isKindOfClass:[NSArray class]]) {
//        NSLog(@"keyValuesArray参数不是一个数组");
        return nil;
    }

    // 如果数组里面放的是NSString、NSNumber等数据
    if (isClassFromFoundation(self)) return [NSMutableArray arrayWithArray:keyValuesArray];

    // 2.创建数组
    NSMutableArray *modelArray = [NSMutableArray array];

    // 3.遍历
    for (NSDictionary *keyValues in keyValuesArray) {
        if ([keyValues isKindOfClass:[NSArray class]]){
            [modelArray addObject:[self WTR_ObjectArrayWithKeyValuesArray:keyValues]];
        } else {
            id model = [self WTR_ObjectWithKeyValues:keyValues];
            if (model) [modelArray addObject:model];
        }
    }

    return modelArray;
}
+ (instancetype)WTR_ObjectWithKeyValues:(id)keyValues
{
    // 获得JSON对象
    keyValues = [keyValues WTR_JSONObject];
    if (!keyValues||![keyValues isKindOfClass:[NSDictionary class]]) {
//        NSLog(@"keyValues参数不是一个字典");
        return nil;
    }
    return [[[self alloc] init] WTR_setKeyValues:keyValues];
}
- (instancetype)WTR_setKeyValues:(id)keyValues
{
    // 获得JSON对象
    keyValues = [keyValues WTR_JSONObject];

    if (![keyValues isKindOfClass:[NSDictionary class]]) {
//        NSLog(@"keyValues参数不是一个字典");
        return self;
    }

    Class clazz = [self class];

    //通过封装的方法回调一个通过运行时编写的，用于返回属性列表的方法。
    [clazz WTR_enumerateProperties:^(WTRProperty *property, BOOL *stop) {
        @try {

            id value=[keyValues objectForKey:property.name];

            // 2.复杂处理
            Class propertyClass = property.typeClass;

            // 不可变 -> 可变处理
            if (propertyClass == [NSMutableArray class] && [value isKindOfClass:[NSArray class]]) {
                value = [NSMutableArray arrayWithArray:value];
            } else if (propertyClass == [NSMutableDictionary class] && [value isKindOfClass:[NSDictionary class]]) {
                value = [NSMutableDictionary dictionaryWithDictionary:value];
            } else if (propertyClass == [NSMutableString class] && [value isKindOfClass:[NSString class]]) {
                value = [NSMutableString stringWithString:value];
            } else if (propertyClass == [NSMutableData class] && [value isKindOfClass:[NSData class]]) {
                value = [NSMutableData dataWithData:value];
            }

            Class objectClass = property.objectClassIfArray;

            if (!property.isFromFoundation && propertyClass) { // 模型属性
                value = [[[propertyClass alloc] init] WTR_setKeyValues:keyValues];
            } else if (objectClass) {
                if (objectClass == [NSURL class] && [value isKindOfClass:[NSArray class]]) {
                    // string array -> url array
                    NSMutableArray *urlArray = [NSMutableArray array];
                    for (NSString *string in value) {
                        if (![string isKindOfClass:[NSString class]]) continue;
                        [urlArray addObject:[NSURL URLWithString:string]];
                    }
                    value = urlArray;
                } else { // 字典数组-->模型数组
                    value = [objectClass WTR_ObjectArrayWithKeyValuesArray:value];
                }
            } else {
                if (propertyClass == [NSString class]) {
                    if ([value isKindOfClass:[NSNumber class]]) {
                        // NSNumber -> NSString
                        value = [value description];
                    } else if ([value isKindOfClass:[NSURL class]]) {
                        // NSURL -> NSString
                        value = [value absoluteString];
                    }
                } else if ([value isKindOfClass:[NSString class]]) {
                    if (propertyClass == [NSURL class]) {
                        // NSString -> NSURL
                        // 字符串转码

                        value = [NSURL URLWithString:value];
//                        value = [value mj_url];

                    } else if (property.isNumberType) {
                        NSString *oldValue = value;

                        // NSString -> NSNumber
                        if (property.typeClass == [NSDecimalNumber class]) {
                            value = [NSDecimalNumber decimalNumberWithString:oldValue];
                        } else {
                            value = @([NSDecimalNumber decimalNumberWithString:oldValue].doubleValue);
                        }

                        // 如果是BOOL
                        if (property.isBoolType) {
                            // 字符串转BOOL（字符串没有charValue方法）
                            // 系统会调用字符串的charValue转为BOOL类型
                            NSString *lower = [oldValue lowercaseString];
                            if ([lower isEqualToString:@"yes"] || [lower isEqualToString:@"true"]) {
                                value = @YES;
                            } else if ([lower isEqualToString:@"no"] || [lower isEqualToString:@"false"]) {
                                value = @NO;
                            }
                        }
                    }
                } else if ([value isKindOfClass:[NSNumber class]] && propertyClass == [NSDecimalNumber class]){
                    // 过滤 NSDecimalNumber类型
                    if (![value isKindOfClass:[NSDecimalNumber class]]) {
                        value = [NSDecimalNumber decimalNumberWithDecimal:[((NSNumber *)value) decimalValue]];
                    }
                }

                // value和property类型不匹配
                if (propertyClass && ![value isKindOfClass:propertyClass]) {
                    value = nil;
                }
            }

            // 3.赋值
            [property setValue:value forObject:self];
        } @catch (NSException *exception) {
            NSLog(@"WTR_setKeyValues:%@",exception);
        }
    }];
    return self;
}



@end
