//
//  WTREpubConfig.m
//  WTREpubReader
//
//  Created by wfz on 2017/3/16.
//  Copyright © 2017年 wfz. All rights reserved.
//

#import "WTREpubConfig.h"
#import "WTREpubShareData.h"

//字体
#define WJIACUZITI(x) [UIFont fontWithName:@"Helvetica-Bold" size:x] //加粗字体
#define TxtReaderRGB(R, G, B)    [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:1.0]

@implementation WTREpubConfig

+(instancetype)shareInstance
{
    static WTREpubConfig *readConfig = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        readConfig = [[self alloc] init];
        
    });
    return readConfig;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        
        NSData *data = [[WTREpubShareData shareInstence] objectForKey:@"ReadConfig"];
        if (data) {
            NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
            WTREpubConfig *config = [unarchive decodeObjectForKey:@"ReadConfig"];
            if (config) {
                [[NSNotificationCenter defaultCenter] addObserver:config selector:@selector(updateLocalConfig) name:UIApplicationWillResignActiveNotification object:nil];
                return config;
            }
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLocalConfig) name:UIApplicationWillResignActiveNotification object:nil];
       
        _titleFont = WJIACUZITI(19);//[UIFont systemFontOfSize:18];
        _titleLineSpace = 7.0f;
        _titleColor =  [UIColor blackColor];
        
        _authorFont = [UIFont systemFontOfSize:15];
        _authorLineSpace = 3.0f;
        _authorColor =  [UIColor blackColor];
        
        _subTitleFont = WJIACUZITI(17);//[UIFont systemFontOfSize:16];
        _subTitleLineSpace = 6.0f;
        _subTitleColor =  [UIColor blackColor];
        
        _contentFont = [UIFont systemFontOfSize:16];
        _contentlineSpace = 3.0f;
        _contentColor =  [UIColor blackColor];
        
        _imageTitleFont = [UIFont systemFontOfSize:14];
        _imageTitlelineSpace = 2.0f;
        _imageTitleColor =  [UIColor blackColor];
        
        _themeColor=TxtReaderRGB(190, 182, 162);//[UIColor whiteColor];
        
        _contentEdgeInsets=UIEdgeInsetsMake(40, 20, 20, 20);
        _imageEdgeInsets=UIEdgeInsetsMake(0, 0, 10, 0);
    
        [self updateLocalConfig];
    }
    return self;
}
-(void)updateLocalConfig
{
    NSMutableData *data=[[NSMutableData alloc]init];
    NSKeyedArchiver *archiver=[[NSKeyedArchiver alloc]initForWritingWithMutableData:data];
    [archiver encodeObject:self forKey:@"ReadConfig"];
    [archiver finishEncoding];
    [[WTREpubShareData shareInstence] setObject:data forKey:@"ReadConfig"];
}
-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.titleFont forKey:@"titleFont"];
    [aCoder encodeObject:self.titleColor forKey:@"titleColor"];
    [aCoder encodeDouble:self.titleLineSpace forKey:@"titleLineSpace"];
    
    [aCoder encodeObject:self.authorFont forKey:@"authorFont"];
    [aCoder encodeObject:self.authorColor forKey:@"authorColor"];
    [aCoder encodeDouble:self.authorLineSpace forKey:@"authorLineSpace"];
    
    [aCoder encodeObject:self.subTitleFont forKey:@"subTitleFont"];
    [aCoder encodeObject:self.subTitleColor forKey:@"subTitleColor"];
    [aCoder encodeDouble:self.subTitleLineSpace forKey:@"subTitleLineSpace"];
    
    [aCoder encodeObject:self.contentFont forKey:@"contentFont"];
    [aCoder encodeObject:self.contentColor forKey:@"contentColor"];
    [aCoder encodeDouble:self.contentlineSpace forKey:@"contentlineSpace"];
    
    [aCoder encodeObject:self.imageTitleFont forKey:@"imageTitleFont"];
    [aCoder encodeObject:self.imageTitleColor forKey:@"imageTitleColor"];
    [aCoder encodeDouble:self.imageTitlelineSpace forKey:@"imageTitlelineSpace"];
    
    
    [aCoder encodeObject:self.themeColor forKey:@"themeColor"];
    
    [aCoder encodeUIEdgeInsets:self.contentEdgeInsets forKey:@"contentEdgeInsets"];
    [aCoder encodeUIEdgeInsets:self.imageEdgeInsets forKey:@"imageEdgeInsets"];
    
    
}
-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {

        self.titleFont=[aDecoder decodeObjectForKey:@"titleFont"];
        self.titleColor=[aDecoder decodeObjectForKey:@"titleColor"];
        self.titleLineSpace=[aDecoder decodeDoubleForKey:@"titleLineSpace"];
        
        self.authorFont=[aDecoder decodeObjectForKey:@"authorFont"];
        self.authorColor=[aDecoder decodeObjectForKey:@"authorColor"];
        self.authorLineSpace=[aDecoder decodeDoubleForKey:@"authorLineSpace"];
        
        self.subTitleFont=[aDecoder decodeObjectForKey:@"subTitleFont"];
        self.subTitleColor=[aDecoder decodeObjectForKey:@"subTitleColor"];
        self.subTitleLineSpace=[aDecoder decodeDoubleForKey:@"subTitleLineSpace"];
        
        self.contentFont=[aDecoder decodeObjectForKey:@"contentFont"];
        self.contentColor=[aDecoder decodeObjectForKey:@"contentColor"];
        self.contentlineSpace=[aDecoder decodeDoubleForKey:@"contentlineSpace"];
        
        self.imageTitleFont=[aDecoder decodeObjectForKey:@"imageTitleFont"];
        self.imageTitleColor=[aDecoder decodeObjectForKey:@"imageTitleColor"];
        self.imageTitlelineSpace=[aDecoder decodeDoubleForKey:@"imageTitlelineSpace"];
        
        self.themeColor=[aDecoder decodeObjectForKey:@"themeColor"];
        
        self.contentEdgeInsets=[aDecoder decodeUIEdgeInsetsForKey:@"contentEdgeInsets"];
        self.imageEdgeInsets=[aDecoder decodeUIEdgeInsetsForKey:@"imageEdgeInsets"];

    }
    return self;
}

