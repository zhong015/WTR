//
//  WTRPhotosAssetViewController.m
//  asd
//
//  Created by wfz on 2017/3/11.
//  Copyright © 2017年 wfz. All rights reserved.
//

#import "WTRPhotosAssetViewController.h"
#import "PHIMCollectionViewCell.h"
#import "WTRBaseDefine.h"

@interface WTRPhotosAssetViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,PHPhotoLibraryChangeObserver>

@end

@implementation WTRPhotosAssetViewController
{
    UICollectionView *_collection;
    PHCachingImageManager *manager;
    CGRect previousPreheatRect;
    
    int selectType;//0 都可以选  1选择图片 2选择视频
    NSInteger loadnum;
    NSMutableArray *selectArray;
    
    BOOL isneedReload;
    
    BOOL iswancheng;
    
    CGFloat ww,hh;
    CGFloat jiange;
    
    UICollectionViewFlowLayout *laout;
}

-(id)init
{
    self=[super init];
    if (self) {
        self.StatusBarIsBlack=NO;
    }
    return self;
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    if (self.StatusBarIsBlack) {
        return UIStatusBarStyleDefault;
    }
    return UIStatusBarStyleLightContent;
}
-(void)updatecellSizeWWHH
{
    int nh=4;
    jiange=4;
    
    ww=(self.view.width-jiange*(nh+1))/nh;
    hh=ww;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
  
    if (self.maxSelectImageNum<=0&&self.maxSelectVideoNum<=0) {
        self.maxSelectImageNum=1;
    }
    [self resetSelectType];

    selectArray=[NSMutableArray array];
    
    manager=[[PHCachingImageManager alloc] init];
    
    if (!self.fetchResult) {
        PHFetchOptions *allPhotosOptions=[[PHFetchOptions alloc] init];
        allPhotosOptions.sortDescriptors=@[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
        self.fetchResult=[PHAsset fetchAssetsWithOptions:allPhotosOptions];
    }
    if (self.fetchResult.count==0) {
        [self showmsg];
        return;
    }
    
    if (self.xcName) {
        UILabel *la=[UILabel new];
        la.text=self.xcName;
        la.textColor=[UIColor whiteColor];
        la.textAlignment=NSTextAlignmentCenter;
        la.font=[UIFont systemFontOfSize:18];
        [la sizeToFit];
        self.navigationItem.titleView=la;
    }

    [self updatecellSizeWWHH];
    
    laout=[[UICollectionViewFlowLayout alloc] init];
    laout.itemSize=CGSizeMake(ww, hh);
    laout.minimumLineSpacing=jiange;
    laout.minimumInteritemSpacing=jiange;
    laout.sectionInset=UIEdgeInsetsMake(jiange, jiange, jiange, jiange);
    
    _collection=[[UICollectionView alloc]initWithFrame:self.view.bounds collectionViewLayout:laout];
    _collection.delegate=self;
    _collection.dataSource=self;
    [self.view addSubview:_collection];
    _collection.contentInset=UIEdgeInsetsZero;
    _collection.alwaysBounceVertical=YES;
    
    [_collection registerClass:[PHIMCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    _collection.backgroundColor=[UIColor whiteColor];
    _collection.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    
    iswancheng=NO;
    self.navigationItem.rightBarButtonItem =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(wancheng)];
}
-(void)resetSelectType
{
    selectType=0;
    if (self.maxSelectImageNum>0&&self.maxSelectVideoNum<=0) {
        selectType=1;
    }
    if (self.maxSelectImageNum<=0&&self.maxSelectVideoNum>0) {
        selectType=2;
    }
}
-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        [self updatecellSizeWWHH];
        laout.itemSize=CGSizeMake(ww, hh);
        [_collection reloadData];
    }];
}
-(void)showmsg
{
    UILabel *la=[[UILabel alloc]initWithFrame:self.view.bounds];
    la.textAlignment=NSTextAlignmentCenter;
    la.textColor=[UIColor grayColor];
    [self.view addSubview:la];
    la.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    la.font=[UIFont systemFontOfSize:16];
    la.text=@"没有图片";
}
-(PHAsset *)assetWithIndex:(NSInteger )row
{
    return [self.fetchResult objectAtIndex:row];
}
- (void)dealloc
{
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
    [manager stopCachingImagesForAllAssets];
}
- (void)photoLibraryDidChange:(PHChange *)changeInstance
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        PHFetchResultChangeDetails *resultChangeDetails=[changeInstance changeDetailsForFetchResult:self.fetchResult];
        if (resultChangeDetails) {
            self.fetchResult=[resultChangeDetails fetchResultAfterChanges];
            
            if ([resultChangeDetails hasIncrementalChanges]) {
                if (resultChangeDetails.removedIndexes&&resultChangeDetails.removedIndexes.count>0) {
                    NSMutableArray *muarr=[NSMutableArray array];
                    [resultChangeDetails.removedIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
                        [muarr addObject:[NSIndexPath indexPathForRow:idx inSection:0]];
                    }];
                    [_collection deleteItemsAtIndexPaths:muarr];
                }
                if (resultChangeDetails.insertedIndexes&&resultChangeDetails.insertedIndexes.count>0) {
                    NSMutableArray *muarr=[NSMutableArray array];
                    [resultChangeDetails.insertedIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
                        [muarr addObject:[NSIndexPath indexPathForRow:idx inSection:0]];
                    }];
                    [_collection insertItemsAtIndexPaths:muarr];
                }
                if (resultChangeDetails.changedIndexes&&resultChangeDetails.changedIndexes.count>0) {
                    NSMutableArray *muarr=[NSMutableArray array];
                    [resultChangeDetails.changedIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
                        [muarr addObject:[NSIndexPath indexPathForRow:idx inSection:0]];
                    }];
                    [_collection reloadItemsAtIndexPaths:muarr];
                }
                [resultChangeDetails enumerateMovesWithBlock:^(NSUInteger fromIndex, NSUInteger toIndex) {
                    [_collection moveItemAtIndexPath:[NSIndexPath indexPathForRow:fromIndex inSection:0] toIndexPath:[NSIndexPath indexPathForRow:toIndex inSection:0]];
                }];
            }
            else
            {
                [_collection reloadData];
            }
            
        }
    });
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.fetchResult.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PHIMCollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    PHAsset *asset=[self assetWithIndex:indexPath.row];
    
    cell.tagstr=asset.localIdentifier;
    PHImageRequestOptions *option=[[PHImageRequestOptions alloc]init];
    option.deliveryMode=PHImageRequestOptionsDeliveryModeHighQualityFormat;
    option.resizeMode=PHImageRequestOptionsResizeModeFast;
    [manager requestImageForAsset:asset targetSize:CGSizeMake([UIScreen mainScreen].scale*ww, [UIScreen mainScreen].scale*hh) contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        if ([cell.tagstr isEqualToString:asset.localIdentifier]) {
            cell.imageView.image = result;
        }
    }];
    
    BOOL isSelect=NO;
    int i=0;
    for (; i<selectArray.count; i++) {
        NSString *numstr=selectArray[i];
        if (numstr.integerValue==indexPath.row) {
            isSelect=YES;
            break;
        }
    }
    if (!isSelect) {
        i=0;
    }else{
        i++;
    }
    
    if (asset.mediaType==PHAssetMediaTypeVideo) {
        [cell setIsImage:NO MovDuration:asset.duration maxDuration:self.maxDuration SelectType:selectType Num:i];
    }else{
        [cell setIsImage:YES MovDuration:0 maxDuration:self.maxDuration SelectType:selectType Num:i];
    }
    
    return cell;
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self updatamanager];
}

