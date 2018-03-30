//
//  WTRPhotosViewController.h
//  asd
//
//  Created by wfz on 2017/3/11.
//  Copyright © 2017年 wfz. All rights reserved.
//

//取照片

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import <PhotosUI/PhotosUI.h>

@protocol WTRPhotosViewControllerDelegate <NSObject>

-(void)selectImageArray:(NSArray <UIImage *> *)imageArray;

@optional

-(void)selectMovPathArray:(NSArray <NSString *> *)movPathArray;//视频选取回调

//用于选择图片后处理ViewController Push 默认YES
-(BOOL)dismissMethodShouldAction:(UINavigationController *)WTRPhotoNav;

@end

@interface WTRPhotosViewController : UIViewController

+(void)showWTRPhotosViewControllerWithDelegate:(id <WTRPhotosViewControllerDelegate> )delegate;

+(void)showWTRPhotosViewControllerWithDelegate:(id <WTRPhotosViewControllerDelegate> )delegate MaxSelectImageNum:(NSInteger)imageNum videoNum:(NSInteger)videoNum;

/*
 imageNum:  最大选择图片的数量
 videoNum： 最大选择视频的数量
 duration:  可选择视频最大时长 (秒)  0 未限制
 */
+(void)showWTRPhotosViewControllerWithDelegate:(id <WTRPhotosViewControllerDelegate> )delegate MaxSelectImageNum:(NSInteger)imageNum videoNum:(NSInteger)videoNum MaxDuration:(NSInteger)maxDuration barTintColor:(UIColor *)barTintColor tintColor:(UIColor *)tintColor statusBarIsBlack:(BOOL)statusBarIsBlack;

@end
