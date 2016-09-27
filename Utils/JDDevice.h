//
//  JDDevice.h
//  Test
//
//  Created by xiaoyi li on 16/9/26.
//  Copyright © 2016年 xiaoyi li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface JDDevice : NSObject

/**
 单例构造器
 
 @return 单例
 */
+ (id)shareDevice;

/**
 获取设备的唯一标识符
 
 @return UUID
 */

- (NSString *)UUIDString;

/**
 获取系统版本号（SDK版本号）
 
 @return 系统版本号
 */
- (NSString *)systemVerson;

/**
 手机厂商
 
 @return 返回Apple
 */
- (NSString *)manufacturer;

/**
 获取手机型号
 
 @return 手机型号
 */
- (NSString *)model;

/**
 获取运营商信息
 
 @return 运营商信息
 */
- (NSString *)carrierName;

/**
 获取网络类型
 
 @return 网络类型
 */
- (NSString *)network;


@end
