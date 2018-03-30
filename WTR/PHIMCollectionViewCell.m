//
//  PHIMCollectionViewCell.m
//  asd
//
//  Created by wfz on 2017/3/11.
//  Copyright © 2017年 wfz. All rights reserved.
//

#import "PHIMCollectionViewCell.h"
#import "WTRPhotosViewController.h"
#import "WTRBaseDefine.h"

@implementation PHIMCollectionViewCell
{
    UILabel *la;
    UIImageView *videoimv;
    
    UIView *coverView;
    
    UIImageView *numBacimv;
    UILabel *numla;
}

-(id)initWithFrame:(CGRect)frame
{
    self=[super initWithFrame:frame];
    if (self) {
        self.imageView=[[UIImageView alloc]initWithFrame:self.bounds];
        [self addSubview:self.imageView];
        self.imageView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.imageView.contentMode=UIViewContentModeScaleAspectFill;
        
        self.imageView.layer.masksToBounds=YES;
        
        numBacimv=[[UIImageView alloc] initWithFrame:CGRectMake(self.width-24, 1, 23, 23)];
        [self addSubview:numBacimv];
        numBacimv.autoresizingMask=UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin;
        numla=[UILabel new];
        [self addSubview:numla];
        numla.frame=numBacimv.frame;
        numla.autoresizingMask=UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin;
        numla.font=[UIFont systemFontOfSize:12];
        numla.textAlignment=NSTextAlignmentCenter;
        numla.textColor=[UIColor whiteColor];
        
        
        la=[UILabel new];
        la.font=[UIFont systemFontOfSize:10];
        la.textColor=[UIColor whiteColor];
        la.textAlignment=NSTextAlignmentRight;
        [self addSubview:la];
        
        videoimv=[[UIImageView alloc] initWithImage:[self ImageForImageName:@"WTRPhotosVideo"]];
        [self addSubview:videoimv];
        
        coverView=[[UIView alloc] initWithFrame:self.bounds];
        coverView.backgroundColor=[UIColor colorWithWhite:1 alpha:0.7];
        [self addSubview:coverView];
        coverView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    }
    return self;
}
-(void)setIsImage:(BOOL)isImage MovDuration:(NSTimeInterval)duration maxDuration:(NSInteger)maxDuration SelectType:(int)SelectType Num:(NSInteger)num
{
    coverView.hidden=YES;
    if (SelectType>0) {
        if ((isImage&&SelectType==2)||(!isImage&&SelectType==1)) {
            coverView.hidden=NO;
        }
    }
    if (!isImage&&maxDuration>0&&(duration>maxDuration)) {
        coverView.hidden=NO;
    }
    
    numBacimv.hidden=NO;
    if (num>0) {
        numBacimv.image=[self ImageForImageName:@"WTRPhotosSelect2"];
        numla.text=[NSString stringWithFormat:@"%d",(int)num];
        numla.hidden=NO;
    }else{
        numBacimv.image=[self ImageForImageName:@"WTRPhotosSelect1"];
        numla.hidden=YES;
    }
    
    if (!isImage) {
        la.hidden=NO;
        videoimv.hidden=NO;
        int zms=duration;
        int f=zms/60;
        int m=zms%60;
        
        la.text=[NSString stringWithFormat:@"%02d:%02d",f,m];
        [la sizeToFit];
        la.frame=CGRectMake(self.frame.size.width-7-la.frame.size.width, self.frame.size.height-5-la.frame.size.height, la.frame.size.width, la.frame.size.height);
        videoimv.x=la.x-videoimv.width-4;
        videoimv.y=la.y+3;
        
    }else{
        la.hidden=YES;
        videoimv.hidden=YES;
    }
}

-(void)prepareForReuse
{
    [super prepareForReuse];
    self.imageView.image = nil;
    la.hidden=YES;
    videoimv.hidden=YES;
    coverView.hidden=YES;
    numla.hidden=YES;
    numBacimv.hidden=YES;
}

-(UIImage *)ImageForImageName:(NSString *)imName
{
    NSBundle *bundle = [NSBundle bundleForClass:NSClassFromString(@"WTRBundle")];
    NSURL *url = [bundle URLForResource:@"WTRBundle" withExtension:@"bundle"];
    NSBundle *imageBundle = [NSBundle bundleWithURL:url];
    NSString *path = [imageBundle pathForResource:imName ofType:@"png"];
    return [UIImage imageWithData:[NSData dataWithContentsOfFile:path] scale:2.0];
}



@end
