//
//  WCTLabel.m
//  CnkiIPhoneClient
//
//  Created by wfz on 2023/9/22.
//  Copyright © 2023 net.cnki.www. All rights reserved.
//

#import "WCTLabel.h"

/*
 字体 从上到下位置

    上行高度 ascent
    原点 origin
    下行高度 descent
    间距 linegap

 行距是 上行高度+下行高度+间距
 */

typedef struct WTRCTline {
    NSInteger index;
    CGPoint origin;
    CGPoint originleftUp; //左上角原点
    CGFloat ascent,descent,linegap;
    double lineWidth;
    CFRange strRange;
}WTRCTline;

#define WCTLabelMAXH 999999.0

@interface WCTLabel ()

@property(nonatomic) CGFloat preferredMaxLayoutWidth;

@property(nonatomic,assign)CTFrameRef strRef;

@property(nonatomic,strong)UITapGestureRecognizer *tap;

@end

@implementation WCTLabel
{
    CGFloat firstLineHeadIndent;
    CGFloat ascentAnddescent;
}

+(CGSize)sizeWithAttrStr:(NSAttributedString *)atr maxSize:(CGSize)maxSize contentInsets:(UIEdgeInsets)contentInsets
{
    if (!atr||![atr isKindOfClass:[NSAttributedString class]]) {
        return CGSizeZero;
    }
    
    CGSize inMaxSize=CGSizeMake(maxSize.width-contentInsets.left-contentInsets.right, maxSize.height-contentInsets.top-contentInsets.bottom);
    
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef) atr);
    CGSize retsize=CTFramesetterSuggestFrameSizeWithConstraints(frameSetter, CFRangeMake(0, atr.length), NULL, inMaxSize, nil);
    CFRelease(frameSetter);
    
    retsize=CGSizeMake(retsize.width+contentInsets.left+contentInsets.right, retsize.height+contentInsets.top+contentInsets.bottom);
    retsize.width=ceilf(retsize.width);
    retsize.width=ceilf(retsize.width);
    
    return retsize;
}

-(void)layoutSubviews
{
    self.preferredMaxLayoutWidth = self.bounds.size.width;
    [super layoutSubviews];
}
- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    self.preferredMaxLayoutWidth = self.bounds.size.width;
}
-(CGSize)intrinsicContentSize
{
    return [WCTLabel sizeWithAttrStr:_attributedText maxSize:CGSizeMake(self.preferredMaxLayoutWidth,WCTLabelMAXH) contentInsets:_contentInsets];
}

- (void)sizeToFit
{
    CGSize cs=[WCTLabel sizeWithAttrStr:_attributedText maxSize:CGSizeMake(self.preferredMaxLayoutWidth,WCTLabelMAXH) contentInsets:_contentInsets];
    self.frame=CGRectMake(self.frame.origin.x, self.frame.origin.y, cs.width, cs.height);//不能用bounds，bounds坐标系为中心，会改变x,y
}

- (CGSize)sizeThatFits:(CGSize)size
{
    return [WCTLabel sizeWithAttrStr:_attributedText maxSize:size contentInsets:_contentInsets];
}

- (void)setPreferredMaxLayoutWidth:(CGFloat)preferredMaxLayoutWidth
{
    _preferredMaxLayoutWidth = preferredMaxLayoutWidth;
    [self invalidateIntrinsicContentSize];
    [self setNeedsDisplay];
}

-(void)setAttributedText:(NSAttributedString *)attributedText
{
    _attributedText=attributedText;
    _preferredMaxLayoutWidth=0;
    [self invalidateIntrinsicContentSize];
    [self setNeedsDisplay];
}

- (void)setContentInsets:(UIEdgeInsets)contentInsets
{
    _contentInsets=contentInsets;
    [self invalidateIntrinsicContentSize];
    [self setNeedsDisplay];
}

-(void)loadStrRefWithRect:(CGRect)rect
{
    if(!_attributedText||![_attributedText isKindOfClass:[NSAttributedString class]]){
        [self setStrRef:nil];
        return;
    }
    firstLineHeadIndent=0;
    
    if (_attributedText.length>0) {
        NSDictionary *yattributes=[_attributedText attributesAtIndex:0 effectiveRange:nil];
        NSParagraphStyle *cst=[yattributes objectForKey:NSParagraphStyleAttributeName];
        if (cst) {
            firstLineHeadIndent=cst.firstLineHeadIndent;
        }
    }
    
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)_attributedText);

    CGPathRef path =CGPathCreateWithRect(rect, NULL);

    CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, NULL);

    [self setStrRef:frame];

    CFRelease(frameSetter);
    CFRelease(path);
}


-(void)setStrRef:(CTFrameRef)strRef
{
    if (_strRef != strRef) {
        if (_strRef) {
            CFRelease(_strRef);
            _strRef = nil;
        }
        _strRef = strRef;
    }
}
-(void)dealloc
{
    if (_strRef) {
        CFRelease(_strRef);
        _strRef = nil;
    }
}
- (void)drawRect:(CGRect)rect {

    [super drawRect:rect];
    [self loadStrRefWithRect:UIEdgeInsetsInsetRect(rect, UIEdgeInsetsMake(_contentInsets.bottom, _contentInsets.left, _contentInsets.top, _contentInsets.right))];
    if (!_strRef) {
        return;
    }

    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
//    CGContextSaveGState(ctx);
    
    CGContextSetTextMatrix(ctx, CGAffineTransformIdentity);
    CGContextTranslateCTM(ctx, 0, rect.size.height);
    CGContextScaleCTM(ctx, 1.0, -1.0);
    CTFrameDraw(_strRef, ctx);
    
//    CGContextRestoreGState(ctx);
    
}

