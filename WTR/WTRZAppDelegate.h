//
//  WTRAppDelegate.h
//  WTRGitCs
//
//  Created by wfz on 2017/5/23.
//  Copyright © 2017年 wfz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface WTRAppDelegate : NSObject

@property (strong, nonatomic) UIWindow *window;

@property (copy) void (^backgroundSessionCompletionHandler)(void);

@end
