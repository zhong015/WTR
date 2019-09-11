//
//  WTREpubChapterView.h
//  PDFTXTREADER
//
//  Created by wfz on 2017/3/27.
//  Copyright © 2017年 wfz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface WTREpubChapterView : UIView


+(void)ShowCurintChapterInView:(UIView *)fview withHtmlFileArray:(NSArray *)fileArray curintIndex:(NSInteger) index SelectCb:(void (^)(NSInteger index))cb;


@end
