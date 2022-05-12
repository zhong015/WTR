//
//  ViewController.m
//  WTRGitCs
//
//  Created by wfz on 2017/5/23.
//  Copyright © 2017年 wfz. All rights reserved.
//

#import "ViewController.h"
#import "WTRDefine.h"
#import "NSObject+WTRExtension.h"
#import "UIImage+WTRManager.h"
#import "WTRImageListShow.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    

}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    self.view.backgroundColor=RANDCOLOR;
    
//    [WTRHUD show];
//    [WTRHUD dismiss];
    
    [WTRHUD showSuccessInView:self.view WithStatus:@"哈哈哈"];
//    [WTRHUD dismissInView:self.view];
    
//    [WTRHUD showSuccess:@"哦哦哦"];
    
//    [self testhud];
//    [WTRHUD show];
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        [WTRHUD showSuccessInView:self.view WithStatus:@"ooo"];
//    });
//    [self performSelector:@selector(testhud) withObject:nil afterDelay:3];
}
-(void)testhud
{
    [WTRHUD dismiss];
    return;
    UIImage *im1=[UIImage imageWithColor:RANDCOLOR size:CGSizeMake(50+arc4random()%1000/1000.0*150, 50+arc4random()%1000/1000.0*150)];
    UIImage *im2=[UIImage imageWithColor:RANDCOLOR size:CGSizeMake(50+arc4random()%1000/1000.0*150, 50+arc4random()%1000/1000.0*150)];
    UIImage *im3=[UIImage imageWithColor:RANDCOLOR size:CGSizeMake(50+arc4random()%1000/1000.0*150, 50+arc4random()%1000/1000.0*150)];
    UIImage *im4=[UIImage imageWithColor:RANDCOLOR size:CGSizeMake(50+arc4random()%1000/1000.0*150, 50+arc4random()%1000/1000.0*150)];
    NSArray *imarr=@[im1,im2,im3,im4];
    [WTRImageListShow showWithListArray:@[@"0",@"1",@"2",@"3"] current:@"2" configOne:^(UIImageView * _Nonnull imv, NSString *imageUrlOrStr, UIView * _Nullable contentView, UIScrollView * _Nullable scrollView) {
        imv.image=imarr[imageUrlOrStr.intValue];
    } completion:^{
        
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
