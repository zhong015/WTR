//
//  PHIMCollectionViewCell.h
//  asd
//
//  Created by wfz on 2017/3/11.
//  Copyright © 2017年 wfz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PHIMCollectionViewCell : UICollectionViewCell

@property(nonatomic,strong)UIImageView *imageView;
@property(nonatomic,copy)NSString *tagstr;


-(void)setIsImage:(BOOL)isImage MovDuration:(NSTimeInterval)duration maxDuration:(NSInteger)maxDuration SelectType:(int)SelectType Num:(NSInteger)num;

@end
