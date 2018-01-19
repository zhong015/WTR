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

#define WTRPhotoImageWidth 80  //图片显示宽
#define WTRPhotoImageHeight 80 //图片显示高

#define ShowLivePhotoOnly 0    //只显示Live图片
#define ISYShowLivePhoto 0     //是否有点击预览Live图片按钮

#define IsShowAddAlbumBu 0     //是否显示添加相册集按钮 

@protocol WTRPhotosViewControllerDelegate <NSObject>

-(void)selectWTRImageArray:(NSArray <UIImage *> *)imageArray;

@optional

-(void)selectWTRLivePhotoJPGAndMovPathArray:(NSArray <NSString *> *)jpgAndMovPathArray;

//用于选择图片后处理ViewController Push 默认YES
-(BOOL)dismissMethodShouldAction:(UINavigationController *)WTRPhotoNav;

@end

@interface WTRPhotosViewController : UIViewController

+(void)showWTRPhotosViewControllerWithDelegate:(id <WTRPhotosViewControllerDelegate> )delegate;

+(void)showWTRPhotosViewControllerWithDelegate:(id <WTRPhotosViewControllerDelegate> )delegate MaxSelectNum:(NSInteger)maxnum;

+(void)showWTRPhotosViewControllerWithDelegate:(id <WTRPhotosViewControllerDelegate> )delegate MaxSelectNum:(NSInteger)maxnum targetSize:(CGSize)targetSize contentMode:(PHImageContentMode)contentMode;

@end
