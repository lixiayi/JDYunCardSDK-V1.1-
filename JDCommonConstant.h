//
//  JDCommonConstant.h
//  JDYunCardSDK
//
//  Created by xiaoyi li on 16/9/21.
//  Copyright © 2016年 xiaoyi li. All rights reserved.
//

/**
 * 常量相关定义
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface JDCommonConstant : NSObject

/// API的系统版本号
UIKIT_EXTERN NSString *const JD_YUN_CARD_SDK_VER;

/// 服务器地址
UIKIT_EXTERN NSString *const SERVER_URL;

/// PKCS#10请求内容
UIKIT_EXTERN NSString *const CERT_REQUEST;

/// PKCS#10请求内容头部
UIKIT_EXTERN NSString *const CERT_REQUEST_HEADER;

/// PKCS#10请求内容尾部
UIKIT_EXTERN NSString *const CERT_REQUEST_FOOTER;

@end
