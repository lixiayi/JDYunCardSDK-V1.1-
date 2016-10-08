 //
//  HardWareSign.h
//  JDYunCardSDK
//
//  Created by xiaoyi li on 16/10/8.
//  Copyright © 2016年 xiaoyi li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JDDevice.h"

@interface HardWareSign : NSObject

+ (NSString *)signHardward;


/**
 硬件信息签名，供第三方调用

 @param hardwareInfo 硬件信息，第三方上送的

 @return 签名后的字符串
 */

+ (NSString *)signHardwardInterface:(NSDictionary *)hardwareInfo;

@end
