//
//  UIViewWTRManager.m
//  WTRGitCs
//
//  Created by wfz on 2019/8/5.
//  Copyright © 2019 wfz. All rights reserved.
//

#import "UIView+WTRManager.h"

@implementation UIView (WTRManager)

-(UIImage *)getScreenshotWithOpaque:(BOOL)opaque scale:(CGFloat)scale
{
    if (scale<1) {
        scale=1.0;
    }
    if (scale>3) {
        scale=3;
    }

    UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.bounds.size.width, self.bounds.size.height),opaque,scale);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * viewImage =UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return viewImage;
}

@end
