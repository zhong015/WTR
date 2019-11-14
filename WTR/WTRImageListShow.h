//
//  WTRImageListShow.h
//  CnkiIPhoneClient
//
//  Created by wfz on 2019/5/29.
//  Copyright © 2019 net.cnki.www. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 展示图片列表  暂不支持转屏


 */
@interface WTRImageListShow : UIView

+(void)ShowImageList:(nonnull NSArray *)listArray current:(nonnull id)imageurlOrStr configeOne:(void (^_Nonnull)(UIImageView * _Nonnull imv,id _Nonnull imageurlOrStr)) confige completion:(void (^_Nonnull)(void))completioncb;

+(void)ShowImageList:(nonnull NSArray *)listArray current:(nonnull id)imageurlOrStr fromView:(nullable UIView *)imageView configeOne:(void (^_Nonnull)(UIImageView * _Nonnull imv,id _Nonnull imageurlOrStr)) confige completion:(void (^_Nonnull)(void))completioncb;

+(void)ShowImageList:(nonnull NSArray *)listArray current:(nonnull id)imageurlOrStr Rect:(CGRect)fromRect configeOne:(void (^_Nonnull)(UIImageView * _Nonnull imv,id _Nonnull imageurlOrStr)) confige completion:(void (^_Nonnull)(void))completioncb;


//自定义创建使用
-(void)ShowImageList:(nonnull NSArray *)listArray current:(nonnull id)imageurlOrStr fromView:(nullable UIView *)imageView OrRect:(CGRect)fromRect configeOne:(void (^_Nonnull)(UIImageView * _Nonnull imv,id _Nonnull imageurlOrStr)) confige completion:(void (^_Nonnull)(void))completioncb;


@end
