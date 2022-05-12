//
//  WTRImageListShow.m
//  Created by wfz on 2019/5/29.

#import "WTRImageListShow.h"
#import "WTRBaseDefine.h"
#import "WTRHUD.h"

#define WTRImageListAnimateDuration 0.32 //动画时间
#define WTRImageListJianGe 5.0 //图片间隔

@interface WTRImageListShowCell : UICollectionViewCell <UIScrollViewDelegate>

@property(nonatomic,strong)UIScrollView *scrollView;
@property(nonatomic,strong)UIImageView *imv;

@property(nonatomic,copy) void (^clearallcb)(void);


@property(nonatomic,weak)UIViewController *curintsvc;

@end

@implementation WTRImageListShowCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self loadui];
    }
    return self;
}
-(void)updateAllImframe
{
    self.scrollView.frame=CGRectMake(WTRImageListJianGe/2.0, 0, self.width-WTRImageListJianGe, self.height);
    self.imv.frame=self.scrollView.bounds;
}
-(void)loadui
{
    self.scrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(WTRImageListJianGe/2.0, 0, self.width-WTRImageListJianGe, self.height)];

    [self.contentView addSubview:self.scrollView];

    self.scrollView.delegate=self;
    self.scrollView.contentSize=self.scrollView.bounds.size;
    self.scrollView.minimumZoomScale=1;
    self.scrollView.maximumZoomScale=4.5;

    if (@available(iOS 11.0, *)) {
        self.scrollView.contentInsetAdjustmentBehavior=UIScrollViewContentInsetAdjustmentNever;
    }

    self.imv=[[UIImageView alloc] initWithFrame:self.scrollView.bounds];
    [self.scrollView addSubview:self.imv];
    self.imv.contentMode=UIViewContentModeScaleAspectFit;

    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imshowqunxiao:)];
    tap.numberOfTapsRequired=1;
    [self.imv addGestureRecognizer:tap];
    self.imv.userInteractionEnabled=YES;

    self.imv.backgroundColor=UIColorFromRGB0x(353637);

    UITapGestureRecognizer *tap2=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imshowqunxiao:)];
    tap2.numberOfTapsRequired=2;
    [self.imv addGestureRecognizer:tap2];
    [tap requireGestureRecognizerToFail:tap2];

    //保存
    UILongPressGestureRecognizer *touch = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handlelongt:)];
    [self.imv addGestureRecognizer:touch];
}

- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imv;
}
-(void)imshowqunxiao:(UITapGestureRecognizer *)tap
{
    if (tap.numberOfTapsRequired==2)
    {
        if (self.scrollView.zoomScale==1) {
            [self.scrollView setZoomScale:2 animated:YES];
        }
        else
        {
            [self.scrollView setZoomScale:1 animated:YES];
        }
        return;
    }
    if (self.scrollView.zoomScale!=1) {
        [self.scrollView setZoomScale:1 animated:YES];
        return;
    }
    [self clearAllShow];
}
-(void)clearAllShow
{
    if (self.clearallcb) {
        self.clearallcb();
    }
}

