//
//  WTREpubPageViewController.m
//  WTREpubReader
//
//  Created by wfz on 2017/3/20.
//  Copyright © 2017年 wfz. All rights reserved.
//

#import "WTREpubPageViewController.h"

@interface WTREpubPageViewController ()

@end

@implementation WTREpubPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[WTREpubConfig shareInstance].themeColor;
    
    UIView *showv=[self.epubpage getView];
    [self.view addSubview:showv];
}
-(void)dealloc
{
    NSLog(@"WTREpubPageViewController dealloc");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
