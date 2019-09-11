//
//  WTREpubHeaderView.m
//  WTREpubReader
//
//  Created by wfz on 2017/3/21.
//  Copyright © 2017年 wfz. All rights reserved.
//

#import "WTREpubHeaderView.h"
#import <AVFoundation/AVFoundation.h>
//#import "WTRTextSpeaker.h"
#import "WTREpubViewController.h"

@implementation WTREpubHeaderView
{
//    CGFloat HeaderBUWidth;

//    BOOL isconfigSession;
//    UIButton *rightonebu;

//    int lsstate,curintReadingpage;// lsstate: 0 准备状态  1播放一次状态  2自动播放状态

//    BOOL isplaying;

    NSArray *namearr;
    
}
-(id)initWithFrame:(CGRect)frame
{
    self=[super initWithFrame:frame];
    if (self) {
//        lsstate=0;

        [self initui];
        
//        isconfigSession=NO;
    }
    return self;
}
-(void)dealloc
{
//    if (isconfigSession) {
//        [[WTRTextSpeaker shareInstence] removeAudioSession];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
//        });
//    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
//-(void)RouteChangeNotificationNoti:(NSNotification *)noti
//{
//
//    NSNumber *changereason=[noti.userInfo objectForKey:AVAudioSessionRouteChangeReasonKey];
//    if (changereason.intValue==AVAudioSessionRouteChangeReasonOldDeviceUnavailable) {
//        AVAudioSessionRouteDescription *descr=[noti.userInfo objectForKey:AVAudioSessionRouteChangePreviousRouteKey];
//
//        for (AVAudioSessionPortDescription *portdes in descr.outputs) {
//            if ([portdes.portType isEqualToString:AVAudioSessionPortHeadphones]||[portdes.portType isEqualToString:AVAudioSessionPortHDMI]||[portdes.portType isEqualToString:AVAudioSessionPortAirPlay]||[portdes.portType isEqualToString:AVAudioSessionPortCarAudio]||[portdes.portType isEqualToString:AVAudioSessionPortBluetoothHFP]||[portdes.portType isEqualToString:AVAudioSessionPortUSBAudio]||[portdes.portType isEqualToString:AVAudioSessionPortBluetoothLE]||[portdes.portType isEqualToString:AVAudioSessionPortBluetoothA2DP]) {
//                [[WTRTextSpeaker shareInstence] pause];
//                return;
//            }
//        }
//    }
//}
//-(void)InterruptionNoti:(NSNotification *)noti
//{
//    if ([UIDevice currentDevice].systemVersion.floatValue>=10.3) {
//        NSString *WasSuspendedKey=[noti.userInfo objectForKey:AVAudioSessionInterruptionWasSuspendedKey];
//        if (WasSuspendedKey&&WasSuspendedKey.boolValue==YES) {
//            return;
//        }
//    }
//    [[WTRTextSpeaker shareInstence] pause];
//}

-(void)initui
{
//    HeaderBUWidth=44;

//    rightonebu=[UIButton new];
//    rightonebu.frame=CGRectMake(self.width-20-HeaderBUWidth, self.height-HeaderBUWidth, HeaderBUWidth, HeaderBUWidth);
//    [rightonebu setImage:[UIImage imageNamed:@"lstxtSetim"] forState:UIControlStateNormal];
//    rightonebu.imageEdgeInsets=UIEdgeInsetsMake(5, 15/2.0, 10, 15/2.0);
//    [self addSubview:rightonebu];
//
//    rightonebu.autoresizingMask=UIViewAutoresizingFlexibleLeftMargin;
//    [rightonebu addTarget:self action:@selector(setbuClick) forControlEvents:UIControlEventTouchUpInside];
//
//    rightonebu=[UIButton new];
//    rightonebu.frame=CGRectMake(self.width-20-10-HeaderBUWidth*2, self.height-HeaderBUWidth, HeaderBUWidth, HeaderBUWidth);
//    [rightonebu setImage:[UIImage imageNamed:@"lstxtone"] forState:UIControlStateNormal];
//    rightonebu.imageEdgeInsets=UIEdgeInsetsMake(5, 15/2.0, 10, 15/2.0);
//    [self addSubview:rightonebu];
//
//    rightonebu.autoresizingMask=UIViewAutoresizingFlexibleLeftMargin;
//    [rightonebu addTarget:self action:@selector(lsbuClick) forControlEvents:UIControlEventTouchUpInside];

}
//-(void)lsbuClick
//{
//    if (!isconfigSession) {
//        isconfigSession=YES;
//
//        [[ShareSetingView shareInstence] configSpeaker];
//
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
//            [self.epubViewController becomeFirstResponder];
//        });
//
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(InterruptionNoti:) name:AVAudioSessionInterruptionNotification object:nil];
//
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(RouteChangeNotificationNoti:) name:AVAudioSessionRouteChangeNotification object:nil];
//
//        __WEAKSelf
//        [WTRTextSpeaker shareInstence].retStateCb=^(int SpeakType){
//
//            [weakSelf updataSpeakState:SpeakType];
//        };
//    }
//
//    if (lsstate==0) {
////        lsstate=1;
////        isplaying=NO;
////        curintReadingpage=0;
////        [SVProgressHUD showSuccessWithStatus:@"朗读本页"];
//
//        [rightonebu setImage:[UIImage imageNamed:@"lstxtauto"] forState:UIControlStateNormal];
//        lsstate=2;
//        [SVProgressHUD showSuccessWithStatus:@"自动朗读（自动翻页模式）"];
//
//    }else if (lsstate==1)
//    {
//        [rightonebu setImage:[UIImage imageNamed:@"lstxtauto"] forState:UIControlStateNormal];
//        lsstate=2;
//        [SVProgressHUD showSuccessWithStatus:@"自动朗读（自动翻页模式）"];
//    }else if (lsstate==2)
//    {
//        [rightonebu setImage:[UIImage imageNamed:@"lstxtone"] forState:UIControlStateNormal];
//        lsstate=0;
//        [[WTRTextSpeaker shareInstence] stop];
//        [SVProgressHUD showSuccessWithStatus:@"停止朗读"];
//        return;
//    }
//    [self startSpeakCurintpage];
//}

