#import <Foundation/Foundation.h>
@interface SHA1 : NSObject {
}

+ (NSString *) SHA1Digest:(NSString *)src;
+ (NSData *) SHA1DigestData:(NSData *)src;
+ (NSData *)HmacSHA1:(NSData *)data Key:(NSData *)Key;

@end
