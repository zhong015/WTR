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

@end
