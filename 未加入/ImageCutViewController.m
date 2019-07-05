//
//  ImageCutViewController.m
//  WTRGitCs
//
//  Created by wfz on 2018/1/18.
//  Copyright © 2018年 wfz. All rights reserved.
//

#import "ImageCutViewController.h"
#import "WTRImageCutView.h"
#import "WTRBaseDefine.h"

@interface ImageCutViewController ()

@end

@implementation ImageCutViewController
{
    WTRImageCutView *cutv;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor=[UIColor blackColor];
    
    self.navigationItem.title=@"剪切图片";
    
    self.automaticallyAdjustsScrollViewInsets=NO;
    
    cutv=[[WTRImageCutView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    
    cutv.cutToSize=self.cutToSize;
    
    cutv.retcb = self.retcb;
    
    cutv.sourceImage=self.sourceImage;
    
    [self.view addSubview:cutv];
    
    UIBarButtonItem *queding=[[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:cutv action:@selector(quedinglclick)];
    self.navigationItem.rightBarButtonItem=queding;
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
