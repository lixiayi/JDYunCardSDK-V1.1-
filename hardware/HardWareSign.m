//
//  HardWareSign.m
//  JDYunCardSDK
//
//  Created by xiaoyi li on 16/10/8.
//  Copyright © 2016年 xiaoyi li. All rights reserved.
//

#import "HardWareSign.h"
#import "JDDevice.h"
#import "JDAPI.h"

@implementation HardWareSign

+ (NSString *)signHardward{
    NSString *signedStr = @"";
    
    NSString *IMEI = [[JDDevice shareDevice] UUIDString];
    NSString *VERSION_RELEASE  = [[JDDevice shareDevice] systemVerson];
    NSString *MANUFACTURER  = [[JDDevice shareDevice] manufacturer];
    NSString *CC_MODEL = [[JDDevice shareDevice] model];
    NSString *NETWORK_OPERATOR_NAME = [[JDDevice shareDevice] carrierName];
    NSString *NETWORK_TYPE = [[JDDevice shareDevice] network];
    
    NSDictionary *signDic = @{@"IMEI" : IMEI,
                              @"VERSION_RELEASE" : VERSION_RELEASE,
                              @"MANUFACTURER" : MANUFACTURER,
                              @"CC_MODEL" : CC_MODEL,
                              @"NETWORK_OPERATOR_NAME" : NETWORK_OPERATOR_NAME,
                              @"NETWORK_TYPE" : NETWORK_TYPE};
    
    NSMutableDictionary *hardDic = [NSMutableDictionary dictionaryWithDictionary:signDic];
    signedStr = [[JDAPI shareAPI] getSign:hardDic];
    
    return signedStr;
}

#pragma mark - 硬件信息签名
/**
 硬件信息签名，供第三方调用
 
 @param hardwareInfo 硬件信息，第三方上送的
 
 @return 签名后的字符串
 */

+ (NSString *)signHardwardInterface:(NSDictionary *)hardwareInfo {
    NSString *signedStr = @"";
    NSMutableDictionary *hardDic = [NSMutableDictionary dictionaryWithDictionary:hardwareInfo];
    signedStr = [[JDAPI shareAPI] getSign:hardDic];
    
    return signedStr;
}

@end
