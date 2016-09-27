 
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonHMAC.h>
#import "Base64.h"
#import "MD5.h"


@implementation MD5

+ (NSString *) MD5Digest:(NSString *)str {
	const char *cStr = [str UTF8String];
	//[str release];
	unsigned char result[16];
	CC_MD5( cStr, (CC_LONG)strlen(cStr), result );
	NSString *resStr = [NSString stringWithFormat:
			@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
			result[0], result[1], result[2], result[3], 
			result[4], result[5], result[6], result[7],
			result[8], result[9], result[10], result[11],
			result[12], result[13], result[14], result[15]
			];
	return resStr;
}

+ (NSData *) MD5DigestData:(NSData *)data {
    unsigned char hash[CC_MD5_DIGEST_LENGTH];
    (void) CC_MD5( [data bytes], (CC_LONG)[data length], hash );
    NSData *resultD = [NSData dataWithBytes: hash length: CC_MD5_DIGEST_LENGTH];
    return resultD;
}

+ (NSData *)HmacMD5:(NSData *)data Key:(NSData *)Key {
	
	NSData *secretData = Key;
	NSData *clearTextData = data;
	
	// create a digest
	uint8_t digest[CC_MD5_DIGEST_LENGTH] = {0};
	// using common crypto
	CCHmacContext hmacContext;
	// we need to use SHA256 and we start by hashing the secretData (API Key)
	CCHmacInit(&hmacContext, kCCHmacAlgMD5, secretData.bytes, secretData.length);
	// combine the existing hash with the clearTextData (the hashParams string)
	CCHmacUpdate(&hmacContext, clearTextData.bytes, clearTextData.length);
	CCHmacFinal(&hmacContext, digest);
    
    //unsigned char digest[CC_SHA1_DIGEST_LENGTH];
    //(void) CCHmac(kCCHmacAlgMD5, secretData, [secretData length], clearTextData, [clearTextData length], digest);
	
	// convert the digest to data
	NSData *hashedData = [NSData dataWithBytes:digest length:CC_MD5_DIGEST_LENGTH];
    //NSString *result = [Base64 stringByEncodingData:hashedData];
        
    return hashedData;    
}

@end
