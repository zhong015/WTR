//
//  WTRImageListShow.h
//  Created by wfz on 2019/5/29.

#import <UIKit/UIKit.h>

/*
 展示图片列表  支持转屏与大小变化

 listArray:内部是 NSURL 或者 NSString 都可以

 fromView / fromRect  打开动画显示区域源头
 */

NS_ASSUME_NONNULL_BEGIN

@interface WTRImageListShow : UIView

+(instancetype)ShowImageList:(nonnull NSArray *)listArray current:(nonnull id)imageurlOrStr configeOne:(void (^_Nonnull)(UIImageView * _Nonnull imv,id _Nonnull imageurlOrStr)) confige completion:(void (^_Nonnull)(void))completioncb;

+(instancetype)ShowImageList:(nonnull NSArray *)listArray current:(nonnull id)imageurlOrStr fromView:(nullable UIView *)imageView configeOne:(void (^_Nonnull)(UIImageView * _Nonnull imv,id _Nonnull imageurlOrStr)) confige completion:(void (^_Nonnull)(void))completioncb;

+(instancetype)ShowImageList:(nonnull NSArray *)listArray current:(nonnull id)imageurlOrStr fromRect:(CGRect)fromRect configeOne:(void (^_Nonnull)(UIImageView * _Nonnull imv,id _Nonnull imageurlOrStr)) confige completion:(void (^_Nonnull)(void))completioncb;

-(void)clearAllShow;

@end

NS_ASSUME_NONNULL_END
