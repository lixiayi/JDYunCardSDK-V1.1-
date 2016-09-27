//
//  JDUtils.h
//  JDYunCardSDK
//
//  Created by xiaoyi li on 16/9/21.
//  Copyright © 2016年 xiaoyi li. All rights reserved.
//

/**
 * 基础工具类
 */

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

@interface JDUtils : NSObject

/**
 * 获取API的版本号
 */

+ (NSString *)JDYunSDKVerson;

/**
 * 获取当前时间
 * 格式:yyyy-MM-dd HH:mm:ss
 */

+ (NSString *)getCurrentTime;

/**
 获取一个随机时间

 @return 时间的字符串
 */

+(NSString *)getTimeAndRandom;


/**
 获取包含年月日的短时间格式的日期字符串

 @return 获取短日期字符串
 */

+(NSString *)getShortCurrentTime;

/**
 获取当前时间后的指定间隔的时间

 @param seconds 以秒为单位的数量

 @return 返回指定间隔的时间字符串
 */

+(NSString*)getShortCurrentTimeIntervalSinceNow:(NSTimeInterval)seconds;

/**
 获取时间戳

 @return 返回13为的时间戳，13位
 */

+ (NSString *)getTimeInterval;



/**
 获取星期信息

 @return 星期信息
 */

+ (NSString *)getWeek;

/**
 判断字符串是否为空

 @param str 待判断的字符串

 @return 是否为空
 */

+ (BOOL)isEmptyStr:(NSString *)str;


/**
 把汉字转成拼音

 @param hanziText 待转换的字符串

 @return 转换后的字符串
 */

+ (NSString *)hanziToPinyin:(NSString *)hanziText;


/**
 根据ID获取证件名称

 @param certId 证件ID

 @return 证件名称
 */

+ (NSString *)getCertNameByID:(NSString *)certId;

NS_ASSUME_NONNULL_END

@end


