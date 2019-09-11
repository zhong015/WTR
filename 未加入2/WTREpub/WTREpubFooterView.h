//
//  WTREpubFooterView.h
//  WTREpubReader
//
//  Created by wfz on 2017/3/21.
//  Copyright © 2017年 wfz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WTREpubFooterView : UIView

@property(nonatomic,copy)void (^retpageCb)(NSInteger pagenum);

@property(nonatomic,copy)void (^retChapterShow)(void);

@property(nonatomic,copy)void (^retupdataShow)(void);

-(void)setcurPage:(NSInteger)curpage totalPage:(NSInteger)totalpage; // 0 - (totalpage-1)


@end