-(void)handlelongt:(UILongPressGestureRecognizer*) recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self saveimageaction];
    }
}
#pragma mark 保存图片
-(void)saveimageaction
{
    if (self.imv.image) {
        [self wtrsaveimage:self.imv.image imageView:self.imv];
    }
}
-(void)wtrsaveimage:(UIImage *)saveimage imageView:(UIImageView *)imv
{
    UIAlertController *actionContr = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    if (TARGET_OS_MACCATALYST) {
        __WEAKSelf
        [actionContr addAction:[UIAlertAction actionWithTitle:@"导出图片" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf performSelector:@selector(daochutupian:) withObject:imv afterDelay:0.1];
        }]];
    }else{
        [actionContr addAction:[UIAlertAction actionWithTitle:@"保存到相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            UIImageWriteToSavedPhotosAlbum(saveimage, self, @selector(image:didFinishSavingWithError:contextInfo:),nil);
        }]];
    }
    [actionContr addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    self.curintsvc=[WTR curintViewController];
    if(ISPadWTR&&imv){
        UIPopoverPresentationController *popPresenter=[actionContr popoverPresentationController];
        popPresenter.sourceView=imv;
        popPresenter.sourceRect=CGRectMake(imv.width/2.0-40, imv.height/2.0-40, 80, 80);
        [self.curintsvc presentViewController:actionContr animated:YES completion:nil];
    }else{
        [self.curintsvc presentViewController:actionContr animated:YES completion:nil];
    }
}
-(void)daochutupian:(UIImageView *)imv
{
    if (!imv.image) {
        return;
    }
    NSString *tmppath=[[WTRFilePath getCachePath] stringByAppendingPathComponent:@"wtrimlist.png"];
    [[NSFileManager defaultManager] removeItemAtPath:tmppath error:nil];
    [UIImagePNGRepresentation(imv.image) writeToFile:tmppath atomically:YES];
    UIDocumentPickerViewController *pic=[[UIDocumentPickerViewController alloc] initWithURL:[NSURL fileURLWithPath:tmppath] inMode:UIDocumentPickerModeMoveToService];
    if (@available(iOS 13.0, *)) {
        pic.shouldShowFileExtensions=YES;
    }
    [[WTR curintViewController] presentViewController:pic animated:YES completion:nil];
}
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error) {
        if (error.code==-3310) {
            UIAlertController *alt=[UIAlertController alertControllerWithTitle:@"请打开写入相册权限" message:nil preferredStyle:UIAlertControllerStyleAlert];
            [alt addAction:[UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                [self openSettingApp];
                self.curintsvc=nil;
            }]];
            [alt addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                self.curintsvc=nil;
            }]];
            [self.curintsvc presentViewController:alt animated:YES completion:nil];
        }
    }else{
        [WTRHUD showSuccessWInView:self.curintsvc.view WithStatus:@"保存成功"];
    }
}
-(void)openSettingApp
{
    if (@available(iOS 10.0, *)) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{UIApplicationOpenURLOptionUniversalLinksOnly:@(NO)} completionHandler:nil];
    }else{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}

@end

@interface WTRImageListShow ()<UICollectionViewDataSource,UICollectionViewDelegate>

@property(nonatomic,copy) void (^confige)(UIImageView * _Nonnull imv,id _Nonnull imageUrlOrStr,UIView * _Nullable contentView,UIScrollView * _Nullable scrollView);
@property(nonatomic,copy) void (^completioncb)(void);

@property(nonatomic,strong)UICollectionView *collection;

@property(nonatomic,strong)UILabel *numla;

@property(nonatomic,strong)UIView *bacview;//黑背景
@property(nonatomic,strong)UIView *crutapv;
@property(nonatomic,strong)UIImageView *crutapvimv;

@property(nonatomic,assign)CGRect yuanlrect;

@end

@implementation WTRImageListShow
{
    UIView *_imageView;
    CGRect _fromRect;
    id _imageurl;
    NSArray *_listArray;

    int currentindex;
    
    CGFloat lastww,lasthh;
}

+(instancetype)showWithListArray:(nonnull NSArray *)listArray current:(nonnull id)imageUrlOrStr configOne:(void (^_Nonnull)(UIImageView * _Nonnull imv,id _Nonnull imageUrlOrStr,UIView * _Nullable contentView,UIScrollView * _Nullable scrollView))configOne completion:(void (^_Nonnull)(void))completioncb
{
    return [self showFromView:nil orRect:CGRectZero listArray:listArray current:imageUrlOrStr configOne:configOne completion:completioncb];
}
+(instancetype)showFromView:(nullable UIView *)fromImageView orRect:(CGRect)fromRect listArray:(nonnull NSArray *)listArray current:(nonnull id)imageUrlOrStr configOne:(void (^_Nonnull)(UIImageView * _Nonnull imv,id _Nonnull imageUrlOrStr,UIView * _Nullable contentView,UIScrollView * _Nullable scrollView))configOne completion:(void (^_Nonnull)(void))completioncb
{
    WTRImageListShow *show=[WTRImageListShow new];
    [show showFromView:fromImageView orRect:fromRect listArray:listArray current:imageUrlOrStr configOne:configOne completion:completioncb];
    return show;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (ABS(self.width-lastww)>2||ABS(self.height-lasthh)>2) {
        [self reloadcolloction];
        self.numla.frame=CGRectMake(20, self.height-60, self.width/2.0, 20);
        if (self.crutapv) {
            [self.crutapv removeFromSuperview];//大小变过就不能有动画了 位置变了
            self.crutapv=nil;
        }
        lastww=self.width;
        lasthh=self.height;
    }
}

