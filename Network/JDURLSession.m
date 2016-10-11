//
//  JDURLSession.m
//  JDYunCardSDK
//
//  Created by xiaoyi li on 16/9/22.
//  Copyright © 2016年 xiaoyi li. All rights reserved.
//

#import "JDURLSession.h"

typedef void(^NSURLSessionFinishBlock)(NSData *data,NSError *error);

NS_ASSUME_NONNULL_BEGIN
@interface JDURLSession()

/**
 正在执行的请求
 */
@property (nonatomic, strong) NSMutableURLRequest *request;

/**
 正在执行的session
 */
@property (nonatomic, strong) NSURLSession *mainSession;

/**
 接口地址
 */
@property (nonatomic, strong) NSURL *interfaceAddress;


@end

NS_ASSUME_NONNULL_END

@implementation JDURLSession


#pragma mark - 构建请求管理器
/**
 单例
 
 @return 返回网络请求单例
 */

+ (JDURLSession *)Manager {
    static JDURLSession *mangaer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mangaer = [[JDURLSession alloc] initRequest];
    });
    return mangaer;
}

#pragma mark - 初始化请求

/**
 初始化请求

 @return 返回请求实例
 */

- (id)initRequest {
    self = [super init];
    if (self) {
        self.interfaceAddress = [NSURL URLWithString:SERVER_URL];
        self.request = [[NSMutableURLRequest alloc] init];
        [self.request setHTTPMethod:@"POST"];
        [self.request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [self.request setTimeoutInterval:60];
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        self.mainSession = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        
    }
    return self;
}

#pragma mark - POST请求数据

/**
 核心方法：POST请求数据

 @param url         服务器地址
 @param str         提交的数据
 @param finishBlock 提交完成后的回调
 */

- (void)postRequestToServer:(NSURL *)url paramStr:(NSString *)str block:(NSURLSessionFinishBlock)finishBlock {
    self.request.URL = url;
    self.request.HTTPBody = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSURLSessionDataTask *sessionDataTask = [self.mainSession dataTaskWithRequest:self.request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (finishBlock) {
            finishBlock(data,error);
        }
    }];
    
    [sessionDataTask resume];
}

#pragma mark - 取消请求
/**
 取消所有的请求
 */

- (void)cancelAllRequest {
    [self.mainSession invalidateAndCancel];
}

#pragma mark ****************************************帐户类接口****************************************
#pragma mark --云卡用户注册

/**
 云卡用户注册

 @param userParams    应用参数
 @param registerBlock 注册后的回调
 */

- (void)YunCardUserRegister:(NSDictionary *)userParams registerBlock:(JDYunCardSDKRegisterBlock)registerBlock {
    NSString *allUrl = [NSString stringWithFormat:@"%@",[self.interfaceAddress absoluteString]];
    
    NSURL *url = [NSURL URLWithString:allUrl];
    NSString *allParamStr = [self allParamStr:userParams interface:cloud_card_user_register];
    NSLog(@"请求的URL地址：%@?%@",allUrl,allParamStr);
    [self postRequestToServer:url paramStr:allParamStr block:^(NSData *data, NSError *error) {
        if (data) {
            NSString *respStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"接口返回S----->%@",respStr);
            NSData *base64DecodeData = [Base64 decodeData:data];
            zipAndUnzip *zipAnd = [[zipAndUnzip alloc] init];
            NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingISOLatin1);
            NSData *unzipData = [zipAnd gzipInflate:base64DecodeData];
            NSString *uString = [[NSString alloc] initWithData:unzipData encoding:enc];
            NSLog(@"调用接口:%@   解压后的字符串------>%@",@"cloud_card_user_register",uString);
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:unzipData options:NSJSONReadingAllowFragments error:&error];
            registerBlock(dict);
        } else {
            registerBlock(nil);
        }
    }];
}

#pragma mark -- 云卡开卡申请

/**
 云卡开卡申请
 
 @param userParams    用户级别的参数
 @param openAccountBlock 云卡开卡申请的回调
 */

- (void)YunCardOpenAccount:(NSDictionary *)userParams openAccountBlock:(JDYunCardSDKOpenAccountBlock)openAccountBlock {
    NSURL *url = self.interfaceAddress;
    NSString *allParams = [self allParamStr:userParams interface:cloud_card_open_account];
    
    [self postRequestToServer:url paramStr:allParams block:^(NSData *data, NSError *error) {
        if (data) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            openAccountBlock(dict);
        } else {
            openAccountBlock(nil);
        }
    }];
    
}


