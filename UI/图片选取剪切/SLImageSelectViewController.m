//
//  SLImageSelectViewController.m
//  WTRGitCs
//
//  Created by wfz on 2018/1/19.
//  Copyright © 2018年 wfz. All rights reserved.
//

#import "SLImageSelectViewController.h"
#import "WTRPhotosViewController.h"
#import "ImageCutViewController.h"

@interface SLImageSelectViewController ()<WTRPhotosViewControllerDelegate>

@end

@implementation SLImageSelectViewController
{
    UIImage *_selectim;
    UINavigationController *_WTRPhotoNav;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor=[UIColor whiteColor];
    
    UIButton *bu=[UIButton new];
    
    bu.frame=CGRectMake(30, 150, 150, 40);
    [bu setTitle:@"相册选取" forState:UIControlStateNormal];
    [bu setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.view addSubview:bu];
    
    [bu addTarget:self action:@selector(selectimage) forControlEvents:UIControlEventTouchUpInside];
}


-(void)selectimage
{
    [WTRPhotosViewController showWTRPhotosViewControllerWithDelegate:self MaxSelectImageNum:3 videoNum:0 MaxDuration:10 barTintColor:[UIColor blueColor] tintColor:[UIColor whiteColor] statusBarIsBlack:NO];
}
-(void)selectImageArray:(NSArray <UIImage *> *)imageArray;
{
    if (imageArray.count>0) {
        _selectim=imageArray.firstObject;
    }
}
-(BOOL)dismissMethodShouldAction:(UINavigationController *)WTRPhotoNav
{
    _WTRPhotoNav=WTRPhotoNav;
    
    ImageCutViewController *imcut=[ImageCutViewController new];
    
    imcut.sourceImage=_selectim;
    imcut.cutToSize=CGSizeMake(200, 100);
    
    imcut.retcb = ^(UIImage *outImage) {
        NSLog(@"outImage:%.2f, %.2f",outImage.size.width,outImage.size.height);
        
        UIImageView *imv=[[UIImageView alloc] initWithFrame:CGRectMake(0,190, ScreenWidth, 200)];
        imv.contentMode=UIViewContentModeScaleAspectFit;
        imv.image=outImage;
        [self.view addSubview:imv];
        
        [_WTRPhotoNav dismissViewControllerAnimated:YES completion:nil];
    };
    [WTRPhotoNav pushViewController:imcut animated:YES];
    
    return NO;
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
