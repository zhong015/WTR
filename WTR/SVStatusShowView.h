//
//  SVStatusShowView.h
//  WTRGitCs
//
//  Created by wfz on 2019/7/5.
//  Copyright © 2019 wfz. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SVStatusShowView : UIVisualEffectView

- (instancetype)initWithImage:(UIImage*)image status:(NSString*)status IsWhite:(BOOL)isw;

-(void)dismissWithAnimated:(NSNumber *)animatedNum;

@end

NS_ASSUME_NONNULL_END
