//
//  ImageCutViewController.h
//  WTRGitCs
//
//  Created by wfz on 2018/1/18.
//  Copyright © 2018年 wfz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageCutViewController : UIViewController

@property(nonatomic,assign)CGSize cutToSize;

@property(nonatomic,strong)UIImage *sourceImage;

@property(nonatomic,copy)void (^retcb)(UIImage *outImage);

@end