#pragma mark -- 云卡信息(文件)下载

/**
 云卡信息(文件)下载
 
 @param userParams    用户级别的参数
 @param downloadBlock 云卡信息下载回调
 */

- (void)YunCardDownload:(NSDictionary *)userParams downloadBlock:(JDYunCardSDKDownloadBlock)downloadBlock{
    NSURL *url = self.interfaceAddress;
    NSString *allParams = [self allParamStr:userParams interface:cloud_card_download];
    
    [self postRequestToServer:url paramStr:allParams block:^(NSData *data, NSError *error) {
        if (data) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            downloadBlock(dict);
        } else {
            downloadBlock(nil);
        }
    }];
}

#pragma mark -- 查询云卡（信息）列表

/**
 查询云卡（信息）列表
 
 @param userParams     用户级别的参数
 @param queryListBlock 云卡信息列表查询回调
 */

- (void)YunCardQueryList:(NSDictionary *)userParams queryListBlock:(JDYunCardSDKQueryListBlock)queryListBlock{
    NSURL *url = self.interfaceAddress;
    NSString *allParams = [self allParamStr:userParams interface:cloud_card_query_list];
    
    [self postRequestToServer:url paramStr:allParams block:^(NSData *data, NSError *error) {
        if (data) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            queryListBlock(dict);
        } else {
            queryListBlock(nil);
        }
    }];
}

#pragma mark -- 查询云卡详情

/**
 查询云卡详情
 
 @param userParams     用户级别的参数
 @param queryInfoBlock 查询云卡详情回调
 */

- (void)YunCardQueryInfo:(NSDictionary *)userParams queryInfoBlock:(JDYunCardSDKQueryInfoBlock)queryInfoBlock {
    NSURL *url = self.interfaceAddress;
    NSString *allParams = [self allParamStr:userParams interface:cloud_card_query_info];
    
    [self postRequestToServer:url paramStr:allParams block:^(NSData *data, NSError *error) {
        if (data) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            queryInfoBlock(dict);
        } else {
            queryInfoBlock(nil);
        }
    }];
}

#pragma mark -- 云卡注销

/**
 云卡注销
 
 @param userParams      用户级别的参数
 @param writtenOffBlock 云卡注销的回调
 */

- (void)YunCardWrittenOff:(NSDictionary *)userParams writenOffBlock:(JDYunCardWrittenOffBlock)writtenOffBlock {
    NSURL *url = self.interfaceAddress;
    NSString *allParams = [self allParamStr:userParams interface:cloud_card_written_off];
    
    [self postRequestToServer:url paramStr:allParams block:^(NSData *data, NSError *error) {
        if (data) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            writtenOffBlock(dict);
        } else {
            writtenOffBlock(nil);
        }
    }];
}

#pragma mark ****************************************交易类接口****************************************
#pragma mark -- 云卡充值
/**
 云卡充值
 
 @param userParams    用户级别的参数
 @param rechargeBlock 云卡充值后的回调
 */
- (void)YunCardAccountReharge:(NSDictionary *)userParams rechargeBlock:(JDYunCardRechargeBlock)rechargeBlock {
    NSURL *url = self.interfaceAddress;
    NSString *allParams = [self allParamStr:userParams interface:cloud_card_trans_account_recharge];
    
    [self postRequestToServer:url paramStr:allParams block:^(NSData *data, NSError *error) {
        if (data) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            rechargeBlock(dict);
        } else {
            rechargeBlock(nil);
        }
    }];
}

#pragma mark -- 云卡交易扣费

/**
 云卡交易扣费
 
 @param userParams        用户级别的参数
 @param transConsumeBlock 云卡交易扣费回调
 */

- (void)YunCardTransConsume:(NSDictionary *)userParams transConsumeBlock:(JDYunCardTransConsumeBlock)transConsumeBlock {
    NSURL *url = self.interfaceAddress;
    NSString *allParams = [self allParamStr:userParams interface:cloud_card_trans_cousume];
    
    [self postRequestToServer:url paramStr:allParams block:^(NSData *data, NSError *error) {
        if (data) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            transConsumeBlock(dict);
        } else {
            transConsumeBlock(nil);
        }
    }];
}

#pragma mark -- 消费记录查询

/**
 消费记录查询
 
 @param userParams       用户级别的参数
 @param transRecordBlock 交易记录查询回调
 */