-(NSInteger)indexWithTapPoint:(CGPoint)inpo
{
    inpo.x=inpo.x-_contentInsets.left;
    inpo.y=inpo.y-_contentInsets.top;
    
    if (!_strRef) {
        return -1;
    }
    NSArray *lines = (__bridge NSArray *)CTFrameGetLines(_strRef);
    if (!lines||lines.count==0) {
        return -1;
    }
    NSInteger linesCount=lines.count;

    WTRCTline *wtrlines = malloc(linesCount * sizeof(WTRCTline));
    CGPoint *origins = malloc(linesCount * sizeof(CGPoint));

    CTFrameGetLineOrigins(_strRef, CFRangeMake(0, 0), origins);

    for (NSInteger i=0; i<linesCount; i++) {
        wtrlines[i].index=i;
        wtrlines[i].origin=origins[i];

        CTLineRef line = (__bridge CTLineRef)[lines objectAtIndex:i];
        wtrlines[i].strRange=CTLineGetStringRange(line);

        CGFloat ascent,descent,linegap; //上行高度、下行高度、行距
        double lineWidth = CTLineGetTypographicBounds(line, &ascent, &descent, &linegap);

        //上下翻转 再减上行高度 得到左上角原点
        origins[i].y=self.frame.size.height-_contentInsets.top-_contentInsets.bottom-origins[i].y-ascent;

        wtrlines[i].originleftUp=origins[i];
        wtrlines[i].lineWidth=lineWidth;
        wtrlines[i].ascent=ascent;
        wtrlines[i].descent=descent;
        wtrlines[i].linegap=linegap;
    }

    if (inpo.y<wtrlines[0].originleftUp.y) {//小于0行
        free(wtrlines);
        free(origins);
        return 0;
    }
    if (inpo.y>wtrlines[linesCount-1].originleftUp.y+wtrlines[linesCount-1].ascent+wtrlines[linesCount-1].descent+wtrlines[linesCount-1].linegap) {
        free(wtrlines);
        free(origins);
        return [self getVisibleRange].length;//-1;//大于最大行
    }

    NSInteger hang=linesCount-1;
    for (int i=0; i<linesCount-1; i++){
        if (inpo.y>wtrlines[i].originleftUp.y-0.01&&inpo.y<wtrlines[i+1].originleftUp.y+0.01) {
            hang=i;
            break;
        }
    }
    WTRCTline wtrline=wtrlines[hang];

    CTLineRef line = (__bridge CTLineRef)[lines objectAtIndex:hang];

    CFIndex lindex=CTLineGetStringIndexForPosition(line, CGPointMake(inpo.x-wtrline.origin.x, wtrline.origin.y-inpo.y));//这个是从第一行第一个字算的 直接返回就行

    free(wtrlines);
    free(origins);

    return lindex;
}
-(CGPoint)pointWithIndex:(NSInteger)index
{
    if (!_strRef) {
        return CGPointMake(-1, -1);
    }
    NSArray *lines = (__bridge NSArray *)CTFrameGetLines(_strRef);
    if (!lines||lines.count==0) {
        return CGPointMake(-1, -1);
    }
    NSInteger linesCount=lines.count;

    CGPoint *origins = malloc(linesCount * sizeof(CGPoint));
    CTFrameGetLineOrigins(_strRef, CFRangeMake(0, 0), origins);

    for (NSInteger i=0; i<linesCount; i++) {
        CTLineRef line = (__bridge CTLineRef)[lines objectAtIndex:i];
        CFRange strRange=CTLineGetStringRange(line);
        if ((index>=strRange.location&&index<strRange.location+strRange.length)||(i==linesCount-1&&index==strRange.location+strRange.length)) {
            CGFloat ascent,descent,linegap; //上行高度、下行高度、行距
            CTLineGetTypographicBounds(line, &ascent, &descent, &linegap);

            origins[i].y=self.frame.size.height-_contentInsets.top-_contentInsets.bottom-origins[i].y-ascent;
            
            ascentAnddescent=ascent+descent;
    
            CGFloat offset=CTLineGetOffsetForStringIndex(line, index, nil);
            
            CGPoint rpo=CGPointMake(origins[i].x+offset, origins[i].y);
            rpo.x=roundf(rpo.x);
            rpo.y=roundf(rpo.y);
            if (isnan(rpo.x)||isinf(rpo.x)) {
                rpo.x=0;
            }
            if (isnan(rpo.y)||isinf(rpo.y)) {
                rpo.y=0;
            }
            free(origins);
            return CGPointMake(rpo.x+_contentInsets.left, rpo.y+_contentInsets.top);
        }
    }
    free(origins);
    return CGPointMake(-1, -1);
}
-(CFRange)getVisibleRange
{
    if(!_strRef){
        return CFRangeMake(0, 0);
    }
    return CTFrameGetVisibleStringRange(_strRef);
}

- (void)setTapClick:(void (^)(WCTLabel * _Nonnull, CGPoint, NSInteger))tapClick
{
    _tapClick = tapClick;
    
    if(!self.tap){
        self.tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ctTapClick:)];
        [self addGestureRecognizer:self.tap];
    }
}
-(void)ctTapClick:(UITapGestureRecognizer *)tap
{
    CGPoint cpo=[tap locationInView:self];
    NSInteger index=[self indexWithTapPoint:cpo];
    if(self.tapClick){
        self.tapClick(self, cpo, index);
    }
}


@end
