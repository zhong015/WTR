//
//  WTREpubShowLa.m
//  WTREpubReader
//
//  Created by wfz on 2017/3/16.
//  Copyright © 2017年 wfz. All rights reserved.
//

#import "WTREpubShowLa.h"

@implementation WTREpubShowLa

-(id)init
{
    return [self initWithFrame:CGRectZero];
}

-(id)initWithFrame:(CGRect)frame
{
    self=[super initWithFrame:frame];
    if (self) {
        self.backgroundColor=[UIColor clearColor];
    }
    return self;
}

-(void)setAttrStr:(NSAttributedString *)attrStr
{
    _attrStr=attrStr;
    
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef) attrStr);
    
    CGPathRef path =CGPathCreateWithRect(self.bounds, NULL);

    CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, NULL);
    
    [self setStrRef:frame];
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
    [self setNeedsDisplay];
}

-(void)dealloc
{
    if (_strRef) {
        CFRelease(_strRef);
        _strRef = nil;
    }
}
- (void)drawRect:(CGRect)rect {

    if (!_strRef) {
        return;
    }
    [super drawRect:rect];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(ctx, CGAffineTransformIdentity);
    CGContextTranslateCTM(ctx, 0, rect.size.height);
    CGContextScaleCTM(ctx, 1.0, -1.0);

    CTFrameDraw(_strRef, ctx);
    
//    CGContextSetFillColorWithColor(ctx, [UIColor blueColor].CGColor);
//    CGContextSetStrokeColorWithColor(ctx, [UIColor blueColor].CGColor);
//    
//    NSArray *lines = (__bridge NSArray *)CTFrameGetLines(_strRef);
//    NSInteger lineCount = [lines count];
//    CGPoint *origins = malloc(lineCount * sizeof(CGPoint)); //给每行的起始点开辟内存
//    if (lineCount) {
//        CTFrameGetLineOrigins(_strRef, CFRangeMake(0, 0), origins);
//        for (int i = 0; i<lineCount; i++) {
//            CGPoint baselineOrigin = origins[i];
//            CTLineRef line = (__bridge CTLineRef)[lines objectAtIndex:i];
//            CGFloat ascent,descent,linegap; //声明字体的上行高度和下行高度和行距
//            CGFloat lineWidth = CTLineGetTypographicBounds(line, &ascent, &descent, &linegap);
//            
//            CGContextAddArc(ctx, baselineOrigin.x, baselineOrigin.y, 5, 0, M_PI*2, YES);
//            
//            CGContextStrokePath(ctx);
////                index = CTLineGetStringIndexForPosition(line, point);
//            CGContextMoveToPoint(ctx, baselineOrigin.x, baselineOrigin.y);
//            CGContextAddLineToPoint(ctx, baselineOrigin.x+lineWidth, baselineOrigin.y);
//            CGContextStrokePath(ctx);
//            
//            CGContextMoveToPoint(ctx, baselineOrigin.x, baselineOrigin.y+ascent);
//            CGContextAddLineToPoint(ctx, baselineOrigin.x+lineWidth, baselineOrigin.y+ascent);
//            CGContextStrokePath(ctx);
//            
//            CGContextMoveToPoint(ctx, baselineOrigin.x, baselineOrigin.y-descent);
//            CGContextAddLineToPoint(ctx, baselineOrigin.x+lineWidth, baselineOrigin.y-descent);
//            CGContextStrokePath(ctx);
//        }
//    }
//    
////    CGContextStrokePath(ctx);
//    
////    CGContextFillPath(ctx);
//    
//    free(origins);
    
}


@end
