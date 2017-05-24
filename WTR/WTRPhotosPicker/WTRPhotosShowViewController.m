//
//  WTRPhotosShowViewController.m
//  asd
//
//  Created by wfz on 2017/3/14.
//  Copyright © 2017年 wfz. All rights reserved.
//

#import "WTRPhotosShowViewController.h"

@interface WTRPhotosShowViewController ()

@end

@implementation WTRPhotosShowViewController
{
    PHImageRequestID reqid;
    PHLivePhotoView *liveview;
}

-(void)backMethod
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    if ([UIDevice currentDevice].systemVersion.floatValue>=9.1&&self.asset.mediaSubtypes&PHAssetMediaSubtypePhotoLive) {
        [self loadLivePhoto];
    }
}
-(void)loadLivePhoto
{
    PHLivePhotoRequestOptions *options=[[PHLivePhotoRequestOptions alloc]init];
    options.deliveryMode=PHImageRequestOptionsDeliveryModeHighQualityFormat;
    
    CGFloat scale=[UIScreen mainScreen].scale;
    
    reqid=[[PHImageManager defaultManager] requestLivePhotoForAsset:self.asset targetSize:CGSizeMake(scale*self.view.bounds.size.width, scale*self.view.bounds.size.height) contentMode:PHImageContentModeAspectFit options:options resultHandler:^(PHLivePhoto * _Nullable livePhoto, NSDictionary * _Nullable info) {
        if (livePhoto) {
            liveview=[[PHLivePhotoView alloc]initWithFrame:self.view.bounds];
            liveview.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
            [self.view addSubview:liveview];
            liveview.livePhoto=livePhoto;
            [liveview startPlaybackWithStyle:PHLivePhotoViewPlaybackStyleHint];
            UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(liveviewPlay)];
            [self.view addGestureRecognizer:tap];
        }
    }];
    
}
-(void)liveviewPlay
{
    if (liveview) {
        [liveview startPlaybackWithStyle:PHLivePhotoViewPlaybackStyleFull];
    }
}
-(void)dealloc
{
    NSLog(@"dealloc");
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
