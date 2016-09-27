//
//  JDDevice.m
//  Test
//
//  Created by xiaoyi li on 16/9/26.
//  Copyright © 2016年 xiaoyi li. All rights reserved.
//

#import "JDDevice.h"
#import <sys/utsname.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

static JDDevice *instance = nil;

@implementation JDDevice

#pragma mark - 单例
/**
 单例构造器
 
 @return 单例
 */

+ (id)shareDevice {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}



#pragma mark - 获取设备唯一标识符
/**
 获取设备的唯一标识符
 
 @return UUID
 */

- (NSString *)UUIDString {
    return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
}

#pragma mark - 获取系统版本号

/**
 获取系统版本号（SDK版本号）
 
 @return 系统版本号
 */

- (NSString *)systemVerson{
    return [[UIDevice currentDevice] systemVersion] ;
}

#pragma mark - 手机厂商
/**
 手机厂商
 
 @return 返回Apple
 */
- (NSString *)manufacturer {
    return @"Apple";
}

#pragma mark - 获取手机型号
/**
 获取手机型号
 
 @return 手机型号
 */
- (NSString *)model{
    return [self deviceVersion];
}


- (NSString *)deviceVersion {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    //iPhone
    if ([deviceString isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([deviceString isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([deviceString isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([deviceString isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone3,2"])    return @"Verizon iPhone 4";
    if ([deviceString isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([deviceString isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    if ([deviceString isEqualToString:@"iPhone5,2"])    return @"iPhone 5";
    if ([deviceString isEqualToString:@"iPhone5,3"])    return @"iPhone 5C";
    if ([deviceString isEqualToString:@"iPhone5,4"])    return @"iPhone 5C";
    if ([deviceString isEqualToString:@"iPhone6,1"])    return @"iPhone 5S";
    if ([deviceString isEqualToString:@"iPhone6,2"])    return @"iPhone 5S";
    if ([deviceString isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([deviceString isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([deviceString isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    if ([deviceString isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    if ([deviceString isEqualToString:@"iPhone9,1"])    return @"iPhone 7";
    if ([deviceString isEqualToString:@"iPhone9,2"])    return @"iPhone 7 Plus";
    
    return deviceString;
}

#pragma mark - 获取运营商信息
/**
 获取运营商信息
 
 @return 运营商信息
 */
- (NSString *)carrierName {
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = info.subscriberCellularProvider;
    return carrier.carrierName;
}

/**
 获取网络类型
 
 @return 网络类型
 */
- (NSString *)network {
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = info.subscriberCellularProvider;
    return carrier.mobileNetworkCode;
}

@end