-(void)updatamanager
{
    CGRect visibleRect=CGRectMake(_collection.contentOffset.x, _collection.contentOffset.y, _collection.bounds.size.width, _collection.bounds.size.height);
    CGRect preheatRect=CGRectInset(visibleRect, 0, -0.5 * visibleRect.size.height);
    
    CGFloat delta=ABS(CGRectGetMidY(preheatRect)-CGRectGetMidY(previousPreheatRect));
    if (delta < self.view.bounds.size.height / 3.0) {
        return;
    }
    CGRect addedRects,removedRects;
    if (CGRectGetMidY(preheatRect)>CGRectGetMidY(previousPreheatRect)) {
        addedRects=CGRectMake(preheatRect.origin.x, CGRectGetMaxY(previousPreheatRect), preheatRect.size.width, CGRectGetMaxY(preheatRect)-CGRectGetMaxY(previousPreheatRect));
        removedRects=CGRectMake(preheatRect.origin.x, CGRectGetMinY(previousPreheatRect), preheatRect.size.width, CGRectGetMinY(preheatRect)-CGRectGetMinY(previousPreheatRect));
    }
    else
    {
        addedRects=CGRectMake(preheatRect.origin.x, CGRectGetMinY(preheatRect), preheatRect.size.width, CGRectGetMinY(previousPreheatRect)-CGRectGetMinY(preheatRect));
        removedRects=CGRectMake(preheatRect.origin.x, CGRectGetMaxY(preheatRect), preheatRect.size.width, CGRectGetMaxY(previousPreheatRect)-CGRectGetMaxY(preheatRect));
    }
    NSArray *addedAssets=[self AssetsForElementsin:addedRects];
    NSArray *removedAssets=[self AssetsForElementsin:removedRects];
    
    [manager startCachingImagesForAssets:addedAssets targetSize:CGSizeMake([UIScreen mainScreen].scale*ww, [UIScreen mainScreen].scale*hh) contentMode:PHImageContentModeAspectFill options:nil];
    [manager stopCachingImagesForAssets:removedAssets targetSize:CGSizeMake([UIScreen mainScreen].scale*ww, [UIScreen mainScreen].scale*hh) contentMode:PHImageContentModeAspectFill options:nil];
    
    previousPreheatRect=preheatRect;
}
-(NSArray *)AssetsForElementsin:(CGRect)rect
{
    NSArray *attArr= [_collection.collectionViewLayout layoutAttributesForElementsInRect:rect];
    NSMutableArray *muarr=[NSMutableArray array];
    for (UICollectionViewLayoutAttributes *attr in attArr) {
        [muarr addObject:[self assetWithIndex:attr.indexPath.row]];
    }
    return muarr;
}

