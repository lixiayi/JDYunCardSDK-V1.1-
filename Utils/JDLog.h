//
//  JDLog.h
//  JDYunCardSDK
//
//  Created by xiaoyi li on 16/9/22.
//  Copyright © 2016年 xiaoyi li. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JDLog : NSObject

+ (void)file:(char *)sourceFile function:(char *)functionName lineNumber:(int)lineNumber format:(NSString *)format,...;
#define JDLog(args, ...) [JDLog file:__FILE__ function:(char *)__FUNCTION__ lineNumber:__LINE__ format:(args),##__VA_ARGS__]

@end
