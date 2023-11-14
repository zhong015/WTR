//
//  WTROCR.h
//  CnkiIPhoneClient
//
//  Created by wfz on 2023/10/8.
//  Copyright © 2023 net.cnki.www. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WTROCR : NSObject

+(void)ocrimage:(UIImage *)image retcb:(void (^)(NSString *retStr))retcb;

@end

NS_ASSUME_NONNULL_END
