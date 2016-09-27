
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonHMAC.h>
#import "SHA1.h"
#import "Base64.h"


@implementation SHA1

+ (NSString*) SHA1Digest:(NSString *)src {
	NSData *data = [src dataUsingEncoding:NSUTF8StringEncoding];
	NSData *resultD = [SHA1 SHA1DigestData:data];
	NSString *resultS = [Base64 stringByEncodingData:resultD];
	return resultS;
}

+ (NSData *) SHA1DigestData:(NSData *)data {
    unsigned char hash[CC_SHA1_DIGEST_LENGTH];
    (void) CC_SHA1( [data bytes], (CC_LONG)[data length], hash );
    NSData *resultD = [NSData dataWithBytes: hash length: CC_SHA1_DIGEST_LENGTH];
    return resultD;
}

+ (NSData *)HmacSHA1:(NSData *)data Key:(NSData *)Key {
	
	NSData *secretData = Key;
	NSData *clearTextData = data;
	
	// create a digest
	uint8_t digest[CC_SHA1_DIGEST_LENGTH] = {0};
	// using common crypto
	CCHmacContext hmacContext;
	// we need to use SHA256 and we start by hashing the secretData (API Key)
	CCHmacInit(&hmacContext, kCCHmacAlgSHA1, secretData.bytes, secretData.length);
	// combine the existing hash with the clearTextData (the hashParams string)
	CCHmacUpdate(&hmacContext, clearTextData.bytes, clearTextData.length);
	CCHmacFinal(&hmacContext, digest);
    
    //unsigned char digest[CC_SHA1_DIGEST_LENGTH];
    //(void) CCHmac(kCCHmacAlgMD5, secretData, [secretData length], clearTextData, [clearTextData length], digest);
	
	// convert the digest to data
	NSData *hashedData = [NSData dataWithBytes:digest length:CC_SHA1_DIGEST_LENGTH];
    //NSString *result = [Base64 stringByEncodingData:hashedData];
        
    return hashedData;    
}

@end