//#pragma mark 播放状态改变
//-(void)updataSpeakState:(int)SpeakType
//{
//    /* 1:didStartSpeech
//     2:didFinishSpeech
//     3:didPauseSpeech
//     4:didContinueSpeech
//     5:didCancelSpeech*/
//    switch (SpeakType) {
//        case 1:
//        {
//            isplaying=YES;
//            if (lsstate==0) {
//                lsstate=1;
//            }
//        }
//            break;
//        case 2:
//        {
//            if (lsstate==2) {
//                WTREpubViewController *epubvc=(WTREpubViewController *)self.epubViewController;
//                [epubvc jumpnextpage];
//            }
//        }
//        case 5:
//        {
//            isplaying=NO;
//            if (lsstate==1) {
//                lsstate=0;
//            }
//        }
//            break;
//        default:
//            break;
//    }
//}
//-(void)startSpeakCurintpageifneed
//{
//    if (lsstate==2) {
//        [self startSpeakCurintpage];
//    }
//}
//-(void)startSpeakCurintpage
//{
//    if (lsstate>0) {
//
//        WTREpubViewController *epubvc=(WTREpubViewController *)self.epubViewController;
//
//        WTREpubHtmlFile *curinthtmlf=[epubvc.htmlArray objectAtIndex:epubvc.curintRedinghtmlIndex];
//
//        WTREpubPage *curintpage=[curinthtmlf.pageArray objectAtIndex:epubvc.curintRedingPage];
//
//        WTREpubParagraph *lastparg=nil;
//        NSMutableString *mustr=[NSMutableString string];
//        for (int i=0; i<curintpage.paragraphArray.count; i++) {
//            WTREpubParagraph *para=[curintpage.paragraphArray objectAtIndex:i];
//            lastparg=para;
//
//            if (i==0&&para.Paragtype==WTREpubParagContent&&para.attrString) {
//                //找上一页页尾 是否多读了字符
//                if (epubvc.curintRedingPage-1>=0&&epubvc.curintRedingPage-1<curinthtmlf.pageArray.count) {
//                    WTREpubPage *lastpage=[curinthtmlf.pageArray objectAtIndex:epubvc.curintRedingPage-1];
//                    WTREpubParagraph *lastPagelastparg=[lastpage.paragraphArray lastObject];
//                    if (lastPagelastparg.Paragtype==WTREpubParagContent&&lastPagelastparg.attrString) {
//
//                        //找这一页段头信息
//                        NSDictionary *atrdic=[para.attrString attributesAtIndex:0 effectiveRange:nil];
//                        NSParagraphStyle *prasy=[atrdic objectForKey:NSParagraphStyleAttributeName];
//                        if (prasy.firstLineHeadIndent<0.1) {//页头
//                            NSString *fsstr=para.attrString.string;
//                            NSRange ra=[fsstr rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@".,;，。？?\":\n\t\r"]];
//                            if (ra.length>0) {
//                                fsstr=[fsstr substringFromIndex:ra.location];
//                                [mustr appendString:fsstr];
//                            }
//                            continue;
//                        }
//                    }
//                }
//            }
//
//            if (para.attrString) {
//                if (para.type==1) {
//                    NSString *visrange=[para.attrString.string substringWithRange:NSMakeRange(para.visibleRange.location, para.visibleRange.length)];
//                    [mustr appendString:visrange];
//                }
//                else
//                    [mustr appendString:para.attrString.string];
//            }
//        }
//
//        if (lastparg.type==1&&epubvc.curintRedingPage+1<curinthtmlf.pageArray.count) {
//            WTREpubPage *nextpage=[curinthtmlf.pageArray objectAtIndex:epubvc.curintRedingPage+1];
//            WTREpubParagraph *para=[nextpage.paragraphArray firstObject];
//
//            if (para.Paragtype==WTREpubParagContent&&para.attrString) {
//                NSDictionary *atrdic=[para.attrString attributesAtIndex:0 effectiveRange:nil];
//                NSParagraphStyle *prasy=[atrdic objectForKey:NSParagraphStyleAttributeName];
//                if (prasy.firstLineHeadIndent<0.1) {//下一页页头
//                    NSString *fsstr=para.attrString.string;
//                    NSRange ra=[fsstr rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@".,;，。？?\":\n\t\r"]];
//                    if (ra.length>0) {
//                        fsstr=[fsstr substringToIndex:ra.location];
//                    }
//                    [mustr appendString:fsstr];
//                }
//            }
//        }
//
//        if (mustr.length>0) {
//            [self speaksenTence:mustr];
//        }
//    }
//}
//-(void)speaksenTence:(NSString *)senTence
//{
//    NSArray *strarr=[WTRTextSpeaker fendaunwithContentStr:senTence];
//
//    NSMutableArray *muarr=[NSMutableArray array];
//    for (int i=0; i<strarr.count; i++) {
//        NSString *ssu=strarr[i];
//
//        if (ssu.length>0) {
////            if (!([ShareSetingData shareInstence].isjumpTszf&&[WTRTextSpeaker isallTeShuZifu:ssu])) {
//                ssu=[WTRTextSpeaker quchuhtmlzhuanyizifuzy:ssu];//因为没有跟随显示可以去短字符
//                [muarr addObject:@{@"text":ssu,@"tag":[NSNumber numberWithInt:i]}];
////            }
//        }
//    }
//    if (muarr.count>0) {
//        [[WTRTextSpeaker shareInstence] speakSentenceArray:muarr];
//    }
//}
//
//#pragma mark 设置
//-(void)setbuClick
//{
//    [[ShareSetingView shareInstence] showvOrDisMis];
//}


@end
