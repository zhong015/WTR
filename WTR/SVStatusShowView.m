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
    UIColor *_bgColor;
    UIImage *_image;
    NSString *_status;
    UIFont *_font;
    UIColor *_tintColor;
    CGFloat _textImageSpace;
    CGSize _bsize;
    UIEdgeInsets _edge;
    CGFloat _cornerRadius;
    
    UIImageView *_imageView;
    UILabel *_statusLabel;
}
-(instancetype)initWithImage:(nullable UIImage*)image bgColor:(UIColor *)bgColor status:(nullable NSString*)status font:(UIFont *)font tintColor:(UIColor *)tintColor textImageSpace:(CGFloat)textImageSpace boundingRectSize:(CGSize)bsize edge:(UIEdgeInsets)edge cornerRadius:(CGFloat)cornerRadius
{
    self = [super init];
    if (self) {
        _image=image;
        _bgColor=bgColor;
        _status=status;
        _font=font;
        _tintColor=tintColor;
        _textImageSpace=textImageSpace;
        _bsize=bsize;
        _edge=edge;
        _cornerRadius=cornerRadius;

        [self loadui];
    }
    return self;
}
-(void)loadui
{
    self.backgroundColor=_bgColor;
    self.layer.cornerRadius=_cornerRadius;
    self.layer.masksToBounds=YES;

    CGFloat imww=0.0;
    CGFloat imhh=0.0;
    if (_image) {
        if (_image.renderingMode != UIImageRenderingModeAlwaysTemplate) {
            _image = [_image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        }
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 28.0f, 28.0f)];
        _imageView.tintColor = _tintColor;
        _imageView.image = _image;
        [self addSubview:_imageView];
        imww=_imageView.frame.size.width;
        imhh=_imageView.frame.size.height;
    }

    CGRect labelRect = CGRectZero;
    CGFloat labelHeight = 0.0f;
    CGFloat labelWidth = 0.0f;

    if(_status&&[_status isKindOfClass:[NSString class]]&&_status.length>0) {
        _statusLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _statusLabel.backgroundColor = [UIColor clearColor];
        _statusLabel.adjustsFontSizeToFitWidth = YES;
        _statusLabel.textAlignment = NSTextAlignmentCenter;
        _statusLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        _statusLabel.numberOfLines = 0;
        _statusLabel.textColor = _tintColor;
        _statusLabel.font = _font;
        [self addSubview:_statusLabel];

        labelRect = [_status boundingRectWithSize:_bsize options:(NSStringDrawingOptions)(NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin)attributes:@{NSFontAttributeName:_font} context:NULL];
        labelHeight = ceilf(CGRectGetHeight(labelRect));
        labelWidth = ceilf(CGRectGetWidth(labelRect));
        _statusLabel.text=_status;
        _statusLabel.bounds=labelRect;
    }

    CGFloat hudWidth;
    CGFloat hudHeight;

    hudWidth = _edge.left + MAX(labelWidth, imww) + _edge.right;
    hudHeight = _edge.top + labelHeight + imhh + _edge.bottom;
    if(_image&&_status&&[_status isKindOfClass:[NSString class]]&&_status.length>0){
        hudHeight += _textImageSpace;   //图片和文字间隔
    }

    self.bounds=CGRectMake(0, 0, hudWidth, hudHeight);

    if (_imageView) {
        _imageView.center = CGPointMake(CGRectGetMidX(self.bounds),_edge.top+imhh/2.0);
    }
    if (_statusLabel) {
        CGFloat centerY=hudHeight-_edge.bottom- labelHeight / 2.0f;
        _statusLabel.center = CGPointMake(CGRectGetMidX(self.bounds),centerY);
    }
}
-(void)dismissWithAnimated:(NSNumber *)animatedNum;
{
    if (self.superview) {
        [WTRHUD dismissInView:self.superview animated:animatedNum.boolValue];
    }
}

@end
