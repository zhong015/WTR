//
//  WTRPhotosAssetViewController.m
//  asd
//
//  Created by wfz on 2017/3/11.
//  Copyright © 2017年 wfz. All rights reserved.
//

#import "WTRPhotosAssetViewController.h"
#import "PHIMCollectionViewCell.h"
#import "WTRPhotosShowViewController.h"

@interface WTRPhotosAssetViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,PHPhotoLibraryChangeObserver>

@end

@implementation WTRPhotosAssetViewController
{
    UICollectionView *_collection;
    PHCachingImageManager *manager;
    CGRect previousPreheatRect;
    
    NSInteger loadnum;
    NSMutableArray *selectArray;
    
    NSMutableArray *_dataArray;
    BOOL isneedReload;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    
    if (self.maxSelectNum<=0) {
        self.maxSelectNum=1;
    }
    if (self.targetSize.width<=0.1||self.targetSize.height<0.1) {
        self.targetSize=CGSizeMake(200, 200);
        self.contentMode=PHImageContentModeAspectFill;
    }
    
    selectArray=[NSMutableArray array];
    
    manager=[[PHCachingImageManager alloc] init];
    
    if (!self.fetchResult) {
        PHFetchOptions *allPhotosOptions=[[PHFetchOptions alloc] init];
        allPhotosOptions.sortDescriptors=@[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
        self.fetchResult=[PHAsset fetchAssetsWithOptions:allPhotosOptions];
    }
#if ShowLivePhotoOnly
    [self ShowLivePhotoOnlyAction];
    if (_dataArray.count==0) {
        [self showmsg];
        return;
    }
#else
    if (self.fetchResult.count==0) {
        [self showmsg];
        return;
    }
#endif
    
    UICollectionViewFlowLayout *laout=[[UICollectionViewFlowLayout alloc] init];
    laout.itemSize=CGSizeMake(WTRPhotoImageWidth, WTRPhotoImageHeight);
    
    _collection=[[UICollectionView alloc]initWithFrame:self.view.bounds collectionViewLayout:laout];
    _collection.delegate=self;
    _collection.dataSource=self;
    [self.view addSubview:_collection];
    _collection.contentInset=UIEdgeInsetsMake(10, 10, 10, 10);
    _collection.alwaysBounceVertical=YES;
    
    [_collection registerClass:[PHIMCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    _collection.backgroundColor=[UIColor whiteColor];
    _collection.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
  
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
}
-(void)showmsg
{
    UILabel *la=[[UILabel alloc]initWithFrame:self.view.bounds];
    la.textAlignment=NSTextAlignmentCenter;
    la.textColor=[UIColor grayColor];
    [self.view addSubview:la];
    la.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    la.font=[UIFont systemFontOfSize:16];
#if ShowLivePhotoOnly
    la.text=@"没有Live图片";
#else
    la.text=@"没有图片";
#endif

}
-(void)ShowLivePhotoOnlyAction
{
    _dataArray=[NSMutableArray array];
    [self.fetchResult enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL * _Nonnull stop) {
        if (asset.mediaSubtypes==PHAssetMediaSubtypePhotoLive) {
            [_dataArray addObject:asset];
        }
    }];
}
-(PHAsset *)assetWithIndex:(NSInteger )row
{
    if (ShowLivePhotoOnly) {
        return [_dataArray objectAtIndex:row];
    }
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
            
#if ShowLivePhotoOnly
            [self ShowLivePhotoOnlyAction];
            [_collection reloadData];
#else
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
#endif
            
        }
    });
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (ShowLivePhotoOnly) {
        return _dataArray.count;
    }
    return self.fetchResult.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PHIMCollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    PHAsset *asset=[self assetWithIndex:indexPath.row];
    
#if ISYShowLivePhoto
    if ([UIDevice currentDevice].systemVersion.floatValue>=9.1&&asset.mediaSubtypes&PHAssetMediaSubtypePhotoLive) {
       cell.livePhotoBadgeImageView.image=[PHLivePhotoView livePhotoBadgeImageWithOptions:PHLivePhotoBadgeOptionsOverContent];
        if (!cell.livePhotoBadgeImageView.gestureRecognizers||cell.livePhotoBadgeImageView.gestureRecognizers.count==0) {
            UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(livePhotoClick:)];
            [cell.livePhotoBadgeImageView addGestureRecognizer:tap];
            cell.livePhotoBadgeImageView.userInteractionEnabled=YES;
        }
        cell.livePhotoBadgeImageView.tag=indexPath.row;
    }
