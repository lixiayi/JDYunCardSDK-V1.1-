//
//  Created by Ken on 4/21/15.
//  Copyright (c) 2015 Epaylinks. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RSAKeyPair;

@interface RSA : NSObject

@property (nonatomic, strong) NSString *publicKey;
@property (nonatomic, strong) NSString *privateKey;


+ (RSA *) sharedRSA;

/** 初始化支付公司公钥及第三方私钥 */
- (id) setPublicKey:(NSString *)publicKey privateKey:(NSString *)privateKey;

- (NSString *) encrypt:(NSString *)plainText;

- (NSString *) decrypt:(NSString *)cipherText;

- (NSString *) sign:(NSString *)plainText;

@end
