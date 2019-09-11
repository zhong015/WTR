//
//  WTREpubHtmlFile.m
//  WTREpubReader
//
//  Created by wfz on 2017/3/17.
//  Copyright © 2017年 wfz. All rights reserved.
//

#import "WTREpubHtmlFile.h"
#import <CoreText/CoreText.h>
#import "WTREpubShowLa.h"
#import "WTRDefine.h"

@implementation WTREpubParagraph

-(id)init
{
    self=[super init];
    if (self) {
        self.topBlankHeight=0;
        self.bottomBlankHeight=0;
    }
    return self;
}

@end

@implementation WTREpubPage

-(id)init
{
    self=[super init];
    if (self) {
        self.paragraphArray=[NSMutableArray array];
    }
    return self;
}
#pragma mark 得到显示view
-(UIView *)getView
{
    UIView *bacView=[[UIView alloc]initWithFrame:ScreenBounds];
    for (int i=0; i<self.paragraphArray.count; i++) {
        WTREpubParagraph *parag=[self.paragraphArray objectAtIndex:i];
        if (parag.attrString) {
            if (parag.type==0) {
                UILabel *la=[[UILabel alloc]initWithFrame:parag.frame];
                la.numberOfLines=0;
                la.attributedText=parag.attrString;
                [bacView addSubview:la];
            } else if (parag.type==1){
                WTREpubShowLa *la=[[WTREpubShowLa alloc]initWithFrame:parag.frame];
                la.attrStr=parag.attrString;
                [bacView addSubview:la];
            }
        }else if (parag.image){
            UIImageView *imv=[[UIImageView alloc] initWithFrame:parag.frame];
            imv.image=parag.image;
            [bacView addSubview:imv];
        }
    }
//    bacView.backgroundColor=[WTREpubConfig shareInstance].themeColor;
    return bacView;
}


@end

@interface WTREpubHtmlFile ()<NSXMLParserDelegate>

@end