#endif
    
    cell.tagstr=asset.localIdentifier;
    PHImageRequestOptions *option=[[PHImageRequestOptions alloc]init];
    option.deliveryMode=PHImageRequestOptionsDeliveryModeHighQualityFormat;
    option.resizeMode=PHImageRequestOptionsResizeModeFast;
    [manager requestImageForAsset:asset targetSize:CGSizeMake([UIScreen mainScreen].scale*WTRPhotoImageWidth, [UIScreen mainScreen].scale*WTRPhotoImageHeight) contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        if ([cell.tagstr isEqualToString:asset.localIdentifier]) {
            cell.imageView.image = result;
        }
    }];
    
    for (NSString *numstr in selectArray) {
        if (numstr.integerValue==indexPath.row) {
            cell.isSelectImage=YES;
            break;
        }
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
    
    [manager startCachingImagesForAssets:addedAssets targetSize:CGSizeMake([UIScreen mainScreen].scale*WTRPhotoImageWidth, [UIScreen mainScreen].scale*WTRPhotoImageHeight) contentMode:PHImageContentModeAspectFill options:nil];
    [manager stopCachingImagesForAssets:removedAssets targetSize:CGSizeMake([UIScreen mainScreen].scale*WTRPhotoImageWidth, [UIScreen mainScreen].scale*WTRPhotoImageHeight) contentMode:PHImageContentModeAspectFill options:nil];
    
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
    for (int i=0; i<selectArray.count; i++) {
        NSString *numstr=[selectArray objectAtIndex:i];
        if (numstr.integerValue==indexPath.row) {
            [selectArray removeObjectAtIndex:i];
            [collectionView reloadItemsAtIndexPaths:@[indexPath]];
            [self updataSelectState];
            return;
        }
    }
    [selectArray addObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
    [collectionView reloadItemsAtIndexPaths:@[indexPath]];
    [self updataSelectState];
}
-(void)updataSelectState
{
    if (selectArray.count>=self.maxSelectNum) {
         loadnum=0;
        if (self.delegate&&[self.delegate respondsToSelector:@selector(selectWTRImageArray:)]) {
            
            BOOL isRetLivePhoto=[self.delegate respondsToSelector:@selector(selectWTRLivePhotoJPGAndMovPathArray:)];
            
            NSMutableArray *muarr=[NSMutableArray array];
            NSMutableArray *muarrJpgMov=[NSMutableArray array];
            NSString *tmpPath=[NSHomeDirectory() stringByAppendingPathComponent:@"tmp/"];
            
            for (NSString *numstr in selectArray) {
                
                PHAsset *asset=[self assetWithIndex:numstr.integerValue];
                
                if (isRetLivePhoto&&[UIDevice currentDevice].systemVersion.floatValue>=9.1&&asset.mediaSubtypes&PHAssetMediaSubtypePhotoLive) {
                    loadnum++;
                    NSArray *arr=[PHAssetResource assetResourcesForAsset:asset];
                    for (PHAssetResource *res in arr) {
                        NSLog(@"%@",res.originalFilename);
                        
                        NSString *filepath=[tmpPath stringByAppendingPathComponent:res.originalFilename];
                        
                        [[PHAssetResourceManager defaultManager] writeDataForAssetResource:res toFile:[NSURL fileURLWithPath:filepath] options:nil completionHandler:^(NSError * _Nullable error) {
                            [muarrJpgMov addObject:filepath];
                        }];
                    }
                    
                    if (selectArray.count==loadnum) {
                        [self.delegate selectWTRImageArray:muarr];
                        if (isRetLivePhoto) {
                            [self.delegate selectWTRLivePhotoJPGAndMovPathArray:muarrJpgMov];
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
                else
                {
                    CGSize targetSize=CGSizeMake([UIScreen mainScreen].scale*self.targetSize.width, [UIScreen mainScreen].scale*self.targetSize.height);
                    
                    PHImageRequestOptions *option=[[PHImageRequestOptions alloc]init];
                    option.deliveryMode=PHImageRequestOptionsDeliveryModeHighQualityFormat;
                    option.resizeMode=PHImageRequestOptionsResizeModeFast;
                    option.networkAccessAllowed=YES;
                    [manager requestImageForAsset:asset targetSize:targetSize contentMode:self.contentMode options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                        loadnum++;
                        NSLog(@"scale:%.2f,  %.2f, %.2f",result.scale,result.size.width,result.size.height);
                        if (result) {
                            [muarr addObject:result];
                        }
                        if (selectArray.count==loadnum) {
                            [self.delegate selectWTRImageArray:muarr];
                            if (isRetLivePhoto) {
                                [self.delegate selectWTRLivePhotoJPGAndMovPathArray:muarrJpgMov];
                            }
                            if ([self.delegate respondsToSelector:@selector(dismissMethodShouldAction:)]) {
                                if (![self.delegate dismissMethodShouldAction:self.navigationController]) {
                                    [self clearAllSelctState];
                                    return ;
                                }
                            }
                            [self dismissMethod];
                        }
                    }];
                }

            }
        }
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
#pragma mark 查看
-(void)livePhotoClick:(UITapGestureRecognizer *)tap
{
    PHAsset *asset=[self assetWithIndex:tap.view.tag];
    
    WTRPhotosShowViewController *showvc=[[WTRPhotosShowViewController alloc]init];
    showvc.asset=asset;
    [self.navigationController pushViewController:showvc animated:YES];
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
