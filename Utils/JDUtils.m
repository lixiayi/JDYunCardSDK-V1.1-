//
//  JDUtils.m
//  JDYunCardSDK
//
//  Created by xiaoyi li on 16/9/21.
//  Copyright © 2016年 xiaoyi li. All rights reserved.
//

#import "JDUtils.h"
#import "JDCommonConstant.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto//CommonCrypto.h>

@implementation JDUtils

/**
 * 获取API的版本号
 */


+ (NSString *)JDYunSDKVerson {
    return JD_YUN_CARD_SDK_VER;
}

/**
 * 获取当前时间
 * 格式:yyyy-MM-dd HH:mm:ss
 */

+ (NSString *)getCurrentTime{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSString *ret_str = [formatter stringFromDate:[NSDate date]];
    return ret_str;
}

/**
 获取一个随机时间
 
 @return 时间的字符串
 */

+ (NSString *)getTimeAndRandom{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    
    NSString *nowTime = [formatter stringFromDate:[NSDate date]];
    // 后面再加两位随机数
    NSInteger randomInt = 10 + arc4random() % 90;
    NSString *randomStr = [NSString stringWithFormat:@"%d",randomInt];
    // 返回时间和随机数的组合
    NSMutableString *resStr = [NSMutableString stringWithFormat:@"%@%@",nowTime,randomStr];
    return resStr;
}

/**
 获取yyyyMMdd格式的短时间格式的日期字符串
 
 @return 获取短日期字符串
 */

+ (NSString *)getShortCurrentTime {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMdd";
    NSString *ret_str = [formatter stringFromDate:[NSDate date]];
    return ret_str;
}

/**
 根据当前时间的指定间隔返回时间字符串
 
 @param seconds 以秒为单位的数量
 
 @return 返回指定间隔的时间字符串
 */

+ (NSString*)getShortCurrentTimeIntervalSinceNow:(NSTimeInterval)seconds {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *ret_str = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:seconds]];
    return ret_str;
}

/**
 获取时间戳
 
 @return 返回13为的时间戳，13位的字符串(*1000主要是和别的系统语言一致)
 */

+ (NSString *)getTimeInterval{
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval interval = [date timeIntervalSince1970] * 1000;
    NSString *timeString = [NSString stringWithFormat:@"%.0f", interval];
    return timeString;
}

/**
 获取星期信息
 1 －－星期天
 2－－星期一
 3－－星期二
 4－－星期三
 5－－星期四
 6－－星期五
 7－－星期六
 @return 星期信息
 */

+ (NSString *)getWeek {
    NSCalendar *calender = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    
    NSInteger unitFlag = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitWeekday | NSCalendarUnitDay |
        NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDate *row = [NSDate date];
    components = [calender components:unitFlag fromDate:row];
    NSInteger week = [components weekday];
    
    return [NSString stringWithFormat:@"%ld",(long)week];
}

/**
 判断字符串是否为空
 
 @param str 待判断的字符串
 
 @return 是否为空
 */

+ (BOOL)isEmptyStr:(nonnull NSString *)str {
    if ([str isEqualToString:@""]) {
        return YES;
    }
    
    if (str == nil || str == NULL) {
        return YES;
    }
    
    if ([str isKindOfClass:[NSNull class]]) {
        return YES;
    }
    
    NSCharacterSet *characterSet = [NSCharacterSet whitespaceCharacterSet];
    if ([[str stringByTrimmingCharactersInSet:characterSet] length] == 0) {
        return YES;
    }
    
    return NO;
}

/**
 把汉字转成拼音
 
 @param hanziText 待转换的字符串
 
 @return 转换后的字符串
 */

+ (NSString *)hanziToPinyin:(NSString *)hanziText {
    NSString *ret = @"";
    if ([hanziText length]) {
        CFMutableStringRef chineseMutableStringRef = CFStringCreateMutableCopy(NULL, 0, (CFStringRef)hanziText);
        CFStringTransform(chineseMutableStringRef, NULL, kCFStringTransformMandarinLatin, NO);
        CFStringTransform(chineseMutableStringRef, NULL, kCFStringTransformStripDiacritics, NO);
        ret = (__bridge NSString *)(chineseMutableStringRef);
    }
    return ret;
}

/**
 根据ID获取证件名称
 
 @param certId 证件ID
 
 @return 证件名称
 */

+ (NSString *)getCertNameByID:(NSString *)certId {
    NSString *certName = @"";
    if ([certId length] == 0) {
        certName = NSLocalizedString(@"身份证", @"");
    } else if ([@"00" isEqualToString:certId]) {
        certName = NSLocalizedString(@"身份证", @"");
    } else if ([@"01" isEqualToString:certId]) {
        certName = NSLocalizedString(@"军官证", @"");
    } else if ([@"02" isEqualToString:certId]) {
        certName = NSLocalizedString(@"护照", @"");
    } else if ([@"03" isEqualToString:certId]) {
        certName = NSLocalizedString(@"入境证", @"");
    } else if ([@"04" isEqualToString:certId]) {
        certName = NSLocalizedString(@"临时身份证", @"");
    } else if ([@"05" isEqualToString:certId]) {
        certName = NSLocalizedString(@"营业执照", @"");
    } else if ([@"06" isEqualToString:certId]) {
        certName = NSLocalizedString(@"组织机构代码证", @"");
    } else if ([@"08" isEqualToString:certId]) {
        certName = NSLocalizedString(@"回乡证", @"");
    } else if ([@"09" isEqualToString:certId]) {
        certName = NSLocalizedString(@"台胞证", @"");
    } else if ([@"10" isEqualToString:certId]) {
        certName = NSLocalizedString(@"驾驶证", @"");
    } else if ([@"99" isEqualToString:certId]) {
        certName = NSLocalizedString(@"其它", @"");
    }
    return certName;
}

@end
