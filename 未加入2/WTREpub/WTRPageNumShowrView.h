//
//  WTRPageNumShowrView.h
//  ZZSWTR
//
//  Created by wfz on 16/7/14.
//  Copyright © 2016年 wfz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WTRPageNumShowrView : UIView


+(void)showCurintPage:(NSInteger)curpage TotalPage:(NSInteger)totalpage toview:(UIView *)baseview Bottom:(CGFloat)bottomf;

@end
