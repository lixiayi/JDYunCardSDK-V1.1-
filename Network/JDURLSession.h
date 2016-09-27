//
//  JDURLSession.h
//  JDYunCardSDK
//
//  Created by xiaoyi li on 16/9/22.
//  Copyright © 2016年 xiaoyi li. All rights reserved.
//

/**
 *  核心数据请求的接口类，供第三方客户调用
 *  这个类不包含任何第三方网络请求库
 *  用户可以放心使用，不会跟自己项目的第三方库冲突
 */

#import <Foundation/Foundation.h>
#import "JDAPI.h"
#import "JDCommonConstant.h"
#import "APIConstant.h"

// 云卡用户注册回调
typedef void(^JDYunCardSDKRegisterBlock)(NSDictionary *dic);

// 云卡产品列表回调
typedef void(^JDYunCardSDKProcutListBlock)(NSArray *products);

// CA证书下发回调
typedef void(^JDYunCardSDKCADownloadBlock)(NSDictionary *dic);



@interface JDURLSession : NSObject<NSURLSessionDelegate>

/**
 单例

 @return 返回网络请求单例
 */

+ (JDURLSession *)Manager;


#pragma mark - 云卡用户注册

/**
 云卡用户注册

 @param userParams    用户级别的参数
 @param registerBlock 云卡用户注册后的回调
 */

- (void)YunCardUserRegister:(NSDictionary *)userParams registerBlock:(JDYunCardSDKRegisterBlock)registerBlock;

#pragma mark - 云卡产品列表
/**
 云卡产品列表

 @param listBlock 产品列表的回调
 */
- (void)getCardList:(JDYunCardSDKProcutListBlock)listBlock;


#pragma mark - CA证书下发
/**
 CA证书下发

 @param userParams    用户级别的参数，此接口用户只须上送user_id
 @param downloadBlock CA证书下发回调
 */

- (void)YunCardCADownload:(NSDictionary *)userParams CADownloadBlock:(JDYunCardSDKCADownloadBlock)downloadBlock;




@end
