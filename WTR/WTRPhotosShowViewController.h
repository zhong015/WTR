//
//  WTRPhotosShowViewController.h
//  asd
//
//  Created by wfz on 2017/3/14.
//  Copyright © 2017年 wfz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import <PhotosUI/PhotosUI.h>

@interface WTRPhotosShowViewController : UIViewController

@property(nonatomic,strong)PHAsset *asset;

@property(nonatomic,assign) BOOL StatusBarIsBlack;//状态栏文字是否是黑色 默认NO (修改的时候 推荐 写在界面init方法里,可以提前改变状态)

@end