@implementation WTREpubHtmlFile
{
    NSXMLParser *parser;
    WTREpubParagraphType parserType;
    NSString *foundCharacters;
    BOOL isload;
}
-(id)init
{
    self=[super init];
    if (self) {
        isload=NO;
        self.pageArray=[NSMutableArray array];
    }
    return self;
}
-(void)loaddataIfNotLoad
{
    if (!isload) {
        isload=YES;
        [self loadHtmlFile:self.filePath];
        if (self.pageArray.count<=0) {
            [self addblankpage];
        }
    }
}
-(void)Clearloaddata
{
    isload=NO;
    [self.pageArray removeAllObjects];
}
-(void)loadHtmlFile:(NSString *)filePath
{
    if (!filePath||![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return;
    }
    NSString *str=[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];

    if (!ISString(str)) {
        return;
    }
    NSRange bdr1=[str rangeOfString:@"<body>"];
    NSRange bdr2=[str rangeOfString:@"</body>"];

    if (bdr1.length>0&&bdr2.length>0) {
        str=[str substringWithRange:NSMakeRange(bdr1.location, (bdr2.location+bdr2.length-bdr1.location))];
    }
    
    parser = [[NSXMLParser alloc] initWithData:[str dataUsingEncoding:NSUTF8StringEncoding]];
    
    parser.delegate=self;
    
    foundCharacters=@"";
    [parser parse];
}
#pragma mark 解析xml
- (void)parser:(__unused NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(__unused NSString *)namespaceURI qualifiedName:(__unused NSString *)qName attributes:(NSDictionary *)attributeDict
{
    parserType=WTREpubParagNotDefin;
    
    if (elementName) {
        if ([elementName isEqualToString:@"style"]) {
            parserType=WTREpubParagHtmlStyle;
        }else if ([elementName isEqualToString:@"script"]) {
            parserType=WTREpubParagHtmlJS;
        }else if ([elementName isEqualToString:@"title"]) {
            parserType=WTREpubParagHtmlTitle;
        }else if ([elementName isEqualToString:@"h1"]) {
            parserType=WTREpubParagTitle;
        }else if ([elementName isEqualToString:@"h2"]) {
            parserType=WTREpubParagTitle;
        }else if (attributeDict){
            NSString *class=[attributeDict objectForKey:@"class"];
            if (ISString(class)) {
                if ([class rangeOfString:@"section"].length>0) {
                    parserType=WTREpubParagSubTitle;
                }else if ([class rangeOfString:@"author"].length>0) {
                    parserType=WTREpubParagAuthor;
                }else if ([class rangeOfString:@"image"].length>0) {
                    parserType=WTREpubParagImageTitle;
                }else if ([class rangeOfString:@"img"].length>0) {
                    parserType=WTREpubParagImageTitle;
                }else if ([class rangeOfString:@"title"].length>0) {
                    parserType=WTREpubParagTitle;
                }
            }
            
            NSString *type=[attributeDict objectForKey:@"type"];
            if (ISString(type)) {
                if ([type isEqualToString:@"text/css"]) {
                    parserType=WTREpubParagHtmlStyle;
                }else if ([type isEqualToString:@"text/javascript"]) {
                    parserType=WTREpubParagHtmlJS;
                }
            }
            
//            for (NSString *astrkey in attributeDict) {
//                NSString *astr=[attributeDict objectForKey:astrkey];
//                if ([astr isKindOfClass:[NSString class]]) {
//                    NSString *extension=[astr pathExtension];
//                    
//                    if ([extension rangeOfString:@"jpg" options:NSCaseInsensitiveSearch].length>0) {
//                        parserType=WTREpubParagImage;
//                        
//                    } else if ([extension rangeOfString:@"png" options:NSCaseInsensitiveSearch].length>0) {
//                        parserType=WTREpubParagImage;
//                    }
//                    if (parserType==WTREpubParagImage) {
//                        NSString *impath=[[self.filePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:[astr stringByReplacingOccurrencesOfString:@".." withString:@""]];
//                        [self addImageWithPath:impath];
//                        break;
//                    }
//                }
//            }
            
            NSString *src=[attributeDict objectForKey:@"src"];
            if (src) {
                NSString *extension=[src pathExtension];
                if ([extension rangeOfString:@"jpg" options:NSCaseInsensitiveSearch].length>0) {
                    parserType=WTREpubParagImage;
                    
                } else if ([extension rangeOfString:@"png" options:NSCaseInsensitiveSearch].length>0) {
                    parserType=WTREpubParagImage;
                } else if ([extension rangeOfString:@"bmp" options:NSCaseInsensitiveSearch].length>0) {
                    parserType=WTREpubParagImage;
                }
                if (parserType==WTREpubParagImage) {
                    NSString *impath=[[self.filePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:src];
                    [self addImageWithPath:impath];
                }
            }
        
        }
    }
}
- (void)parser:(__unused NSXMLParser *)parser didEndElement:(__unused NSString *)elementName namespaceURI:(__unused NSString *)namespaceURI qualifiedName:(__unused NSString *)qName
{
    if (!foundCharacters||foundCharacters.length==0) {
        foundCharacters=@"";
        return;
    }
    
    //去除段首空格空行
    unichar ch=[foundCharacters characterAtIndex:0];
    NSString *cstr=[NSString stringWithFormat:@"%C",ch];
    int junmp=0;
    while (ch=='\n'||ch=='\r'||ch==' '||ch=='\t'||[cstr isEqualToString:@"\u3000"]) {
        junmp++;
        if (junmp>=foundCharacters.length) {
            break;
        }
        ch=[foundCharacters characterAtIndex:junmp];
        cstr=[NSString stringWithFormat:@"%C",ch];
    }
    foundCharacters=[foundCharacters substringFromIndex:junmp];
    
    if (foundCharacters.length>0) {
        switch (parserType) {
            case WTREpubParagNotDefin:
            case WTREpubParagContent:
            {
                NSString *retstr=[self addContentWithString:foundCharacters WithFL:YES];
                while (retstr&&retstr.length>0) {
                    if (retstr.length==foundCharacters.length) {
                        retstr=[self addContentWithString:retstr WithFL:YES];
                    }else{
                        retstr=[self addContentWithString:retstr WithFL:NO];
                    }
                }
            }
                break;
            case WTREpubParagTitle:
            {
                [self addTitleWithString:foundCharacters];
            }
                break;
            case WTREpubParagAuthor:
            {
                [self addAuthorWithString:foundCharacters];
            }
                break;
            case WTREpubParagImageTitle:
            {
                [self addImageTitleWithString:foundCharacters];
            }
                break;
            case WTREpubParagSubTitle:
            {
                [self addSubTitleWithString:foundCharacters];
            }
                break;
            default:
                break;
        }
    }
    foundCharacters=@"";
}

- (void)parser:(__unused NSXMLParser *)parser foundCharacters:(NSString *)string
{
   if (!string||string.length==0||[string isEqualToString:@"\n"]) {
        return;
    }
    foundCharacters=[foundCharacters stringByAppendingString:string];
}

- (void)parser:(__unused NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock
{
    NSLog(@"foundCDATA:%@",[[NSString alloc] initWithData:CDATABlock encoding:NSUTF8StringEncoding]);
}

- (void)parser:(__unused NSXMLParser *)parser foundComment:(NSString *)comment
{
    NSLog(@"foundComment:%@",comment);
}

#pragma mark 加入数据
-(void)addblankpage
{
    WTREpubPage *page=[[WTREpubPage alloc]init];
    if (self.pageArray.count>0) {
        WTREpubPage *lastpage=[self.pageArray lastObject];
        page.curintpage=lastpage.curintpage+1;
    }
    else
    {
        page.curintpage=0;
    }
    [self.pageArray addObject:page];
}

-(void)addTitleWithString:(NSString *)string
{
    if (self.pageArray.count<=0) {
        [self addblankpage];
    }
    WTREpubPage *page=[self.pageArray lastObject];
    
    WTREpubParagraph *lastparag=[[page paragraphArray] lastObject];
    
    NSAttributedString *atrstr=[[NSAttributedString alloc] initWithString:string attributes:[WTREpubConfig AttributeTitle]];
    
    UIEdgeInsets contenti=[WTREpubConfig shareInstance].contentEdgeInsets;
    
    CGFloat bw=ScreenWidth-contenti.left-contenti.right;
    
    CGSize size=[atrstr boundingRectWithSize:CGSizeMake(bw, 4000) options:NSStringDrawingUsesFontLeading|NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    
    WTREpubParagraph *parag=[[WTREpubParagraph alloc]init];
    parag.attrString=atrstr;
    if (lastparag) {
        CGFloat lastbottom=(lastparag)?(lastparag.frame.origin.y+lastparag.frame.size.height+lastparag.bottomBlankHeight+[WTREpubConfig shareInstance].titleLineSpace*1.5):contenti.top;
        
        CGFloat bh=ScreenHeight-contenti.top-contenti.bottom;
        if (lastbottom+size.height>bh) {
            [self addblankpage];
            page=[self.pageArray lastObject];
            lastparag=[[page paragraphArray] lastObject];
            lastbottom=(lastparag)?(lastparag.frame.origin.y+lastparag.frame.size.height+lastparag.bottomBlankHeight+[WTREpubConfig shareInstance].titleLineSpace*1.5):contenti.top;
        }
        parag.frame=CGRectMake(contenti.left,lastbottom,bw, size.height);
    }
    else
        parag.frame=CGRectMake(contenti.left, contenti.top,bw, size.height);
    
    parag.bottomBlankHeight=[WTREpubConfig shareInstance].titleLineSpace*1.5;
    parag.topBlankHeight=[WTREpubConfig shareInstance].titleLineSpace*1.5;
    parag.type=0;
    parag.Paragtype=WTREpubParagTitle;
    [page.paragraphArray addObject:parag];
}

-(void)addAuthorWithString:(NSString *)string
{
    if (self.pageArray.count<=0) {
        [self addblankpage];
    }
    WTREpubPage *page=[self.pageArray lastObject];
    WTREpubParagraph *lastparag=[[page paragraphArray] lastObject];
    
    NSAttributedString *atrstr=[[NSAttributedString alloc] initWithString:string attributes:[WTREpubConfig AttributeAuthor]];
    
    UIEdgeInsets contenti=[WTREpubConfig shareInstance].contentEdgeInsets;
    
    CGFloat bw=ScreenWidth-contenti.left-contenti.right;
    
    CGSize size=[atrstr boundingRectWithSize:CGSizeMake(bw, 4000) options:NSStringDrawingUsesFontLeading|NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    
    CGFloat lastbottom=(lastparag)?(lastparag.frame.origin.y+lastparag.frame.size.height+lastparag.bottomBlankHeight):contenti.top;
    
    CGFloat bh=ScreenHeight-contenti.top-contenti.bottom;
    
    if (lastbottom+size.height>bh) {
        [self addblankpage];
        page=[self.pageArray lastObject];
        lastparag=[[page paragraphArray] lastObject];
        lastbottom=(lastparag)?(lastparag.frame.origin.y+lastparag.frame.size.height+lastparag.bottomBlankHeight):contenti.top;
    }
    
    WTREpubParagraph *parag=[[WTREpubParagraph alloc]init];
    parag.attrString=atrstr;
    parag.frame=CGRectMake(contenti.left,lastbottom,bw, size.height);
    parag.bottomBlankHeight=[WTREpubConfig shareInstance].authorLineSpace*1.5;
    parag.type=0;
    parag.Paragtype=WTREpubParagAuthor;
    [page.paragraphArray addObject:parag];
}

-(void)addSubTitleWithString:(NSString *)string
{
    if (self.pageArray.count<=0) {
        [self addblankpage];
    }
    WTREpubPage *page=[self.pageArray lastObject];
    WTREpubParagraph *lastparag=[[page paragraphArray] lastObject];
    
    NSAttributedString *atrstr=[[NSAttributedString alloc] initWithString:string attributes:[WTREpubConfig AttributeSubTitle]];
    
    UIEdgeInsets contenti=[WTREpubConfig shareInstance].contentEdgeInsets;
    
    CGFloat bw=ScreenWidth-contenti.left-contenti.right;
    
    CGFloat bh=ScreenHeight-contenti.top-contenti.bottom;
    
    CGSize size=[atrstr boundingRectWithSize:CGSizeMake(bw, 4000) options:NSStringDrawingUsesFontLeading|NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    
    CGFloat lastbottom=(lastparag)?(lastparag.frame.origin.y+lastparag.frame.size.height+lastparag.bottomBlankHeight+[WTREpubConfig shareInstance].subTitleLineSpace*1.5):contenti.top;
    
    if (lastbottom+size.height>bh) {
        [self addblankpage];
        page=[self.pageArray lastObject];
        lastparag=[[page paragraphArray] lastObject];
    }
    
    WTREpubParagraph *parag=[[WTREpubParagraph alloc]init];
    parag.attrString=atrstr;
    parag.frame=CGRectMake(contenti.left,(lastparag)?lastbottom:contenti.top,bw, size.height);
    parag.bottomBlankHeight=[WTREpubConfig shareInstance].subTitleLineSpace*1.5;
    parag.topBlankHeight=[WTREpubConfig shareInstance].subTitleLineSpace*1.5;
    parag.type=0;
    parag.Paragtype=WTREpubParagSubTitle;
    [page.paragraphArray addObject:parag];
}

-(NSString *)addContentWithString:(NSString *)string WithFL:(BOOL)iswf
{
    if (self.pageArray.count<=0) {
        [self addblankpage];
    }
    WTREpubPage *page=[self.pageArray lastObject];
    WTREpubParagraph *lastparag=[[page paragraphArray] lastObject];
    
    NSAttributedString *atrstr=[[NSAttributedString alloc] initWithString:string attributes:[WTREpubConfig AttributeContentWithFL:iswf]];
    
    UIEdgeInsets contenti=[WTREpubConfig shareInstance].contentEdgeInsets;
    
    CGFloat bw=ScreenWidth-contenti.left-contenti.right;
    CGFloat bh=ScreenHeight-contenti.top-contenti.bottom;
    
    CGSize size=[atrstr boundingRectWithSize:CGSizeMake(bw, 4000) options:NSStringDrawingUsesFontLeading|NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    
    CGFloat lastbottom=(lastparag)?(lastparag.frame.origin.y+lastparag.frame.size.height+lastparag.bottomBlankHeight):contenti.top;
    
    lastbottom+=[WTREpubConfig shareInstance].contentFont.pointSize/2;//Content文字前面空白 调整
    
    if (lastbottom+size.height>bh) {
        
        CGRect sxdrect=CGRectMake(contenti.left,lastbottom, bw, ScreenHeight-contenti.bottom-lastbottom);
        
        CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef) atrstr);
        
        CGPathRef path = CGPathCreateWithRect(sxdrect, NULL);
        
        CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, NULL);
        CFRange range = CTFrameGetVisibleStringRange(frame);
        if (range.length==0) {
            if (self.pageArray.count<=0) {
                NSLog(@"文字占不下: %@",string);
                return nil;
            }
            [self addblankpage];
            return string;
        }
        
        WTREpubParagraph *parag=[[WTREpubParagraph alloc]init];
        parag.attrString=atrstr;
        parag.visibleRange=range;
        parag.frame=sxdrect;
        parag.bottomBlankHeight=[WTREpubConfig shareInstance].contentFont.pointSize/2;
        parag.type=1;
        parag.Paragtype=WTREpubParagContent;
        [page.paragraphArray addObject:parag];
        
        if (string.length<=range.length+range.location) {
            return nil;
        }
        return [string substringFromIndex:range.location+range.length];
    }
    else
    {
        WTREpubParagraph *parag=[[WTREpubParagraph alloc]init];
        parag.attrString=atrstr;
        parag.frame=CGRectMake(contenti.left,lastbottom, bw, size.height);
        parag.bottomBlankHeight=[WTREpubConfig shareInstance].contentFont.pointSize/2;
        parag.type=0;
        parag.Paragtype=WTREpubParagContent;
        [page.paragraphArray addObject:parag];
    }
    return nil;
}
-(void)addImageWithPath:(NSString *)imagePath
{
    if (self.pageArray.count<=0) {
        [self addblankpage];
    }
    WTREpubPage *page=[self.pageArray lastObject];
    WTREpubParagraph *lastparag;
    if (page) {
        lastparag=[[page paragraphArray] lastObject];
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:imagePath]) {
        UIImage *image=[UIImage imageWithContentsOfFile:imagePath];
        if (image) {
            
            UIEdgeInsets contenti=[WTREpubConfig shareInstance].contentEdgeInsets;
            UIEdgeInsets imageEdgeInsets=[WTREpubConfig shareInstance].imageEdgeInsets;
            
            CGFloat bw=ScreenWidth-contenti.left-contenti.right;
            CGFloat bh=ScreenHeight-contenti.top-contenti.bottom;
            
            CGFloat lastbottom=(lastparag)?(lastparag.frame.origin.y+lastparag.frame.size.height+lastparag.bottomBlankHeight):contenti.top;
            
            CGFloat bbw=bw-imageEdgeInsets.left-imageEdgeInsets.right;
            CGFloat bbh=ScreenHeight-contenti.bottom-lastbottom-imageEdgeInsets.top-imageEdgeInsets.bottom;
            
            CGSize imsize=image.size;
            CGFloat imbili=imsize.width/imsize.height;
            CGFloat nbili=bbw/bbh;
            
            CGFloat maxw;
            CGFloat maxh;
            
            CGRect imrect;
            
            if (bbh>30) {
                if (imbili>nbili) {
                    maxw=bbw;
                    if (imsize.width<bbw) {
                        maxw=imsize.width;
                    }
                    maxh=maxw/imbili;
                    
                    imrect=CGRectMake((ScreenWidth-maxw)/2.0, lastbottom+imageEdgeInsets.top, maxw, maxh);
                    
                }else
                {
                    BOOL isneedadd=YES;
                    
                    maxh=bbh;
                    if (imsize.height<maxh) {
                        maxh=imsize.height;
                        isneedadd=NO;
                    }
                    maxw=maxh*imbili;
                    
                    if (isneedadd&&maxw<bbw*0.4) {
                        [self addblankpage];
                        page=[self.pageArray lastObject];
                        lastparag=[[page paragraphArray] lastObject];
                        
                        bbh=bh-imageEdgeInsets.top-imageEdgeInsets.bottom;
                        nbili=bbw/bbh;
                        
                        if (imbili>nbili) {
                            maxw=bbw;
                            if (imsize.width<bbw) {
                                maxw=imsize.width;
                            }
                            maxh=maxw/imbili;
                            
                            imrect=CGRectMake((ScreenWidth-maxw)/2.0,contenti.top+imageEdgeInsets.top, maxw, maxh);
                            
                        }else
                        {
                            maxh=bbh;
                            if (imsize.height<maxh) {
                                maxh=imsize.height;
                            }
                            maxw=maxh*imbili;
                            imrect=CGRectMake((ScreenWidth-maxw)/2.0,contenti.top+imageEdgeInsets.top, maxw, maxh);
                        }

                    }
                    else
                    {
                        imrect=CGRectMake((ScreenWidth-maxw)/2.0, lastbottom+imageEdgeInsets.top, maxw, maxh);
                    }
                }
            }
            else
            {
                [self addblankpage];
                page=[self.pageArray lastObject];
                lastparag=[[page paragraphArray] lastObject];
                
                bbh=bh-imageEdgeInsets.top-imageEdgeInsets.bottom;
                nbili=bbw/bbh;
                
                if (imbili>nbili) {
                    maxw=bbw;
                    if (imsize.width<bbw) {
                        maxw=imsize.width;
                    }
                    maxh=maxw/imbili;
                    
                    imrect=CGRectMake((ScreenWidth-maxw)/2.0,contenti.top+imageEdgeInsets.top, maxw, maxh);
                    
                }else
                {
                    maxh=bbh;
                    if (imsize.height<maxh) {
                        maxh=imsize.height;
                    }
                    maxw=maxh*imbili;
                    imrect=CGRectMake((ScreenWidth-maxw)/2.0,contenti.top+imageEdgeInsets.top, maxw, maxh);
                }
            }
            
            WTREpubParagraph *parag=[[WTREpubParagraph alloc]init];
            parag.image=image;
            parag.frame=imrect;
            parag.bottomBlankHeight=[WTREpubConfig shareInstance].imageEdgeInsets.bottom;
            parag.Paragtype=WTREpubParagImage;
            [page.paragraphArray addObject:parag];
        }
    }
}
-(void)addImageTitleWithString:(NSString *)string
{
    if (self.pageArray.count<=0) {
        [self addblankpage];
    }
    WTREpubPage *page=[self.pageArray lastObject];
    WTREpubParagraph *lastparag=[[page paragraphArray] lastObject];
    
    NSAttributedString *atrstr=[[NSAttributedString alloc] initWithString:string attributes:[WTREpubConfig AttributeImageTitle]];
    
    UIEdgeInsets contenti=[WTREpubConfig shareInstance].contentEdgeInsets;
    
    CGFloat bw=ScreenWidth-contenti.left-contenti.right;
    CGFloat bh=ScreenHeight-contenti.top-contenti.bottom;
    
    CGSize size=[atrstr boundingRectWithSize:CGSizeMake(bw, 4000) options:NSStringDrawingUsesFontLeading|NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    
    CGFloat lastbottom=(lastparag)?(lastparag.frame.origin.y+lastparag.frame.size.height+lastparag.bottomBlankHeight):contenti.top;
    
    if (lastbottom+size.height>bh) {
        [self addblankpage];
        page=[self.pageArray lastObject];
        lastparag=[[page paragraphArray] lastObject];
    }
    
    WTREpubParagraph *parag=[[WTREpubParagraph alloc]init];
    parag.attrString=atrstr;
    parag.frame=CGRectMake(contenti.left,(lastparag)?lastbottom:contenti.top,bw, size.height);
    parag.bottomBlankHeight=[WTREpubConfig shareInstance].imageTitlelineSpace*1.5;
    parag.type=0;
    parag.Paragtype=WTREpubParagImageTitle;
    [page.paragraphArray addObject:parag];
}

@end
