//
//  WTRStreamDManager.h
//  WTRMusic
//
//  Created by wfz on 2020/11/17.
//  Copyright © 2020 wfz. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^WTRStreamDHeadRet)(NSString *tagstr,int64_t allLen,int64_t begin,int64_t end,NSDictionary *headdic);
typedef void (^WTRStreamDDataRet)(NSString *tagstr,NSData * cdata);
typedef void (^WTRStreamDCompletion)(NSString *tagstr, NSError * _Nullable error);

@interface WTRStreamDManager : NSObject

+(instancetype)shareInstence;

-(void)getStream:(NSURL *)url tagstr:(NSString *)tagstr begin:(int64_t)begin end:(int64_t)end headret:(WTRStreamDHeadRet)headret dataret:(WTRStreamDDataRet)dataret completion:(WTRStreamDCompletion)completion;

-(void)cancelTagstr:(NSString *)tagstr;

@end

NS_ASSUME_NONNULL_END
