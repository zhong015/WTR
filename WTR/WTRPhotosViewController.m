//
//  WTRPhotosViewController.m
//  asd
//
//  Created by wfz on 2017/3/11.
//  Copyright © 2017年 wfz. All rights reserved.
//

#import "WTRPhotosViewController.h"
#import "WTRPhotosAssetViewController.h"
#import "WTRBaseDefine.h"
#import "WTRSTBarNavViewController.h"

@interface WTRPhotosViewController ()<UITableViewDelegate,UITableViewDataSource,PHPhotoLibraryChangeObserver>

@property(nonatomic,assign)id <WTRPhotosViewControllerDelegate> delegate;
@property(nonatomic,assign)NSInteger maxSelectNum;

@property(nonatomic,assign)CGSize targetSize;
@property(nonatomic,assign)PHImageContentMode contentMode;

@property(nonatomic,strong) UIColor *barTintColor;
@property(nonatomic,strong) UIColor *tintColor;
@property(nonatomic,assign) BOOL StatusBarIsBlack;//状态栏文字是否是黑色 默认NO (修改的时候 推荐 写在界面init方法里,可以提前改变状态)

@end

@implementation WTRPhotosViewController
{
    UITableView *_tableview;
    PHFetchResult *allPhotos,*smartAlbums,*userCollections;
}
+(void)showWTRPhotosViewControllerWithDelegate:(id <WTRPhotosViewControllerDelegate> )delegate
{
    [self showWTRPhotosViewControllerWithDelegate:delegate MaxSelectNum:1];
}
+(void)showWTRPhotosViewControllerWithDelegate:(id <WTRPhotosViewControllerDelegate> )delegate MaxSelectNum:(NSInteger)maxnum
{
    [self showWTRPhotosViewControllerWithDelegate:delegate MaxSelectNum:maxnum targetSize:CGSizeMake(200, 200) contentMode:PHImageContentModeAspectFill barTintColor:nil tintColor:nil statusBarIsBlack:YES];
}
+(void)showWTRPhotosViewControllerWithDelegate:(id <WTRPhotosViewControllerDelegate> )delegate MaxSelectNum:(NSInteger)maxnum barTintColor:(UIColor *)barTintColor tintColor:(UIColor *)tintColor statusBarIsBlack:(BOOL)statusBarIsBlack
{
    [self showWTRPhotosViewControllerWithDelegate:delegate MaxSelectNum:maxnum targetSize:CGSizeMake(200, 200) contentMode:PHImageContentModeAspectFill barTintColor:barTintColor tintColor:tintColor statusBarIsBlack:statusBarIsBlack];
}
+(void)showWTRPhotosViewControllerWithDelegate:(id <WTRPhotosViewControllerDelegate> )delegate MaxSelectNum:(NSInteger)maxnum targetSize:(CGSize)targetSize contentMode:(PHImageContentMode)contentMode barTintColor:(UIColor *)barTintColor tintColor:(UIColor *)tintColor statusBarIsBlack:(BOOL)statusBarIsBlack
{
    WTRPhotosViewController *photosvc=[[WTRPhotosViewController alloc] init];
    photosvc.StatusBarIsBlack=statusBarIsBlack;
    photosvc.delegate=delegate;
    photosvc.maxSelectNum=maxnum;
    photosvc.targetSize=targetSize;
    photosvc.contentMode=contentMode;
    photosvc.barTintColor=barTintColor;
    photosvc.tintColor=tintColor;
    
    WTRSTBarNavViewController *nav=[[WTRSTBarNavViewController alloc] initWithRootViewController:photosvc];
    nav.navigationBar.barTintColor=barTintColor;
    nav.navigationBar.tintColor=tintColor;
    nav.StatusBarIsBlack=statusBarIsBlack;
    [[WTR curintViewController] presentViewController:nav animated:YES completion:nil];
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

-(void)backMethod
{
    if (self.navigationController&&(self.navigationController.viewControllers.count>1)) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if(self.navigationController)
    {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];

    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(backMethod)];
    
#if IsShowAddAlbumBu
    self.navigationItem.rightBarButtonItem =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addAlbum)];
