//
//  PHIMCollectionViewCell.m
//  asd
//
//  Created by wfz on 2017/3/11.
//  Copyright © 2017年 wfz. All rights reserved.
//

#import "PHIMCollectionViewCell.h"
#import "WTRPhotosViewController.h"

@implementation PHIMCollectionViewCell


-(id)initWithFrame:(CGRect)frame
{
    self=[super initWithFrame:frame];
    if (self) {
        self.imageView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, WTRPhotoImageWidth, WTRPhotoImageHeight)];
        [self addSubview:self.imageView];
        self.imageView.contentMode=UIViewContentModeScaleAspectFill;
        
        self.imageView.layer.masksToBounds=YES;
        
        self.livePhotoBadgeImageView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 28, 28)];
        [self addSubview:self.livePhotoBadgeImageView];

    }
    return self;
}
-(void)setIsSelectImage:(BOOL)isSelectImage
{
    _isSelectImage=isSelectImage;
    if (_isSelectImage) {
        self.layer.borderWidth=2;
        self.layer.borderColor=[UIColor redColor].CGColor;
        self.layer.masksToBounds=YES;
    }
    else
    {
        self.layer.borderWidth=0;
    }
}

-(void)prepareForReuse
{
    [super prepareForReuse];
    self.isSelectImage=NO;
    self.imageView.image = nil;
    self.livePhotoBadgeImageView.image = nil;
}



@end
