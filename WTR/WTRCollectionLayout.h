//
//  WTRCollectionLayout.h
//  asda
//
//  Created by wfz on 16/5/12.
//  Copyright © 2016年 wfz. All rights reserved.
//

// 拖拽分组  排序

#import <UIKit/UIKit.h>

@interface WTRCellFakeView :UIView

@property (nonatomic, strong)UIImageView *cellFakeImageView;
@property (nonatomic, strong)NSIndexPath *indexPath;

@property (nonatomic, weak)UICollectionViewCell *cell;

@end

@protocol WTRCollectionLayoutDelegate <NSObject>

@optional

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath; //是否可以移动某个 默认yes
- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemToIndexPath:(NSIndexPath *)destinationIndexPath;//是否可以移动到某个 默认yes
- (void)collectionView:(UICollectionView *)collectionView didmoveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath*)destinationIndexPath; //移动了某个


- (BOOL)collectionView:(UICollectionView *)collectionView canCombineItemFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath;  //是否可以合成 默认no
- (void)collectionView:(UICollectionView *)collectionView didCombineToIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath; //已经合成了

- (void)collectionView:(UICollectionView *)collectionView willEditingAtIndexPath:(NSIndexPath *)indexPath; //将要开始编辑

@end


@interface WTRCollectionLayout : UICollectionViewFlowLayout 

@property(nonatomic,weak)id<WTRCollectionLayoutDelegate> delegate;

@property(nonatomic,assign)BOOL isCanLongPressBigin; //是否可以长按开始移动 默认yes
@property(nonatomic,assign)BOOL isCanPanMoveBigin;  //是否可以直接移动开始 默认no


//配置 一般不用动
@property(nonatomic,assign)CGFloat ChaRuBili; //插入组合界限 默认0.9
@property(nonatomic,assign)CGFloat HuDongD; //滑动间隔 当移动的cell靠近上下边缘时 滑动Collection的界限 默认10

@property(nonatomic,assign)CGFloat totalSpeedLJ;//检测速度临界点 默认100

@end
