//
//  WTRVideoCut.m
//  LivePhoto
//
//  Created by wfz on 2017/5/3.
//  Copyright © 2017年 wfz. All rights reserved.
//

#import "WTRVideoCut.h"
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import "WTRBaseDefine.h"

@implementation WTRVideoCut


+(void)cutVideoWithPath:(NSString *)movPath outputPath:(NSString *)outputpath start:(float)start duration:(float)duration Completion:(void (^)(BOOL iss))cb;
{
    AVAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:movPath] options:nil];
    // Load the values of AVAsset keys to inspect subsequently
    NSArray *assetKeysToLoadAndTest = @[@"preferredTransform", @"composable", @"tracks", @"duration"];
    
    // Tells the asset to load the values of any of the specified keys that are not already loaded.
    [asset loadValuesAsynchronouslyForKeys:assetKeysToLoadAndTest completionHandler:
     ^{
         for (NSString *key in assetKeysToLoadAndTest) {
             NSError *error = nil;
             
             if ([asset statusOfValueForKey:key error:&error] == AVKeyValueStatusFailed) {
                 NSLog(@"%@",error);
                 return;
             }
         }
         
         if (![asset isComposable]) {
             // Asset cannot be used to create a composition (e.g. it may have protected content).
             NSLog(@"该文件不能合成");
             return;
         }
         
         //视频轨道
         AVAssetTrack *videoAssetTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
         //音轨
         AVAssetTrack *audioAssetTrack=[[asset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
         
         AVMutableComposition* mixComposition = [AVMutableComposition composition];
         
         AVMutableCompositionTrack *compositionCommentaryTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
         
         [compositionCommentaryTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)
                                             ofTrack:audioAssetTrack
                                              atTime:kCMTimeZero error:nil];
         
         AVMutableCompositionTrack *compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
         
         [compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)
                                        ofTrack:videoAssetTrack
                                         atTime:kCMTimeZero error:nil];
         
         NSLog(@"videoAssetTrack.preferredTransform:%@",NSStringFromCGAffineTransform(videoAssetTrack.preferredTransform));
         
         compositionVideoTrack.preferredTransform=CGAffineTransformIdentity;
         
         AVAssetExportSession * exportSession = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
         
         CMTime movduration=asset.duration;
         
         //开始时间
         CMTime startCmt = movduration;
         startCmt.value=movduration.value*start;
         
         //剪切时间长
         CMTime durationCmt = movduration;
         durationCmt.value=movduration.value*duration;
         
         exportSession.timeRange = CMTimeRangeMake(startCmt, durationCmt);
         
         [[NSFileManager defaultManager] removeItemAtPath:outputpath error:nil];
         
         exportSession.outputURL = [NSURL fileURLWithPath:outputpath];
         
         exportSession.outputFileType = AVFileTypeMPEG4;
         
         
         //视频处理 旋转 透明度变换 一般用于视频衔接 (也用于如果 videoAssetTrack 视频轨道翻转了 纠正过来)
         exportSession.videoComposition=[self MutableVideoCompositionWith:videoAssetTrack mixComposition:mixComposition];
         
         [exportSession exportAsynchronouslyWithCompletionHandler:^(void)
          {
              BOOL copyOK=NO;
              switch (exportSession.status)
              {
                  case AVAssetExportSessionStatusUnknown:
                      
                      break;
                      
                  case AVAssetExportSessionStatusWaiting:
                      
                      break;
                      
                  case AVAssetExportSessionStatusExporting:
                      NSLog(@"------视频ok-----expotring");
                      copyOK=YES;
                      
                      break;
                      
                  case AVAssetExportSessionStatusCompleted:
                      
                      NSLog(@"------视频ok");
                      copyOK=YES;
                      
                      break;
                      
                  case AVAssetExportSessionStatusFailed:
                      
                      NSLog(@"Export failed: %@", [[exportSession error] localizedDescription]);
                      
                      break;
                      
                  case AVAssetExportSessionStatusCancelled:
                      
                      break;
                      
                  default:
                      
                      break;
                      
              }
              if (cb) {
                  dispatch_async(dispatch_get_main_queue(), ^{
                      if (copyOK) {
                          cb(YES);
                      }else
                      {
                          cb(NO);
                      }
                  });
              }
          }];
     }];
}
//AVMutableVideoComposition:视频处理 旋转 透明度变换 一般用于视频衔接 (也用于如果 videoAssetTrack 视频轨道翻转了 纠正过来)
+(AVMutableVideoComposition *)MutableVideoCompositionWith:(AVAssetTrack *)videoAssetTrack mixComposition:(AVMutableComposition *)mixComposition
{
    NSLog(@"%@,%@",NSStringFromCGSize(mixComposition.naturalSize),NSStringFromCGSize(videoAssetTrack.naturalSize));
    
    AVMutableVideoComposition *mutableVideoComposition = [AVMutableVideoComposition videoComposition];
    mutableVideoComposition.frameDuration = CMTimeMake(1, 30); // 30 fps
   
    AVMutableVideoCompositionInstruction *passThroughInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    
    CMTime duration=[mixComposition duration];
    NSLog(@"%lld",duration.value);
    passThroughInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, duration);
    
    AVAssetTrack *videoTrack = [mixComposition tracksWithMediaType:AVMediaTypeVideo][0];
    AVMutableVideoCompositionLayerInstruction *passThroughLayer = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];

    
    /*
     [0, 1, -1, 0, 720, 0] 竖 ok
     [-1, 0, 0, -1, 1280, 720] 右横 ok
     [1, 0, 0, 1, 0, 0] 左横 ok
     [0, -1, 1, 0, 0, 1280] 倒
     */
    
    CGAffineTransform newTransform=CGAffineTransformIdentity;
    mutableVideoComposition.renderSize = videoAssetTrack.naturalSize;
    
    if (videoAssetTrack.preferredTransform.a==-1) {
        
        newTransform = CGAffineTransformMake(videoAssetTrack.preferredTransform.a, videoAssetTrack.preferredTransform.b, videoAssetTrack.preferredTransform.c, videoAssetTrack.preferredTransform.d, videoAssetTrack.naturalSize.width, videoAssetTrack.naturalSize.height);
        
    }else if (videoAssetTrack.preferredTransform.c==-1){
        mutableVideoComposition.renderSize = CGSizeMake(videoAssetTrack.naturalSize.height, videoAssetTrack.naturalSize.width);
        
        newTransform = CGAffineTransformMake(videoAssetTrack.preferredTransform.a, videoAssetTrack.preferredTransform.b, videoAssetTrack.preferredTransform.c, videoAssetTrack.preferredTransform.d, videoAssetTrack.naturalSize.height, 0);
        
    }else if (videoAssetTrack.preferredTransform.c==1){
        
        mutableVideoComposition.renderSize = CGSizeMake(videoAssetTrack.naturalSize.height, videoAssetTrack.naturalSize.width);
        
        newTransform = CGAffineTransformMake(videoAssetTrack.preferredTransform.a, videoAssetTrack.preferredTransform.b, videoAssetTrack.preferredTransform.c, videoAssetTrack.preferredTransform.d, 0, videoAssetTrack.naturalSize.width);
    }

    [passThroughLayer setTransform:newTransform atTime:kCMTimeZero];
    
    passThroughInstruction.layerInstructions = @[passThroughLayer];
    mutableVideoComposition.instructions = @[passThroughInstruction];
    
