//
//  WTRListView.m
//  CnkiIPhoneClient
//
//  Created by wfz on 2018/12/26.
//  Copyright © 2018 net.cnki.www. All rights reserved.
//

#import "WTRListView.h"
#import "UIImageView+AFNetworking.h"
#import "WTRImageListShow.h"

@implementation WTRListModel
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.contentInset=UIEdgeInsetsZero;

        self.textAlignment=NSTextAlignmentNatural;

        self.content=nil;
        self.contentAttr=nil;
        self.limitHeight=-1;
        self.contentHeight=-1;
        self.imgUrl=nil;
        self.placeholderImage=nil;
        self.imageModelArray=nil;
        self.videoUrl=nil;

        self.lineSpacing=3;
        self.imgBili=1.7;
        self.imArraybili=1.7;
        self.imgSpacing=5;
        self.videoBili=1.7;
    }
    return self;
}
@end

@interface WTRListView ()

@property(nonatomic,strong) NSMutableArray *imageUrlArray;

@end

@implementation WTRListView

+(NSAttributedString *)AttrWith:(WTRListModel *)model
{
    NSMutableParagraphStyle *pst=[[NSMutableParagraphStyle alloc] init];
    pst.lineSpacing=model.lineSpacing;
    return [[NSAttributedString alloc] initWithString:SafeRealStr(model.content) attributes:@{NSFontAttributeName:model.font,NSForegroundColorAttributeName:model.color,NSParagraphStyleAttributeName:pst}];
}

+(CGFloat)heightWithList:(NSArray <WTRListModel *>*)arr width:(CGFloat)width
{
    CGFloat hh=0;
    for (int i=0; i<arr.count; i++) {
        WTRListModel *model=arr[i];

        hh+=model.contentInset.top;

        width=width-(model.contentInset.left+model.contentInset.right);

        if (model.content&&!model.contentAttr) {
            model.contentAttr=[self AttrWith:model];
        }

        if (model.contentAttr) {
            CGSize size=[WTRZX getSizeOfStr:model.contentAttr Size:CGSizeMake(width, 4000)];
            if (model.limitHeight>0&&(size.height>model.limitHeight)) {
                size.height=model.limitHeight;
            }
            model.contentHeight=size.height;
            hh+=size.height;
        }else if (model.imgUrl){
            CGFloat imh=width/model.imgBili;
            hh+=imh;
        }else if(model.imageModelArray){
            CGFloat ww=(width-(model.imageModelArray.count-1)*model.imgSpacing)/model.imageModelArray.count;
            CGFloat imh=ww/model.imArraybili;
            hh+=imh;
        }else if (model.videoUrl){
            CGFloat imh=width/model.videoBili;
            hh+=imh;
        }

        hh+=model.contentInset.bottom;
    }
    return hh;
}

