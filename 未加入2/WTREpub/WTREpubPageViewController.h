//
//  WTREpubPageViewController.h
//  WTREpubReader
//
//  Created by wfz on 2017/3/20.
//  Copyright © 2017年 wfz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WTREpubHtmlFile.h"

@interface WTREpubPageViewController : UIViewController

@property(nonatomic,strong)WTREpubPage *epubpage;
@property(nonatomic,strong)WTREpubHtmlFile *htmlfile;

@end