//    mutableVideoComposition.animationTool=[self animationToolWithVideoComposition:mutableVideoComposition];
    
    return mutableVideoComposition;
}

//加水印 或者动画
+(AVVideoCompositionCoreAnimationTool *)animationToolWithVideoComposition:(AVMutableVideoComposition *)mutableVideoComposition
{
    CALayer *parentLayer = [CALayer layer];
    CALayer *videoLayer = [CALayer layer];
    
    parentLayer.frame = CGRectMake(0, 0, mutableVideoComposition.renderSize.width,mutableVideoComposition.renderSize.height);
    videoLayer.frame=parentLayer.bounds;
    
    [parentLayer addSublayer:videoLayer];
    
    CATextLayer *titleLayer = [CATextLayer layer];
    titleLayer.string = @"LiveToGif";
    titleLayer.foregroundColor = [[UIColor whiteColor] CGColor];
    titleLayer.shadowOpacity = 0.5;
    titleLayer.alignmentMode = kCAAlignmentCenter;
    titleLayer.bounds=CGRectMake(0, 0, 200, 200);
    
    titleLayer.position = CGPointMake(parentLayer.bounds.size.width-titleLayer.frame.size.width/2.0,titleLayer.frame.size.height/2.0);
    [parentLayer addSublayer:titleLayer];
    
    CABasicAnimation *animation=[CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
    
    animation.fromValue=[NSNumber numberWithFloat:0];
    animation.toValue=[NSNumber numberWithFloat:-150];
    animation.repeatCount=1;
    animation.autoreverses=YES;
    animation.removedOnCompletion=YES;
    animation.fillMode=kCAFillModeForwards;
    animation.beginTime = AVCoreAnimationBeginTimeAtZero;
    animation.duration=1;
    
    [titleLayer addAnimation:animation forKey:@"asd"];
    
    return [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
}

/*
 修改多媒体文件说明信息
 AVURLAsset *asset=[AVURLAsset URLAssetWithURL:url options:nil];
 
 sestion=[AVAssetExportSession exportSessionWithAsset:asset presetName:AVAssetExportPresetHighestQuality];

 sestion.outputURL = [NSURL fileURLWithPath:[[url.path stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"asd.m4a"]];
 
 AVMutableMetadataItem *item=[AVMutableMetadataItem metadataItem];
 item.keySpace=AVMetadataKeySpaceCommon;
 item.key=AVMetadataCommonKeyTitle; //修改标题
 item.value=@"哈哈哈222";
 sestion.metadata=@[item];
 [sestion exportAsynchronouslyWithCompletionHandler:^{
     NSLog(@"完成");
 }];
 
 */
@end
