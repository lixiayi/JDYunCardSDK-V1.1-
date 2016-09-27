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


#pragma mark - 云卡用户注册

/**
 云卡用户注册

 @param userParams    应用参数
 @param registerBlock 注册后的回调
 */

- (void)YunCardUserRegister:(NSDictionary *)userParams registerBlock:(JDYunCardSDKRegisterBlock)registerBlock {
    NSURL *url = self.interfaceAddress;
    NSString *allParamStr = [self allParamStr:userParams interface:cloud_card_user_register];
    
    [self postRequestToServer:url paramStr:allParamStr block:^(NSData *data, NSError *error) {
        if (data) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            registerBlock(dict);
        } else {
            registerBlock(nil);
        }
    }];
}

#pragma mark - 云卡产品列表

/**
 云卡产品列表
 
 @param listBlock 产品列表的回调
 */

- (void)getCardList:(JDYunCardSDKProcutListBlock)listBlock {
    
}

#pragma mark - CA证书下发
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
// 把pkcs#10请求的字符串去掉头部，尾部后的内容
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
    allParams[@"sign"] = signStr;
    
    NSString *allParamStr = [api stringPairsFromDictionary:allParams];
    return allParamStr;
}

@end