+(WTRListView *)ViewWithList:(NSArray <WTRListModel *>*)arr width:(CGFloat)width
{
    CGFloat hh=0;
    WTRListView *listView=[[WTRListView alloc] initWithFrame:CGRectMake(0, 0, width, 10)];

    for (int i=0; i<arr.count; i++) {
        WTRListModel *model=arr[i];

        hh+=model.contentInset.top;

        width=width-(model.contentInset.left+model.contentInset.right);

        if (model.content&&!model.contentAttr) {
            model.contentAttr=[self AttrWith:model];
        }

        if (model.contentAttr) {

            if (model.contentHeight<0) {
                CGSize size=[WTRZX getSizeOfStr:model.contentAttr Size:CGSizeMake(width, 4000)];
                if (model.limitHeight>0&&(size.height>model.limitHeight)) {
                    size.height=model.limitHeight;
                }
                model.contentHeight=size.height;
            }

            UILabel *la=[[UILabel alloc] initWithFrame:CGRectMake(model.contentInset.left,hh, width, model.contentHeight)];
            if (model.limitHeight>0&&(ABS((model.contentHeight-model.limitHeight))<0.1)) {

                //设置 NSLineBreakByTruncatingTail
                NSMutableParagraphStyle *pst=[[NSMutableParagraphStyle alloc] init];
                pst.lineSpacing=model.lineSpacing;
                pst.lineBreakMode=NSLineBreakByTruncatingTail;

                NSMutableAttributedString *mustr=[[NSMutableAttributedString alloc] initWithAttributedString:model.contentAttr];
                [mustr addAttribute:NSParagraphStyleAttributeName value:pst range:NSMakeRange(0, mustr.length)];

                model.contentAttr=mustr;
            }
            la.numberOfLines=0;
            la.textAlignment=model.textAlignment;
            la.attributedText=model.contentAttr;
            [listView addSubview:la];

            hh+=model.contentHeight;
        }else if (model.imgUrl){
            CGFloat imh=width/model.imgBili;

            UIImageView *imv=[[UIImageView alloc] initWithFrame:CGRectMake(model.contentInset.left, hh, width, imh)];
            [listView addSubview:imv];
            imv.contentMode=UIViewContentModeScaleAspectFill;
            imv.layer.masksToBounds=YES;

            if ([model.imgUrl isFileURL]) {
                imv.image=[UIImage imageWithContentsOfFile:model.imgUrl.path];
            }else{
                [imv setImageWithURL:model.imgUrl placeholderImage:model.placeholderImage];
            }

            listView.imageUrlArray=[NSMutableArray arrayWithObject:model.imgUrl];
            UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:listView action:@selector(tapimv:)];
            imv.userInteractionEnabled=YES;
            imv.tag=0;
            [imv addGestureRecognizer:tap];

            hh+=imh;
        }else if(model.imageModelArray){

            listView.imageUrlArray=[NSMutableArray array];

            CGFloat ww=(width-(model.imageModelArray.count-1)*model.imgSpacing)/model.imageModelArray.count;
            CGFloat imh=ww/model.imArraybili;

            for (int j=0; j<model.imageModelArray.count; j++) {
                WTRListModel *cim=model.imageModelArray[j];
                if (!cim.imgUrl) {
                    continue;
                }
                UIImageView *imv=[[UIImageView alloc] initWithFrame:CGRectMake(model.contentInset.left+(ww+model.imgSpacing)*j, hh, ww, imh)];
                [listView addSubview:imv];
                imv.contentMode=UIViewContentModeScaleAspectFill;
                imv.layer.masksToBounds=YES;

                if ([cim.imgUrl isFileURL]) {
                    imv.image=[UIImage imageWithContentsOfFile:cim.imgUrl.path];
                }else{
                    [imv setImageWithURL:cim.imgUrl placeholderImage:model.placeholderImage];
                }

                [listView.imageUrlArray addObject:cim.imgUrl];
                UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:listView action:@selector(tapimv:)];
                imv.userInteractionEnabled=YES;
                imv.tag=j;
                [imv addGestureRecognizer:tap];
            }

            hh+=imh;
        }else if (model.videoUrl){
            CGFloat imh=width/model.videoBili;

            UIImageView *imv=[[UIImageView alloc] initWithFrame:CGRectMake(model.contentInset.left, hh, width, imh)];
            [listView addSubview:imv];
            imv.contentMode=UIViewContentModeScaleAspectFill;
            imv.layer.masksToBounds=YES;

            if ([model.videoImgUrl isFileURL]) {
                imv.image=[UIImage imageWithContentsOfFile:model.videoImgUrl.path];
            }else{
                [imv setImageWithURL:model.videoImgUrl];
            }

            UIButton *bu=[UIButton new];
            [bu setImage:[UIImage imageNamed:@"RTCVideoPlay"] forState:UIControlStateNormal];
            [imv addSubview:bu];
            bu.width=50;
            bu.height=50;
            bu.center=CGPointMake(imv.width/2.0, imv.height/2.0);
            bu.userInteractionEnabled=NO;

//            videoimv=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"WTRPhotosVideo"]];
//            [self addSubview:videoimv];

            hh+=imh;
        }

        hh+=model.contentInset.bottom;
    }

    listView.height=hh;
    return listView;
}

-(void)tapimv:(UITapGestureRecognizer *)tap
{
    if (self.imageUrlArray) {
        NSURL *curl=self.imageUrlArray[tap.view.tag];
        [WTRImageListShow ShowImageList:self.imageUrlArray current:curl fromView:tap.view configeOne:^(UIImageView * _Nonnull imv, NSURL * _Nonnull imageurl) {
            if ([imageurl isFileURL]) {
                imv.image=[UIImage imageWithContentsOfFile:imageurl.path];
            }else{
                [imv setImageWithURL:imageurl];
            }
        } completion:^{

        }];
    }
}

@end
