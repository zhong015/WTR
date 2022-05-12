//
//  WTRImageListShow.h
//  Created by wfz on 2019/5/29.

#import <UIKit/UIKit.h>

/*
 展示图片列表  支持转屏与大小变化

 listArray:内部是 NSURL 或者 NSString 都可以
 configOne: 是配置怎么加载图片的回调，需要给imv配置上imageUrlOrStr对应的图片

 可选使用
 contentView : cell.contentView 用于自定义显示信息添加 动画中配置时为null
 scrollView : 当前放大功能的scroll 用于自定义配置放大功能 动画中配置时为null

 */

NS_ASSUME_NONNULL_BEGIN

@interface WTRImageListShow : UIView

//不带放大动画
+(instancetype)showWithListArray:(nonnull NSArray *)listArray current:(nonnull id)imageUrlOrStr configOne:(void (^_Nonnull)(UIImageView * _Nonnull imv,id _Nonnull imageUrlOrStr,UIView * _Nullable contentView,UIScrollView * _Nullable scrollView))configOne completion:(void (^_Nonnull)(void))completioncb;

//带放大动画的 需要fromImageView 或者 fromRect
+(instancetype)showFromView:(nullable UIView *)fromImageView orRect:(CGRect)fromRect listArray:(nonnull NSArray *)listArray current:(nonnull id)imageUrlOrStr configOne:(void (^_Nonnull)(UIImageView * _Nonnull imv,id _Nonnull imageUrlOrStr,UIView * _Nullable contentView,UIScrollView * _Nullable scrollView))configOne completion:(void (^_Nonnull)(void))completioncb;

-(void)clearAllShow;

@end

NS_ASSUME_NONNULL_END
