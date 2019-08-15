//
//  UIViewWTRManager.h
//  WTRGitCs
//
//  Created by wfz on 2019/8/5.
//  Copyright © 2019 wfz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (WTRManager)

//得到view的截图 包含子view
-(UIImage *)getScreenshotWithOpaque:(BOOL)opaque scale:(CGFloat)scale;

@end

NS_ASSUME_NONNULL_END
