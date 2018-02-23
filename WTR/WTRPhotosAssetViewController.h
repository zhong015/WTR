//
//  WTRPhotosAssetViewController.h
//  asd
//
//  Created by wfz on 2017/3/11.
//  Copyright © 2017年 wfz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import <PhotosUI/PhotosUI.h>
#import "WTRPhotosViewController.h"

@interface WTRPhotosAssetViewController : UIViewController

@property(nonatomic,strong)PHFetchResult *fetchResult;
@property(nonatomic,assign)id <WTRPhotosViewControllerDelegate> delegate;

@property(nonatomic,assign)NSInteger maxSelectNum;//最大选择的个数  默认1个

@property(nonatomic,assign)CGSize targetSize;
@property(nonatomic,assign)PHImageContentMode contentMode;

@property(nonatomic,assign) BOOL StatusBarIsBlack;//状态栏文字是否是黑色 默认NO (修改的时候 推荐 写在界面init方法里,可以提前改变状态)


@end