+(NSMutableDictionary *)AttributeTitle
{
    WTREpubConfig *contfig=[WTREpubConfig shareInstance];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[NSForegroundColorAttributeName] = contfig.titleColor;
    dict[NSFontAttributeName] = contfig.titleFont;
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = contfig.titleLineSpace;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    dict[NSParagraphStyleAttributeName] = paragraphStyle;
    return dict;
}
+(NSMutableDictionary *)AttributeAuthor
{
    WTREpubConfig *contfig=[WTREpubConfig shareInstance];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[NSForegroundColorAttributeName] = contfig.authorColor;
    dict[NSFontAttributeName] = contfig.authorFont;
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = contfig.authorLineSpace;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    dict[NSParagraphStyleAttributeName] = paragraphStyle;
    return dict;
}

+(NSMutableDictionary *)AttributeSubTitle
{
    WTREpubConfig *contfig=[WTREpubConfig shareInstance];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[NSForegroundColorAttributeName] = contfig.subTitleColor;
    dict[NSFontAttributeName] = contfig.subTitleFont;
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = contfig.subTitleLineSpace;
    paragraphStyle.alignment = NSTextAlignmentLeft;
    dict[NSParagraphStyleAttributeName] = paragraphStyle;
    return dict;
}


+(NSMutableDictionary *)AttributeContentWithFL:(BOOL)iswf
{
    WTREpubConfig *contfig=[WTREpubConfig shareInstance];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[NSForegroundColorAttributeName] = contfig.contentColor;
    dict[NSFontAttributeName] = contfig.contentFont;
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = contfig.contentlineSpace;
    paragraphStyle.alignment = NSTextAlignmentJustified;
    
    if (iswf) {
        CGFloat zw=contfig.contentFont.pointSize;
        paragraphStyle.firstLineHeadIndent=zw*2;
    }
    
    dict[NSParagraphStyleAttributeName] = paragraphStyle;
    return dict;
}

+(NSMutableDictionary *)AttributeImageTitle
{
    WTREpubConfig *contfig=[WTREpubConfig shareInstance];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[NSForegroundColorAttributeName] = contfig.imageTitleColor;
    dict[NSFontAttributeName] = contfig.imageTitleFont;
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = contfig.imageTitlelineSpace;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    dict[NSParagraphStyleAttributeName] = paragraphStyle;
    return dict;
}



@end
