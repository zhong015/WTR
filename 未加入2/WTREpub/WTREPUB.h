//
//  WTREPUB.h
//  WTREpubReader
//
//  Created by wfz on 2017/3/15.
//  Copyright © 2017年 wfz. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface WTREPUB : NSObject

+(void)OpenEpubFile:(NSString *)filePath;
+(void)OpenEpubFile:(NSString *)filePath tmpkey:(NSString *)epubCode;

+(void)closeCurintFile;

+(void)clearTmpFile:(NSString *)filepath;//清理对应的

@end



