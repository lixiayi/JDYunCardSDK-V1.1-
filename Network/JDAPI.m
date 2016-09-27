//
//  JDAPI.m
//  MetroInterfaceDemo
//
//  Created by xiaoyi li on 16/8/25.
//  Copyright © 2016年 xiaoyi li. All rights reserved.
//

#import "JDAPI.h"
#import "URLCode.h"
#import "APIConstant.h"
#import "MD5.h"
#import "JDCommonConstant.h"
#import "JDUtils.h"
#import "RSA.h"


static JDAPI *jd_api = nil;

@implementation JDAPI

#pragma mark - 单例
+ (id)shareAPI {
    dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        jd_api = [[self alloc] init];
    });
    return jd_api;
}

#pragma mark- 生成数字签名(根据规则来定，如果是RSA则换成RSA签名)
/**
 生成数字签名(根据规则来定，如果是RSA则换成RSA签名)
 
 @param dic 待签名的字典
 
 @return 返回前面后的字符串
 */
- (NSString *) getSign:(NSMutableDictionary *)dic
{
    NSString *resStr = nil;
    @try {
        // 参数从a到z的顺序排序，若遇到相同首字母，则看第二个字母，以此类推
        NSArray *keys = [dic allKeys];
        NSArray *sortedArr = [keys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            return [obj1 compare:obj2 options:NSNumericSearch];
        }];
        
        NSMutableString *str = [NSMutableString string];
        for (NSString *categoryId in sortedArr) {
            if ([sortedArr indexOfObject:categoryId] == [sortedArr count] - 1) {
                [str appendFormat:@"%@=%@",categoryId,dic[categoryId]];
            } else if (![JDUtils isEmptyStr:categoryId]) {
                [str appendFormat:@"%@=%@,",categoryId,dic[categoryId]];
            }
        }
        
        // 使用MD5摘要算法对上一步生成的待签名字符串进行计算
        NSString *md5_str = [MD5 MD5Digest:str];
        // 使用PKCS1SHA1算法生成数字签名
        resStr = [[RSA sharedRSA] sign:md5_str];
    }
    @catch (NSException *exception) {
        NSLog(@"%@", [exception description]);
    }
    
    if ([resStr length] < 1) {
        resStr = @"";
    }
    
    return resStr;
}


#pragma mark - 把字典转换成键值对

/**
 把字典转换成键值对

 @param dit 待生成的键值对的字典

 @return 生成键值对后的字符串
 */

- (NSString *)stringPairsFromDictionary:(NSDictionary *)dit {
    if (!dit) {
        return err_msg1;
    }
    
    NSMutableArray *ret_arr = [NSMutableArray arrayWithCapacity:0];
    
    [dit enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSLog(@"key = %@, obj = %@", key, obj);
        [ret_arr addObject:[self stringPairsFromKey:key andValue:obj]];
    }];
    
    NSString *ret_str = [ret_arr componentsJoinedByString:@"&"];
    return  ret_str;
}

- (NSString *)stringPairsFromKey:(NSString *)key andValue:(NSString *)value {
    if ([key length] < 1 || [value length] < 1) {
        return @"";
    } else {
        return [NSString stringWithFormat:@"%@=%@", [URLCode encode:key], [URLCode encode:value]];
    }
}

#pragma mark - 获得系统级参数
/**
 获取系统参数

 @param apiName api的名称
 @param token   token

 @return 返回系统参数的字典
 */

- (NSDictionary *)getSystemParams:(NSString *)apiName withToken:(BOOL)token{
    NSMutableDictionary *mut_dic = [NSMutableDictionary dictionary];
    [mut_dic setValue:apiName forKey:@"api_name"];
    [mut_dic setValue:ver forKey:@"ver"];
    [mut_dic setValue:formate forKey:@"format"];
    [mut_dic setValue:app_id forKey:@"app_id"];
    [mut_dic setValue:[JDUtils getCurrentTime] forKey:@"timestamp"];
    if (token) {
        [mut_dic setValue:s_token forKey:@"auth_token"];
    }
    return mut_dic;
}

@end
