//
//  WTRFilePath.m
//  WTRGitCs
//
//  Created by wfz on 2017/5/24.
//  Copyright © 2017年 wfz. All rights reserved.
//

#import "WTRFilePath.h"
#import <sys/xattr.h>

@interface WTRFilePath ()

@property(nonatomic,copy)NSString *myDocumentPath;
@property(nonatomic,copy)NSString *myLibraryPath;
@property(nonatomic,copy)NSString *myCachePath;

@end

static id _s;
@implementation WTRFilePath
+(WTRFilePath *)shareInstence
{
    @synchronized(self){
        if (_s==nil) {
            _s=[[[self class]alloc]init];
        }
    }
    return _s;
}

+ (NSString *)getDocumentPath
{
    if ([WTRFilePath shareInstence].myDocumentPath) {
        return [WTRFilePath shareInstence].myDocumentPath;
    }
    NSArray *path  = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *absolutePath = [path lastObject];
    [WTRFilePath shareInstence].myDocumentPath=absolutePath;
    return absolutePath;
}
+ (NSString *)getLibraryPath
{
    if ([WTRFilePath shareInstence].myLibraryPath) {
        return [WTRFilePath shareInstence].myLibraryPath;
    }
    NSArray *path  = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *absolutePath = [path lastObject];
    [WTRFilePath shareInstence].myLibraryPath=absolutePath;
    return absolutePath;
}
+ (NSString *)getCachePath
{
    if ([WTRFilePath shareInstence].myCachePath) {
        return [WTRFilePath shareInstence].myCachePath;
    }
    NSArray *path  = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *absolutePath = [path lastObject];
    [WTRFilePath shareInstence].myCachePath=absolutePath;
    return absolutePath;
}

+(NSString *)getTemporaryPath
{
    return NSTemporaryDirectory();
}

+(void)excludeBackUp
{
    NSArray *documents = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [documents objectAtIndex:0];
    NSURL *url = [NSURL URLWithString:path];
    [WTRFilePath addSkipBackupAttributeToItemAtURL:url];
    
    NSArray *libraries = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *path1 = [libraries objectAtIndex:0];
    NSURL *url1= [NSURL URLWithString:path1];
    [WTRFilePath addSkipBackupAttributeToItemAtURL:url1];
}

//禁止被同步到iCloud
+ (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    const char* filePath = [[URL path] fileSystemRepresentation];
    
    const char* attrName = "com.apple.MobileBackup";
    u_int8_t attrValue = 1;
    
    int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
    return result == 0;
}

@end