- (void)YunCardTransRecord:(NSDictionary *)userParams transRecordBlock:(JDYunCardTransRecordBlock)transRecordBlock{
    NSURL *url = self.interfaceAddress;
    NSString *allParams = [self allParamStr:userParams interface:pic_cloud_transaction_recod_query];
    
    [self postRequestToServer:url paramStr:allParams block:^(NSData *data, NSError *error) {
        if (data) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            transRecordBlock(dict);
        } else {
            transRecordBlock(nil);
        }
    }];
}

#pragma mark ****************************************公共类接口****************************************
#pragma mark -- CA证书下发
/**
 CA证书下发
 
 @param userParams    用户级别的参数，此接口用户只须上送user_id
 @param downloadBlock CA证书下发回调
 */

- (void)YunCardCADownload:(NSDictionary *)userParams CADownloadBlock:(JDYunCardSDKCADownloadBlock)downloadBlock {
    NSURL *url = self.interfaceAddress;
    
    NSMutableDictionary *sdkParams = [NSMutableDictionary dictionaryWithCapacity:0];
    [sdkParams addEntriesFromDictionary:userParams];
    // SDK需要上送的参数
    NSString *certP10 = [self strippedRequestKey:CERT_REQUEST
                                          header:CERT_REQUEST_HEADER
                                          footer:CERT_REQUEST_FOOTER];
    [sdkParams setObject:certP10 forKey:@"cert_p10"];
    NSString *cert_object =@"CN=cn,OU=data,O=pci";
    [sdkParams setObject:cert_object forKey:@"cert_object"];
    
    NSString *allParamStr = [self allParamStr:sdkParams interface:cloud_card_ca_download];
    [self postRequestToServer:url paramStr:allParamStr block:^(NSData *data, NSError *error) {
        if (data) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            downloadBlock(dict);
        } else {
            downloadBlock(nil);
        }
    }];
}

#pragma mark -- 后台图片获取

/**
 后台图片获取
 
 @param userParams       用户级别的参数
 @param picDownloadBlock 后台图片获取回调
 */

- (void)YunCardPicDownload:(NSDictionary *)userParams picDownloadBlock:(JDYunCardSDKPicDownloadBlock)picDownloadBlock {
    NSURL *url = self.interfaceAddress;
    NSString *allParams = [self allParamStr:userParams interface:cloud_card_pic_download];
    
    [self postRequestToServer:url paramStr:allParams block:^(NSData *data, NSError *error) {
        if (data) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            picDownloadBlock(dict);
        } else {
            picDownloadBlock(nil);
        }
    }];
}

#pragma mark -- 云卡产品列表下载

/**
 云卡产品列表下载
 
 @param userParams 用户级别的参数
 @param typeBlock  云卡产品列表下载回调
 */

- (void)YunCardTypeDownload:(NSDictionary *)userParams typeDownloadBlock:(JDYunCardSDKTypeDownloadBlock)typeBlock {
    NSURL *url = self.interfaceAddress;
    NSString *allParams = [self allParamStr:userParams interface:cloud_card_type_download];
    
    [self postRequestToServer:url paramStr:allParams block:^(NSData *data, NSError *error) {
        if (data) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            typeBlock(dict);
        } else {
            typeBlock(nil);
        }
    }];
}

// 把pkcs#10请求的字符串去掉头部/尾部后的内容
- (NSString *)strippedRequestKey:(NSString *)requestKey header:(NSString *)header footer:(NSString *)footer {
    
    NSString *result = [[requestKey stringByReplacingOccurrencesOfString:header withString:@""] stringByReplacingOccurrencesOfString:footer withString:@""];
    
    return [[result stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""];
}

#pragma mark - private 获取请求参数字符串
- (NSString *)allParamStr:(NSDictionary *)userParams interface:(NSString *)interfaceName{
    JDAPI *api = [JDAPI shareAPI];
    api.api_name = interfaceName;

    NSMutableDictionary *allParams = [NSMutableDictionary dictionaryWithDictionary:userParams];
    NSDictionary *applicationDictionary = [api getSystemParams:api.api_name withToken:NO];
    [allParams addEntriesFromDictionary:applicationDictionary];
    NSString *signStr = [api getSign:allParams];
    if (!signStr || [signStr length] <= 0) {
        signStr = @"debug signStr";
    }
    NSLog(@"signStr------>%@",signStr);
    allParams[@"sign"] = signStr;
    
    NSString *allParamStr = [api stringPairsFromDictionary:allParams];
    return allParamStr;
}

@end
