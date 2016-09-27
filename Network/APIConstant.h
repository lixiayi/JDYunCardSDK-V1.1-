//
//  APIConstant.h
//  JDYunCardSDK
//
//  Created by xiaoyi li on 16/9/22.
//  Copyright © 2016年 xiaoyi li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface APIConstant : NSObject

#pragma mark - 用到的常量

UIKIT_EXTERN NSString *const err_msg;
UIKIT_EXTERN NSString *const err_msg1;
UIKIT_EXTERN NSString *const err_msg2;
UIKIT_EXTERN NSString *const ver;
UIKIT_EXTERN NSString *const formate;
UIKIT_EXTERN NSString *const app_id;
UIKIT_EXTERN NSString *const terminal_no;
UIKIT_EXTERN NSString *const s_token;


#pragma mark - 在此定义所有的接口常量

UIKIT_EXTERN NSString *const cloud_card_user_register;
UIKIT_EXTERN NSString *const cloud_card_open_account;
UIKIT_EXTERN NSString *const cloud_card_download;
UIKIT_EXTERN NSString *const cloud_card_query_list;
UIKIT_EXTERN NSString *const cloud_card_query_info;
UIKIT_EXTERN NSString *const cloud_card_written_off;

UIKIT_EXTERN NSString *const cloud_card_trans_account_recharge;

UIKIT_EXTERN NSString *const cloud_card_ca_download;
UIKIT_EXTERN NSString *const cloud_card_pic_download;
UIKIT_EXTERN NSString *const cloud_card_type_download;



@end
