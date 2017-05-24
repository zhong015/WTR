//
//  PHIMCollectionViewCell.h
//  asd
//
//  Created by wfz on 2017/3/11.
//  Copyright © 2017年 wfz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PHIMCollectionViewCell : UICollectionViewCell

@property(nonatomic,strong)UIImageView *imageView,*livePhotoBadgeImageView;
@property(nonatomic,copy)NSString *tagstr;

@property(nonatomic,assign)BOOL isSelectImage;

@end
