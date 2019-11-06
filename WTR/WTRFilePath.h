//
//  WTRFilePath.h
//  WTRGitCs
//
//  Created by wfz on 2017/5/24.
//  Copyright © 2017年 wfz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WTRFilePath : NSObject

+ (NSString *)getDocumentPath;
+ (NSString *)getLibraryPath;
+ (NSString *)getCachePath;
+ (NSString *)getTemporaryPath;


//禁止被同步到iCloud
+(void)excludeBackUpAll;
+(BOOL)addSkipBackupAttributeToPath:(NSString *)path;

@end
