//
//  Created by Ken on 4/21/15.
//  Copyright (c) 2015 Epaylinks. All rights reserved.
//

#import "RSA.h"
#import <Security/Security.h>
#import "Base64.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
#import <Security/Security.h>
#import <EncryptConstant.h>



#define kChosenDigestLength CC_SHA1_DIGEST_LENGTH  // SHA-1消息摘要的数据位数160位


@implementation RSA

/** singleton instance  */
static RSA *sharedRSA = nil;

+ (RSA *) sharedRSA {
    @synchronized ([RSA class]) {
        if (sharedRSA == nil) {
            [[RSA alloc] init];
            sharedRSA.publicKey = CER_PUBLICKEY_DATA;
            sharedRSA.privateKey = CER_PRIVATEKEY_DATA;
            return sharedRSA;
        }
    }
    
    return sharedRSA;
}


+ (id) alloc {
    @synchronized ([RSA class]) {
        sharedRSA = [super alloc];
        return sharedRSA;
    }
    
    return nil;
}


- (id) init {
    self = [super init];
    if (self) {
        
    }
    
    return self;
}


#pragma mark - initial keypair
- (id)setPublicKey:(NSString *)publicKey privateKey:(NSString *)privateKey
{
    if (sharedRSA)
    {
        sharedRSA.publicKey = publicKey;
        sharedRSA.privateKey = privateKey;
    }
    
    return sharedRSA;
}