#endif
    
    PHFetchOptions *allPhotosOptions=[[PHFetchOptions alloc] init];
    allPhotosOptions.sortDescriptors=@[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
//    allPhotos=[PHAsset fetchAssetsWithOptions:allPhotosOptions];//包活视频
    allPhotos=[PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:allPhotosOptions]; //不包括视频

    smartAlbums=[PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    userCollections=[PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    
    _tableview=[[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableview.delegate=self;
    _tableview.dataSource=self;
    [self.view addSubview:_tableview];
    _tableview.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [_tableview registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    _tableview.contentInset=UIEdgeInsetsMake(0, 0, 10, 0);
    
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
}

-(void)dealloc
{
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}
- (void)photoLibraryDidChange:(PHChange *)changeInstance
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        BOOL isc=NO;
        PHFetchResultChangeDetails *resultChangeDetails=[changeInstance changeDetailsForFetchResult:allPhotos];
        if (resultChangeDetails) {
            allPhotos=[resultChangeDetails fetchResultAfterChanges];
            isc=YES;
        }
        resultChangeDetails=[changeInstance changeDetailsForFetchResult:smartAlbums];
        if (resultChangeDetails) {
            smartAlbums=[resultChangeDetails fetchResultAfterChanges];
            isc=YES;
        }
        resultChangeDetails=[changeInstance changeDetailsForFetchResult:userCollections];
        if (resultChangeDetails) {
            userCollections=[resultChangeDetails fetchResultAfterChanges];
            isc=YES;
        }
        if (isc) {
            [_tableview reloadData];
        }
    });
}
-(void)addAlbum
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"新建相册集" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder=@"请输入相册集名字";
    }];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"创建" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *textField=alert.textFields.firstObject;
        NSString *title=textField.text;
        if (title&&title.length>0) {
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:title];
            } completionHandler:^(BOOL success, NSError * _Nullable error) {
            }];
        }
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1+userCollections.count+smartAlbums.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    
    if (indexPath.row==0) {
#if ShowLivePhotoOnly
        cell.textLabel.text=@"全部Live图片";
#else
        cell.textLabel.text=@"全部图片";
#endif
    }else if (indexPath.row>0&&indexPath.row<userCollections.count+1){
        PHCollection *collection=[userCollections objectAtIndex:indexPath.row-1];
        cell.textLabel.text = collection.localizedTitle;
    }else if(indexPath.row>userCollections.count&&indexPath.row<1+userCollections.count+smartAlbums.count){
        PHCollection *collection=[smartAlbums objectAtIndex:indexPath.row-1-userCollections.count];
        cell.textLabel.text = collection.localizedTitle;
    }
    else
        cell.textLabel.text=@"show error";

    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WTRPhotosAssetViewController *assetvc=[[WTRPhotosAssetViewController alloc] init];
    assetvc.StatusBarIsBlack=self.StatusBarIsBlack;
    
    PHAssetCollection *collection=nil;
    
    if (indexPath.row==0) {
        assetvc.fetchResult=allPhotos;
    }else if (indexPath.row>0&&indexPath.row<userCollections.count+1){
        collection=[userCollections objectAtIndex:indexPath.row-1];
    }else if(indexPath.row>userCollections.count&&indexPath.row<1+userCollections.count+smartAlbums.count){
        collection=[smartAlbums objectAtIndex:indexPath.row-1-userCollections.count];
    }
    
    if (collection&&[collection isKindOfClass:[PHAssetCollection class]]) {
        assetvc.fetchResult=[PHAsset fetchAssetsInAssetCollection:collection options:nil];
    }
    assetvc.delegate=self.delegate;
    assetvc.targetSize=self.targetSize;
    assetvc.maxSelectNum=self.maxSelectNum;
    assetvc.contentMode=self.contentMode;
    [self.navigationController pushViewController:assetvc animated:YES];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self checkAuthorization];
}
-(void)checkAuthorization
{
    PHAuthorizationStatus  status = [PHPhotoLibrary authorizationStatus];
    /*
     PHAuthorizationStatusNotDetermined   用户还没有关于这个应用程序做出了选择
     PHAuthorizationStatusRestricted      这个应用程序未被授权访问图片数据 , 用户不能更改该应用程序的状态,可能由于活跃的限制
     PHAuthorizationStatusDenied          用户已经明确否认了这个应用程序访问图片数据。
     PHAuthorizationStatusAuthorized      用户授权此应用程序访问图片数据
     */
    if (status == PHAuthorizationStatusDenied)
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"请打开相册授权" message:@"设置->隐私->照片->本应用" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [self backMethod];
        }];
        [alert addAction:cancel];
        UIAlertAction *skip = [UIAlertAction actionWithTitle:@"设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self performSelector:@selector(openSettingApp) withObject:nil afterDelay:0.1];
        }];
        [alert addAction:skip];
        [self presentViewController:alert animated:YES completion:nil];
    }
}
-(void)openSettingApp
{
//    if (ISIOS10) {
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{UIApplicationOpenURLOptionUniversalLinksOnly:[NSNumber numberWithBool:YES]} completionHandler:nil];
//    }
//    else
//    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
//    }
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