#pragma mark 选择
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    PHAsset *asset=[self assetWithIndex:indexPath.row];
    if (selectType>0) {
        if (((asset.mediaType==PHAssetMediaTypeImage)&&selectType==2)||((asset.mediaType==PHAssetMediaTypeVideo)&&selectType==1)) {
            return;
        }
    }
    if ((asset.mediaType==PHAssetMediaTypeVideo)&&self.maxDuration>0&&(asset.duration>self.maxDuration)) {
//        NSString *msg=[NSString stringWithFormat:@"请选择%d秒之内的视频",(int)self.maxDuration];
//        [SVProgressHUD showInfoWithStatus:msg];
        return;
    }
    
    for (int i=0; i<selectArray.count; i++) {
        NSString *numstr=[selectArray objectAtIndex:i];
        if (numstr.integerValue==indexPath.row) {
            [selectArray removeObjectAtIndex:i];
            if (selectArray.count==0) {
                if (self.maxSelectImageNum>0&&self.maxSelectVideoNum>0) {
                    selectType=0;
                }
            }
            [collectionView reloadData];
            [self updataSelectState];
            return;
        }
    }
    
    if (selectArray.count==0) {
        if (self.maxSelectImageNum>0&&self.maxSelectVideoNum>0) {
            PHAsset *asset=[self assetWithIndex:indexPath.row];
            if (asset.mediaType==PHAssetMediaTypeVideo) {
                selectType=2;
            }else{
                selectType=1;
            }
        }
    }
    
    [selectArray addObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
    if (selectArray.count==1) {
        [collectionView reloadData];
    }else{
        [collectionView reloadItemsAtIndexPaths:@[indexPath]];
    }
    [self updataSelectState];
}
-(void)wancheng
{
    if (selectArray.count==0) {
        [self dismissMethod];
    }else{
        iswancheng=YES;
        [self updataSelectState];
    }
}
-(void)updataSelectState
{
    BOOL isfh=NO;
    if (selectArray.count>0) {
        if (selectType==1) {
            if (selectArray.count>=self.maxSelectImageNum||iswancheng) {
                isfh=YES;
            }
        }else if (selectType==2) {
            if (selectArray.count>=self.maxSelectVideoNum||iswancheng) {
                isfh=YES;
            }
        }
    }
    if (isfh) {
        iswancheng=NO;
        loadnum=0;
        if (self.delegate&&[self.delegate respondsToSelector:@selector(selectImageArray:)]) {
            NSMutableArray *muarr=[NSMutableArray array];
            NSMutableArray *movMuarray=[NSMutableArray array];
            NSString *tmpPath=[NSHomeDirectory() stringByAppendingPathComponent:@"tmp/"];
            
            BOOL isRetMov=[self.delegate respondsToSelector:@selector(selectMovPathArray:)];
            
            for (NSString *numstr in selectArray) {
                
                PHAsset *asset=[self assetWithIndex:numstr.integerValue];
                
                if (asset.mediaType==PHAssetMediaTypeVideo) {
                    
                    loadnum++;
                    if (isRetMov) {
                        NSArray *arr=[PHAssetResource assetResourcesForAsset:asset];
                        
                        __block int allarrnum=0;
                        
                        for (int i=0; i<arr.count; i++) {
                            PHAssetResource *res=arr[i];
                            NSLog(@"%@",res.originalFilename);
                            
                            NSString *filepath=[tmpPath stringByAppendingPathComponent:res.originalFilename];
                            [[NSFileManager defaultManager]removeItemAtPath:filepath error:nil];
                            [[PHAssetResourceManager defaultManager] writeDataForAssetResource:res toFile:[NSURL fileURLWithPath:filepath] options:nil completionHandler:^(NSError * _Nullable error) {
                                [movMuarray addObject:filepath];
                                allarrnum++;
                                if (allarrnum==arr.count) {
                                    [self wanchengjiance:muarr movMuarray:movMuarray];
                                }
                            }];
                        }
                    }else{
                        NSLog(@"没有写视频回调代理");
                    }
                }else{
                    
                    CGSize targetSize=CGSizeMake(asset.pixelWidth, asset.pixelHeight);
                    if (targetSize.width>1000||targetSize.height>1000) {
                        CGFloat bili=targetSize.width/targetSize.height;
                        if (bili>1) {
                            targetSize.width=ScreenWidthD*2.0;
                            targetSize.height=roundf(targetSize.width/bili);
                        }else{
                            targetSize.height=ScreenWidthD*2.0;
                            targetSize.width=roundf(targetSize.height*bili);
                        }
                    }
                    
                    PHImageRequestOptions *option=[[PHImageRequestOptions alloc]init];
                    option.deliveryMode=PHImageRequestOptionsDeliveryModeHighQualityFormat;
                    option.resizeMode=PHImageRequestOptionsResizeModeFast;
                    option.networkAccessAllowed=YES;
                    [manager requestImageForAsset:asset targetSize:targetSize contentMode:PHImageContentModeAspectFit options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                        loadnum++;
                        NSLog(@"scale:%.2f,  %.2f, %.2f",result.scale,result.size.width,result.size.height);
                        if (result) {
                            [muarr addObject:result];
                        }
                        [self wanchengjiance:muarr movMuarray:movMuarray];
                    }];
                }
            }
        }
    }
}
-(void)wanchengjiance:(NSArray *)muarr movMuarray:(NSArray *)movMuarray
{
    
    if (selectArray.count==loadnum) {
        
        if (muarr.count>0) {
            [self.delegate selectImageArray:muarr];
        }

        if (movMuarray.count>0) {
            [self.delegate selectMovPathArray:movMuarray];
        }
        
        if ([self.delegate respondsToSelector:@selector(dismissMethodShouldAction:)]) {
            if (![self.delegate dismissMethodShouldAction:self.navigationController]) {
                [self clearAllSelctState];
                return ;
            }
        }
        [self dismissMethod];
    }
}

-(void)clearAllSelctState
{
    [selectArray removeAllObjects];
    isneedReload=YES;
}
-(void)dismissMethod
{
    if(self.navigationController)
    {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (isneedReload){
        isneedReload=NO;
        [_collection reloadData];
    }
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
