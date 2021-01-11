//
//  AppDelegate.m
//  WTRGitCs
//
//  Created by wfz on 2017/5/23.
//  Copyright © 2017年 wfz. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "UIImage+WTRManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window=[[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor=[UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    self.window.rootViewController=[[UINavigationController alloc] initWithRootViewController:[ViewController new]];
    
//    UIImage *im=[UIImage QRCodeImageWithStr:@"https://zwwh.cnki.net/web/m/download/index" size:CGSizeMake(100, 100) foregroundColor:[UIColor blackColor] backgroundColor:[UIColor clearColor]];
//    [UIImagePNGRepresentation(im) writeToFile:@"/Users/wfz/Desktop/cnkizwwh.png" atomically:YES];
    
//    NSString *strurl=[NSString WTR_urlStrWithComponents:@{@"asd":@"1",@"asd8":@"2asd",@"as2d":@"o2o"} prefix:@"http://asd.asd.com"];
//    NSLog(@"%@",strurl);
    
    NSLog(@"%.2f %.2f %.2f %.2f",WTRSafeTop,WTRSafeLeft,WTRSafeBottom,WTRSafeRight);

    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
