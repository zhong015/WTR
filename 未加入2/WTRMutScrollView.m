//
//  WTRMutScrollView.m
//  CnkiIPhoneClient
//
//  Created by wfz on 2019/6/3.
//  Copyright © 2019 net.cnki.www. All rights reserved.
//

#import "WTRMutScrollView.h"

@interface WTRMutScrollView ()

@end

@implementation WTRMutScrollView
{
    NSMutableArray *buArray;
    NSArray *_titieArray;

    UIView *linv;

    NSArray *_cselectColorArray;//选择的颜色数组
    UIColor *_unSelectColor;//未选择的颜色

    NSInteger currentIndex;
    CGFloat ww;
    CGFloat _pro;
    NSMutableArray <NSNumber *>*titlewwArray;

    CGFloat _lineHeight;
    CGFloat _leftjiange;
    CGFloat _rightjiange;
    CGFloat _topjiange;
    CGFloat _bottomjiange;
}
-(void)setTitleArray:(NSArray <NSString *>*)titieArray selectColor:(NSArray <UIColor *>*)cselectColorArray unSelectColor:(UIColor *)cunSelectColor lineHeight:(CGFloat)lineHeight font:(UIFont *)font leftjiange:(CGFloat)leftjiange rightjiange:(CGFloat)rightjiange topjiange:(CGFloat)topjiange bottomjiange:(CGFloat)bottomjiange
{
    if (!ISArray(titieArray)||titieArray.count==0) {
        return;
    }

    _cselectColorArray=cselectColorArray;
    _unSelectColor=cunSelectColor;

    _lineHeight=lineHeight;
    _leftjiange=leftjiange;
    _rightjiange=rightjiange;
    _topjiange=topjiange;
    _bottomjiange=bottomjiange;

    currentIndex=0;

    buArray=[NSMutableArray array];
    titlewwArray=[NSMutableArray array];
    _titieArray=titieArray;

    ww=(self.width-_leftjiange-_rightjiange)/titieArray.count;

    for (int i=0; i<titieArray.count; i++) {
        UILabel *la=[UILabel new];
        [buArray addObject:la];
        la.text=titieArray[i];
        la.textAlignment=NSTextAlignmentCenter;
        la.font=font;
        la.frame=CGRectMake(_leftjiange+ww*i, _topjiange, ww, self.height-_topjiange-_bottomjiange);
        la.tag=i;
        UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(laclick:)];
        la.userInteractionEnabled=YES;
        [la addGestureRecognizer:tap];
        [self addSubview:la];

        la.backgroundColor=[UIColor clearColor];

        CGSize tsize=[WTRZX getsizeOfStr:titieArray[i] Fontsize:la.font Width:self.width];
        [titlewwArray addObject:[NSNumber numberWithFloat:tsize.width]];
    }

    linv=nil;

    if (_lineHeight>0.01) {
        linv=[[UIView alloc] init];
        linv.backgroundColor=_cselectColorArray[currentIndex];
        [self addSubview:linv];
    }

    [self updatecurrentIndexisan:NO];
}
-(void)laclick:(UITapGestureRecognizer *)tap
{
    currentIndex=tap.view.tag;
    [self updatecurrentIndexisan:YES];
    if (self.retcb) {
        self.retcb(currentIndex);
    }
}
-(void)updatecurrentIndexisan:(BOOL)isan
{
    _pro=currentIndex*1.0/(_titieArray.count-1);
    [self setPro:_pro isan:isan];
}
-(void)setPro:(CGFloat)pro
{
    [self setPro:pro isan:NO];
}
-(void)setPro:(CGFloat)pro isan:(BOOL)isan
{
    _pro=pro;
    CGFloat zc=self.width-ww-_leftjiange-_rightjiange;
    CGFloat linvcener=zc*_pro+ww/2.0+_leftjiange;

    CGFloat buww1=0,buww2=0;
    CGFloat buww=0;

    for (int i=0; i<buArray.count; i++) {
        UILabel *la=buArray[i];
        CGFloat juli=ABS(la.centerX-linvcener);
        if (juli<ww) {
            CGFloat bili=juli/ww;

            UIColor *selectColor=_cselectColorArray[i];

            CGFloat sr,sg,sb,ur,ug,ub,cr,cg,cb;
            [selectColor getRed:&sr green:&sg blue:&sb alpha:nil];
            [_unSelectColor getRed:&ur green:&ug blue:&ub alpha:nil];
            cr=(ur-sr)*bili+sr;
            cg=(ug-sg)*bili+sg;
            cb=(ub-sb)*bili+sb;
            la.textColor=[UIColor colorWithRed:cr green:cg blue:cb alpha:1.0];

            if (buww1<0.1) {
                buww1=titlewwArray[i].floatValue;
                continue;
            }
            if (buww2<0.1) {
                buww2=titlewwArray[i].floatValue;
            }
            if (buww<0.1) {
                buww=(buww1-buww2)*bili+buww2;
            }
        }else{
            la.textColor=_unSelectColor;
        }
    }
    if (buww<0.1) {
        buww=buww1;
    }

    if (linv) {
        if (isan) {
            [UIView animateWithDuration:0.25 animations:^{
                linv.frame=CGRectMake(linvcener-buww/2.0, self.height-_lineHeight, buww, _lineHeight);
            }];
        }else{
            linv.frame=CGRectMake(linvcener-buww/2.0, self.height-_lineHeight, buww, _lineHeight);
        }

        if (_titieArray.count>1) {
            CGFloat indexf=_pro*(_titieArray.count-1);
            int indexup=ceilf(indexf);
            int indexdown=floorf(indexf);
            if (indexup>=0&&indexup<_titieArray.count&&indexdown>=0&&indexdown<_titieArray.count) {
                UIColor *color1=_cselectColorArray[indexdown];
                UIColor *color2=_cselectColorArray[indexup];

                CGFloat bili=(indexf-indexdown);
                if (bili<0) {
                    bili=0;
                }
                if (bili>1) {
                    bili=1;
                }
                CGFloat sr,sg,sb,ur,ug,ub,cr,cg,cb;
                [color1 getRed:&sr green:&sg blue:&sb alpha:nil];
                [color2 getRed:&ur green:&ug blue:&ub alpha:nil];
                cr=(ur-sr)*bili+sr;
                cg=(ug-sg)*bili+sg;
                cb=(ub-sb)*bili+sb;

                linv.backgroundColor=[UIColor colorWithRed:cr green:cg blue:cb alpha:1.0];
            }
        }
    }
}



@end
