//
//  WTRImageCutView.h
//  WTRGitCs
//
//  Created by wfz on 2018/1/18.
//  Copyright © 2018年 wfz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WTRImageCutView : UIView

@property(nonatomic,assign)CGSize cutToSize;

@property(nonatomic,copy)void (^retcb)(UIImage *outImage);


/*
 vc 要加 self.automaticallyAdjustsScrollViewInsets=NO;
 */
@property(nonatomic,strong)UIImage *sourceImage;//最后赋值这个


-(void)quedinglclick;

@end
