//
//  WTRPageNumShowrView.m
//  ZZSWTR
//
//  Created by wfz on 16/7/14.
//  Copyright © 2016年 wfz. All rights reserved.
//

#import "WTRPageNumShowrView.h"
#import "WTRDefine.h"

@interface WTRPageNumShowLabel : UILabel

@end
@implementation WTRPageNumShowLabel
@end

@implementation WTRPageNumShowrView

+(void)showCurintPage:(NSInteger)curpage TotalPage:(NSInteger)totalpage toview:(UIView *)baseview Bottom:(CGFloat)bottomf
{
    if (!baseview) {
        return;
    }
    NSString *showstr=[NSString stringWithFormat:@"%ld of %ld",curpage+1,totalpage];

    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        for (UIView *vv in baseview.subviews) {
            if ([vv isKindOfClass:[WTRPageNumShowLabel class]]) {
                
                WTRPageNumShowLabel *showmsgla=(WTRPageNumShowLabel *)vv;
                showmsgla.text=showstr;
//                [showmsgla sizeToFit];
//                showmsgla.frame=CGRectInset(showmsgla.frame, -10, -9);
                return ;
            }
        }
        
        WTRPageNumShowLabel *showmsgla=[WTRPageNumShowLabel new];
        showmsgla.textColor=[UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.00];//UIColorFromRGB(0x999999);
        showmsgla.backgroundColor=[UIColor colorWithRed:0.24 green:0.24 blue:0.24 alpha:1.00];
        showmsgla.textAlignment=NSTextAlignmentCenter;
        showmsgla.text=showstr;
        showmsgla.numberOfLines=0;
        showmsgla.font=[UIFont systemFontOfSize:15];
        LayerMakeCB(showmsgla, 1, 1, [UIColor colorWithRed:0.76 green:0.76 blue:0.76 alpha:1.00].CGColor);
        
        [showmsgla sizeToFit];
        showmsgla.frame=CGRectInset(showmsgla.frame, -10, -9);
        
        [baseview addSubview:showmsgla];
        showmsgla.center=CGPointMake(baseview.bounds.size.width/2.0, baseview.bounds.size.height-bottomf);
        showmsgla.autoresizingMask=UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        
        showmsgla.alpha=0;
        [UIView animateWithDuration:0.25 animations:^{
            showmsgla.alpha=1;
        } completion:^(BOOL finished) {
            [UIView animateKeyframesWithDuration:0.25 delay:1.5 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
                showmsgla.alpha=0;
            } completion:^(BOOL finished) {
                
                 [showmsgla removeFromSuperview];
            }];
        }];

    }];
    

}

@end