-(void)showFromView:(nullable UIView *)fromImageView orRect:(CGRect)fromRect listArray:(nonnull NSArray *)listArray current:(nonnull id)imageUrlOrStr configOne:(void (^_Nonnull)(UIImageView * _Nonnull imv,id _Nonnull imageUrlOrStr,UIView * _Nullable contentView,UIScrollView * _Nullable scrollView))configOne completion:(void (^_Nonnull)(void))completioncb
{
    if (!listArray||listArray.count==0) {
        return;
    }
    _listArray=listArray;
    _imageurl=imageUrlOrStr;
    _imageView=fromImageView;
    _fromRect=fromRect;

    self.confige = configOne;
    self.completioncb = completioncb;

    currentindex=0;
    for (int i=0; i<_listArray.count; i++) {
        NSURL *urls=_listArray[i];
        if ([urls isKindOfClass:[NSURL class]]) {
            NSURL *c_imageurl=_imageurl;
            if ([urls.absoluteString isEqualToString:c_imageurl.absoluteString]) {
                currentindex=i;
                break;
            }
        }else if ([urls isKindOfClass:[NSString class]]){
            NSString *cstr=(NSString *)urls;
            NSString *c_imageurl=_imageurl;
            if ([cstr isEqualToString:c_imageurl]) {
                currentindex=i;
                break;
            }
        }
    }

    UIView *surview=[WTR curintViewController].view;
    self.frame=surview.bounds;
    [surview addSubview:self];
    self.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;

    lastww=self.width;
    lasthh=self.height;
    
    self.bacview=[[UIView alloc] initWithFrame:self.bounds];
    self.bacview.backgroundColor=UIColorFromRGB0x(353637);
    [self addSubview:self.bacview];
    self.bacview.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;

    [self reloadcolloction];

    self.numla=[UILabel new];
    self.numla.font=[UIFont systemFontOfSize:15];
    self.numla.textColor=[UIColor whiteColor];
    [self addSubview:self.numla];
    self.numla.frame=CGRectMake(20, self.height-60, self.width/2.0, 20);
    [self updataenumla];

    //放大动画
    if (_imageView||_fromRect.size.width>0.1) {
        if (_imageView) {
            self.yuanlrect=[self convertRect:_imageView.bounds fromView:_imageView];
        }else{
            self.yuanlrect=_fromRect;
        }
        self.crutapv=[[UIView alloc] initWithFrame:self.yuanlrect];
        self.crutapvimv=[[UIImageView alloc]initWithFrame:self.crutapv.bounds];
        [self.crutapv addSubview:self.crutapvimv];
        self.crutapvimv.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.crutapv.layer.masksToBounds=YES;

        if (configOne) {
            configOne(self.crutapvimv,imageUrlOrStr,nil,nil);
        }

        if (self.crutapvimv.image) {
            [self insertSubview:self.crutapv belowSubview:self.collection];

            CGSize imsize=self.crutapvimv.image.size;

            CGFloat faw=0,fah=0;
            if (imsize.width/imsize.height>ScreenWidth/ScreenHeight) {
                faw=ScreenWidth;
                fah=ScreenWidth/(imsize.width/imsize.height);
            }
            else
            {
                fah=ScreenHeight;
                faw=ScreenHeight*(imsize.width/imsize.height);
            }

            if (_imageView) {
                self.crutapvimv.contentMode=_imageView.contentMode;
                if (self.crutapvimv.contentMode==UIViewContentModeScaleAspectFit) {
                    faw=ScreenWidth;
                    fah=ScreenHeight;
                }
            }
            self.bacview.alpha=0;
            self.collection.hidden=YES;
            [UIView animateWithDuration:WTRImageListAnimateDuration animations:^{
                self.crutapv.frame=CGRectMake((ScreenWidth-faw)/2,(ScreenHeight-fah)/2, faw, fah);
                self.bacview.alpha=1;
            }completion:^(BOOL finished) {
                self.crutapv.hidden=YES;
                self.collection.hidden=NO;
            }];
            return;
        }
    }
    self.alpha=0;
    [UIView animateWithDuration:WTRImageListAnimateDuration animations:^{
        self.alpha=1;
    }];
}
-(void)reloadcolloction
{
    if (self.collection) {
        UICollectionView *lastcolloction=self.collection;
        [UIView animateWithDuration:WTRImageListAnimateDuration animations:^{
            lastcolloction.alpha=0;
        }completion:^(BOOL finished) {
            [lastcolloction removeFromSuperview];
        }];
    }
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection=UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(ScreenWidth+WTRImageListJianGe, ScreenHeight);

    layout.minimumLineSpacing=0;
    layout.minimumInteritemSpacing=0;

    layout.estimatedItemSize=CGSizeZero;
    
    self.collection = [[UICollectionView alloc] initWithFrame:CGRectMake(-WTRImageListJianGe/2.0, 0, self.bounds.size.width+WTRImageListJianGe, self.bounds.size.height) collectionViewLayout:layout];
    self.collection.dataSource=self;
    self.collection.delegate=self;
    [self.collection registerClass:[WTRImageListShowCell class] forCellWithReuseIdentifier:@"cell"];

    self.collection.pagingEnabled=YES;

    [self insertSubview:self.collection aboveSubview:self.bacview];

    self.collection.backgroundColor=[UIColor clearColor];

    [self.collection scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:currentindex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
}
-(void)updataenumla
{
    if (_listArray.count>1) {
        self.numla.text=[NSString stringWithFormat:@"%d / %d",currentindex+1,(int)_listArray.count];
    }else{
        self.numla.hidden=YES;
    }
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int index=roundf(scrollView.contentOffset.x/scrollView.width);
    currentindex=index;
    [self updataenumla];
}
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    int index=roundf(scrollView.contentOffset.x/scrollView.width);
    currentindex=index;
    [self updataenumla];
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _listArray.count;
}
// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    WTRImageListShowCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];

    if (self.confige) {
        self.confige(cell.imv,_listArray[indexPath.row],cell.contentView,cell.scrollView);
    }

    if (!cell.clearallcb) {
        __WEAKSelf
        cell.clearallcb = ^{
            [weakSelf clearAllShow];
        };
    }
    
    [cell.scrollView setZoomScale:1 animated:NO];
    [cell updateAllImframe];
    
    return cell;
}
-(void)clearAllShow
{
    if (self.crutapv&&self.crutapv.superview) {
        self.collection.hidden=YES;
        self.crutapv.hidden=NO;

        //图片是显示后加载出来的 那么大小会变化 重新设置crutapv位置
        CGSize imsize=self.crutapvimv.image.size;
        CGFloat faw=0,fah=0;
        if (imsize.width/imsize.height>ScreenWidth/ScreenHeight) {
            faw=ScreenWidth;
            fah=ScreenWidth/(imsize.width/imsize.height);
        }
        else
        {
            fah=ScreenHeight;
            faw=ScreenHeight*(imsize.width/imsize.height);
        }
        if (_imageView) {
            if (self.crutapvimv.contentMode==UIViewContentModeScaleAspectFit) {
                faw=ScreenWidth;
                fah=ScreenHeight;
            }
        }
        self.crutapv.frame=CGRectMake((ScreenWidth-faw)/2,(ScreenHeight-fah)/2, faw, fah);

        [UIView animateWithDuration:WTRImageListAnimateDuration animations:^{
            self.crutapv.frame=self.yuanlrect;
            self.bacview.alpha=0;
        }completion:^(BOOL finished) {
            [self removeFromSuperview];
            if (self.completioncb) {
                self.completioncb();
            }
        }];
    }else{
        [UIView animateWithDuration:WTRImageListAnimateDuration animations:^{
            self.alpha=0;
        }completion:^(BOOL finished) {
            [self removeFromSuperview];
            if (self.completioncb) {
                self.completioncb();
            }
        }];
    }
}

@end
