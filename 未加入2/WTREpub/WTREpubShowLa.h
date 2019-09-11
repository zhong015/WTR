//
//  WTREpubShowLa.h
//  WTREpubReader
//
//  Created by wfz on 2017/3/16.
//  Copyright © 2017年 wfz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

@interface WTREpubShowLa : UIView


@property(nonatomic,strong)NSAttributedString *attrStr;

@property(nonatomic,assign)CTFrameRef strRef;

@end
