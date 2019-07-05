//
//  SVStatusShowView.m
//  WTRGitCs
//
//  Created by wfz on 2019/7/5.
//  Copyright © 2019 wfz. All rights reserved.
//

#import "SVStatusShowView.h"
#import "WTRHUD.h"

@implementation SVStatusShowView
{
    UIVisualEffectView *_vibrancyEffectView;

    UIImageView *_imageView;
    UILabel *_statusLabel;
}
- (instancetype)initWithImage:(UIImage*)image status:(NSString*)status IsWhite:(BOOL)isw
{
    // Blur effect 模糊效果
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:(isw?UIBlurEffectStyleExtraLight:UIBlurEffectStyleDark)];
    self = [super initWithEffect:blurEffect];
    if (self) {
        // Vibrancy effect 生动效果
        UIVibrancyEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:blurEffect];
        _vibrancyEffectView = [[UIVisualEffectView alloc] initWithEffect:vibrancyEffect];
        [self.contentView addSubview:_vibrancyEffectView];

        [self loaduiImage:image status:status IsWhite:isw];
    }
    return self;
}
-(void)loaduiImage:(UIImage*)image status:(NSString*)status IsWhite:(BOOL)isw
{
    UIColor *tintColor;
    if (isw) {
        tintColor=[UIColor blackColor];
    }else{
        tintColor=[UIColor whiteColor];
    }

    self.layer.cornerRadius=14.0;
    self.layer.masksToBounds=YES;
    
    UIFont *font=[UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];

    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 28.0f, 28.0f)];
    _imageView.tintColor = tintColor;
    _imageView.image = image;
    [_vibrancyEffectView.contentView addSubview:_imageView];

    _statusLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _statusLabel.backgroundColor = [UIColor clearColor];
    _statusLabel.adjustsFontSizeToFitWidth = YES;
    _statusLabel.textAlignment = NSTextAlignmentCenter;
    _statusLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    _statusLabel.numberOfLines = 0;
    _statusLabel.textColor = tintColor;
    _statusLabel.font = font;
    [_vibrancyEffectView.contentView addSubview:_statusLabel];

    CGRect labelRect = CGRectZero;
    CGFloat labelHeight = 0.0f;
    CGFloat labelWidth = 0.0f;

    if(status&&[status isKindOfClass:[NSString class]]&&status.length>0) {
        CGSize constraintSize = CGSizeMake(200.0f, 300.0f);
        labelRect = [status boundingRectWithSize:constraintSize options:(NSStringDrawingOptions)(NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin)attributes:@{NSFontAttributeName: font} context:NULL];
        labelHeight = ceilf(CGRectGetHeight(labelRect));
        labelWidth = ceilf(CGRectGetWidth(labelRect));

        _statusLabel.text=status;
        _statusLabel.bounds=labelRect;
    }

    CGFloat hudWidth;
    CGFloat hudHeight;

    CGFloat hleft=12; //左右空白间隔
    CGFloat vtop=12;  //上下空白间隔
    CGFloat wtjg=8;   //文字和图片的间隔

    hudWidth = hleft + MAX(labelWidth, _imageView.frame.size.width) + hleft;
    hudHeight = vtop + labelHeight + _imageView.frame.size.height + vtop;
    if(status&&[status isKindOfClass:[NSString class]]){
        hudHeight += wtjg; //图片和文字间隔
    }

    self.bounds=CGRectMake(0, 0, hudWidth, hudHeight);
    _vibrancyEffectView.frame = self.bounds;

    _imageView.center = CGPointMake(CGRectGetMidX(self.bounds),vtop+_imageView.frame.size.height/2.0);
    
    CGFloat centerY=CGRectGetMaxY(_imageView.frame) + wtjg + labelHeight / 2.0f;
    _statusLabel.center = CGPointMake(CGRectGetMidX(self.bounds),centerY);
}
-(void)dismissWithAnimated:(NSNumber *)animatedNum;
{
    if (self.superview) {
        [WTRHUD dismissInView:self.superview animated:animatedNum.boolValue];
    }
}

@end