#pragma mark - Signature
-(NSString *)sign:(NSString *)plainText
{
    uint8_t* signedBytes = NULL;
    size_t signedBytesSize = 0;
    OSStatus sanityCheck = noErr;
    NSData* signedHash = nil;
    
    if (!plainText || [plainText isKindOfClass:[NSNull class]] || [[plainText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0)
    {
        return nil;
    }
    
    [self setPrivateKey:sharedRSA.privateKey
                    tag:[self privateKeyIdentifier]];
    
    NSMutableDictionary *keyQueryDictionary = [self keyQueryDictionary:[self privateKeyIdentifier]];
    [keyQueryDictionary setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
    
    SecKeyRef privateKeyRef = [self keyRefWithTag:[self privateKeyIdentifier]];
    
    if (!privateKeyRef)
    {
        return nil;
    }
    signedBytesSize = SecKeyGetBlockSize(privateKeyRef);
    
    NSData *plainTextBytes = [plainText dataUsingEncoding:NSUTF8StringEncoding];
    
    signedBytes = malloc( signedBytesSize * sizeof(uint8_t) ); // Malloc a buffer to hold signature.
    memset((void *)signedBytes, 0x0, signedBytesSize);
    
    sanityCheck = SecKeyRawSign(
                                privateKeyRef,
                                kSecPaddingPKCS1SHA1,
                                (const uint8_t *)[[self getHashBytes:plainTextBytes] bytes],
                                kChosenDigestLength,
                                (uint8_t *)signedBytes,
                                &signedBytesSize);
    
    if (sanityCheck == noErr)
    {
        signedHash = [NSData dataWithBytes:(const void *)signedBytes length:(NSUInteger)signedBytesSize];
    }
    else
    {
        return nil;
    }
    
    if (signedBytes)
    {
        free(signedBytes);
    }
    NSString *signatureResult=[NSString stringWithFormat:@"%@", [Base64 stringByEncodingData:signedHash]];     // [signedHash base64EncodedString]];
    return signatureResult;
}



#pragma mark - encrypt / decrypt
- (NSString *)encrypt:(NSString *)plainText
{
    if (!plainText)
    {
        return nil;
    }
    
    [self setPublicKey:sharedRSA.publicKey tag:[self publicKeyIdentifier]];
    
    SecKeyRef publicKey = [self keyRefWithTag:[self publicKeyIdentifier]];
    
    if (!publicKey)
    {
        return nil;
    }
    
    uint8_t *nonce = (uint8_t *)[plainText UTF8String];
    size_t cipherBufferSize = SecKeyGetBlockSize(publicKey);
    uint8_t *cipherBuffer = malloc(cipherBufferSize);
    
    if (cipherBufferSize < sizeof(nonce))
    {
        if (publicKey)
        {
            CFRelease(publicKey);
        }
        
        free(cipherBuffer);
        
        NSLog(@"CryptoErrorRSATextLength");
        return nil;
    }
    
    OSStatus secStatus = SecKeyEncrypt(publicKey,
                                       kSecPaddingPKCS1,
                                       nonce,
                                       strlen((char *)nonce) + 1,
                                       &cipherBuffer[0],
                                       &cipherBufferSize);
    
    if (secStatus != noErr)
    {
        NSLog(@"CryptoErrorEncrypt");
        return nil;
    }
    
    NSData *encryptedData = [NSData dataWithBytes:cipherBuffer length:cipherBufferSize];
    
    if (publicKey)
    {
        CFRelease(publicKey);
    }
    free(cipherBuffer);
    
    NSString *result = [Base64 stringByEncodingData:encryptedData];
    
    return result;
}


- (NSString *)decrypt:(NSString *)cipherText
{
    if (!cipherText)
    {
        NSLog(@"CryptoErrorDecrypt");
        return nil;
    }
    
    [self setPrivateKey:sharedRSA.privateKey
                    tag:[self privateKeyIdentifier]];
    
    NSMutableDictionary *keyQueryDictionary = [self keyQueryDictionary:[self privateKeyIdentifier]];
    [keyQueryDictionary setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
    
    SecKeyRef privateKey = [self keyRefWithTag:[self privateKeyIdentifier]];
    
    if (!privateKey)
    {
        return nil;
    }
    
    size_t plainBufferSize = SecKeyGetBlockSize(privateKey);
    uint8_t *plainBuffer = malloc(plainBufferSize);
    
    NSData *incomingData = [Base64 decodeString:cipherText];
    uint8_t *cipherBuffer = (uint8_t*)[incomingData bytes];
    size_t cipherBufferSize = SecKeyGetBlockSize(privateKey);
    
    if (plainBufferSize < cipherBufferSize)
    {
        if (privateKey)
        {
            CFRelease(privateKey);
        }
        
        free(plainBuffer);
        
        NSLog(@"CryptoErrorRSATextLength");
        return nil;
    }
    
    OSStatus secStatus = SecKeyDecrypt(privateKey,
                                       kSecPaddingPKCS1,
                                       cipherBuffer,
                                       cipherBufferSize,
                                       plainBuffer,
                                       &plainBufferSize);
    
    if (secStatus != noErr)
    {
        NSLog(@"CryptoErrorDecrypt");
        return nil;
    }
    
    NSString *decryptedString = [[NSString alloc] initWithBytes:plainBuffer
                                                         length:plainBufferSize
                                                       encoding:NSUTF8StringEncoding];
    
    free(plainBuffer);
    
    if (privateKey)
    {
        CFRelease(privateKey);
    }
    
    return decryptedString;
}


- (void)setPrivateKey:(NSString *)key tag:(NSString *)tag
{
    [self removeKey:tag];
    
    NSString *strippedKey = nil;
    if ([self isPrivateKey:key])
    {
        strippedKey = [self strippedKey:key header:[self PEMPrivateHeader] footer:[self PEMPrivateFooter]];
    }
    
    if (!strippedKey)
    {
        NSLog(@"CryptoErrorRSAKeyFormat");
        return;
    }
    
    NSData *strippedPrivateKeyData = [Base64 decodeString:strippedKey];
    NSMutableDictionary *keyQueryDictionary = [self keyQueryDictionary:tag];
    [keyQueryDictionary setObject:strippedPrivateKeyData forKey:(__bridge id)kSecValueData];
    [keyQueryDictionary setObject:(__bridge id)kSecAttrKeyClassPrivate forKey:(__bridge id)kSecAttrKeyClass];
    [keyQueryDictionary setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnPersistentRef];
    
    CFTypeRef persistKey = nil;
    OSStatus secStatus = SecItemAdd((__bridge CFDictionaryRef)keyQueryDictionary, &persistKey);
    
    if (persistKey != nil)
    {
        CFRelease(persistKey);
    }
    
    if ((secStatus != noErr) && (secStatus != errSecDuplicateItem))
    {
        NSLog(@"CryptoErrorRSAAddKey");
        return;
    }
    
    return;
}


- (void)setPublicKey:(NSString *)key tag:(NSString *)tag
{
    [self removeKey:tag];
    
    NSData *strippedPublicKeyData = [self strippedPublicKey:key];
    
    if (!strippedPublicKeyData)
    {
        return;
    }
    
    CFTypeRef persistKey = nil;
    
    NSMutableDictionary *keyQueryDictionary = [self keyQueryDictionary:tag];
    [keyQueryDictionary setObject:strippedPublicKeyData forKey:(__bridge id)kSecValueData];
    [keyQueryDictionary setObject:(__bridge id)kSecAttrKeyClassPublic forKey:(__bridge id)kSecAttrKeyClass];
    [keyQueryDictionary setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnPersistentRef];
    
    OSStatus secStatus = SecItemAdd((__bridge CFDictionaryRef)keyQueryDictionary, &persistKey);
    
    if (persistKey != nil)
    {
        CFRelease(persistKey);
    }
    
    if ((secStatus != noErr) && (secStatus != errSecDuplicateItem))
    {
        NSLog(@"CryptoErrorRSAAddKey");
        
        return;
    }
    
    return;
}


- (NSData *)strippedPublicKey:(NSString *)key
{
    NSString *strippedKey = nil;
    if ([self isX509PublicKey:key])
    {
        strippedKey = [self strippedKey:key header:[self X509PublicHeader] footer:[self X509PublicFooter]];
    }
    else if ([self isPKCS1PublicKey:key])
    {
        strippedKey = [self strippedKey:key header:[self PKCS1PublicHeader] footer:[self PKCS1PublicFooter]];
    }
    
    if (!strippedKey)
    {
        NSLog(@"CryptoErrorRSAKeyFormat");
        return nil;
    }
    
    NSData *strippedPublicKeyData = [Base64 decodeString:strippedKey];
    if ([self isX509PublicKey:key])
    {
        unsigned char * bytes = (unsigned char *)[strippedPublicKeyData bytes];
        size_t bytesLen = [strippedPublicKeyData length];
        
        size_t i = 0;
        if (bytes[i++] != 0x30)
        {
            NSLog(@"CryptoErrorRSAKeyFormat");
            
            return nil;
        }
        
        if (bytes[i] > 0x80)
        {
            i += bytes[i] - 0x80 + 1;
        }
        else
        {
            i++;
        }
        
        if (i >= bytesLen)
        {
            NSLog(@"CryptoErrorRSAKeyFormat");
            
            return nil;
        }
        if (bytes[i] != 0x30)
        {
            NSLog(@"CryptoErrorRSAKeyFormat");
            return nil;
        }
        
        i += 15;
        
        if (i >= bytesLen - 2)
        {
            NSLog(@"CryptoErrorRSAKeyFormat");
            return nil;
        }
        if (bytes[i++] != 0x03)
        {
            NSLog(@"CryptoErrorRSAKeyFormat");
            return nil;
        }
        
        if (bytes[i] > 0x80)
        {
            i += bytes[i] - 0x80 + 1;
        }
        else
        {
            i++;
        }
        
        if (i >= bytesLen)
        {
            NSLog(@"CryptoErrorRSAKeyFormat");
            return nil;
        }
        if (bytes[i++] != 0x00)
        {
            NSLog(@"CryptoErrorRSAKeyFormat");
            return nil;
        }
        if (i >= bytesLen)
        {
            NSLog(@"CryptoErrorRSAKeyFormat");
            return nil;
        }
        
        strippedPublicKeyData = [NSData dataWithBytes:&bytes[i] length:bytesLen - i];
    }
    
    if (!strippedPublicKeyData)
    {
        NSLog(@"CryptoErrorRSAKeyFormat");
        return nil;
    }
    
    return strippedPublicKeyData;
}


- (NSString *)strippedKey:(NSString *)key header:(NSString *)header footer:(NSString *)footer
{
    NSString *result = [[key stringByReplacingOccurrencesOfString:header withString:@""] stringByReplacingOccurrencesOfString:footer withString:@""];
    
    return [[result stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""];
}


- (BOOL)isPrivateKey:(NSString *)key
{
    if (([key rangeOfString:[self PEMPrivateHeader]].location != NSNotFound) && ([key rangeOfString:[self PEMPrivateFooter]].location != NSNotFound))
    {
        return YES;
    }
    
    return NO;
}


- (BOOL)isX509PublicKey:(NSString *)key
{
    if (([key rangeOfString:[self X509PublicHeader]].location != NSNotFound) && ([key rangeOfString:[self X509PublicFooter]].location != NSNotFound))
    {
        return YES;
    }
    
    return NO;
}


- (BOOL)isPKCS1PublicKey:(NSString *)key
{
    if (([key rangeOfString:[self PKCS1PublicHeader]].location != NSNotFound) && ([key rangeOfString:[self PKCS1PublicFooter]].location != NSNotFound))
    {
        return YES;
    }
    
    return NO;
}




#pragma mark - Keychain convenience methods

- (NSData *)keyDataWithTag:(NSString *)tag
{
    NSMutableDictionary *queryKey = [self keyQueryDictionary:tag];
    [queryKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnData];
    
    SecKeyRef key = NULL;
    OSStatus err = SecItemCopyMatching((__bridge CFDictionaryRef)queryKey, (CFTypeRef *)&key);
    
    if (err != noErr || !key)
    {
        NSLog(@"CryptoErrorRSACopyKey");
        return nil;
    }
    
    return (__bridge NSData *)key;
}


- (SecKeyRef)keyRefWithTag:(NSString *)tag
{
    NSMutableDictionary *queryKey = [self keyQueryDictionary:tag];
    [queryKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
    
    SecKeyRef key = NULL;
    OSStatus err = SecItemCopyMatching((__bridge CFDictionaryRef)queryKey, (CFTypeRef *)&key);
    
    if (err != noErr)
    {
        NSLog(@"CryptoErrorRSACopyKey");
        
        return nil;
    }
    
    return key;
}


- (void)removeKey:(NSString *)tag
{
    NSDictionary *queryKey = [self keyQueryDictionary:tag];
    OSStatus secStatus = SecItemDelete((__bridge CFDictionaryRef)queryKey);
    
    if ((secStatus != noErr) && (secStatus != errSecDuplicateItem))
    {
        NSLog(@"CryptoErrorRSARemoveKey");
    }
}


- (NSMutableDictionary *)keyQueryDictionary:(NSString *)tag
{
    NSData *keyTag = [tag dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    [result setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [result setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [result setObject:keyTag forKey:(__bridge id)kSecAttrApplicationTag];
    [result setObject:(__bridge id)kSecAttrAccessibleWhenUnlocked forKey:(__bridge id)kSecAttrAccessible];
    
    return result;
}


- (NSUInteger)PEMWrapWidth
{
    return 64;
}




#pragma mark - RSA Key Anatomy


- (NSString *)X509PublicHeader
{
    return @"-----BEGIN PUBLIC KEY-----";
}


- (NSString *)X509PublicFooter
{
    return @"-----END PUBLIC KEY-----";
}


- (NSString *)PKCS1PublicHeader
{
    return  @"-----BEGIN RSA PUBLIC KEY-----";
}


- (NSString *)PKCS1PublicFooter
{
    return @"-----END RSA PUBLIC KEY-----";
}


- (NSString *)PEMPrivateHeader
{
    return @"-----BEGIN RSA PRIVATE KEY-----";
}


- (NSString *)PEMPrivateFooter
{
    return @"-----END RSA PRIVATE KEY-----";
}




#pragma mark - Important tags
- (NSString *)publicKeyIdentifier
{
    return [self publicKeyIdentifierWithTag:nil];
}


- (NSString *)privateKeyIdentifier
{
    return [self privateKeyIdentifierWithTag:nil];
}


- (NSString *)publicKeyIdentifierWithTag:(NSString *)additionalTag
{
    NSString *identifier = [NSString stringWithFormat:@"%@.publicKey", [[NSBundle mainBundle] bundleIdentifier]];
    
    if (additionalTag)
    {
        identifier = [identifier stringByAppendingFormat:@".%@", additionalTag];
    }
    
    return identifier;
}


- (NSString *)privateKeyIdentifierWithTag:(NSString *)additionalTag
{
    NSString *identifier = [NSString stringWithFormat:@"%@.privateKey", [[NSBundle mainBundle] bundleIdentifier]];
    
    if (additionalTag)
    {
        identifier = [identifier stringByAppendingFormat:@".%@", additionalTag];
    }
    
    return identifier;
}

- (NSData *)getHashBytes:(NSData *)plainText {
    CC_SHA1_CTX ctx;
    uint8_t * hashBytes = NULL;
    NSData * hash = nil;
    
    // Malloc a buffer to hold hash.
    hashBytes = malloc( kChosenDigestLength * sizeof(uint8_t) );
    memset((void *)hashBytes, 0x0, kChosenDigestLength);
    // Initialize the context.
    CC_SHA1_Init(&ctx);
    // Perform the hash.
    CC_SHA1_Update(&ctx, (void *)[plainText bytes], [plainText length]);
    // Finalize the output.
    CC_SHA1_Final(hashBytes, &ctx);
    
    // Build up the SHA1 blob.
    hash = [NSData dataWithBytes:(const void *)hashBytes length:(NSUInteger)kChosenDigestLength];
    if (hashBytes) free(hashBytes);
    
    return hash;
}



@end
