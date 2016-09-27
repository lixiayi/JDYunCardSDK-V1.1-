 
#import "URLCode.h"


@implementation URLCode

/**
 *
 urlencode()函数原理:对字符串中除了 -_.之外的所有非字母数字字符都将被替换成百分号（%）后跟两位十六进制数，空格则编码为加号（+）
 urldecode()函数与urlencode()函数原理相反，用于解码已编码的URL字符串，其原理就是把十六进制字符串转换为中文字符
 */

+ (NSString *) encode:(NSString *) str
{
    NSString *result = @"";
#if defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    NSCharacterSet *characterSet = [NSCharacterSet URLUserAllowedCharacterSet];
    result = [str stringByAddingPercentEncodingWithAllowedCharacters:characterSet];
#else
    result = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                   (CFStringRef)str,
                                                                                   NULL,
                                                                                   CFSTR("!*'();:@&=+$,/?%#[]"),
                                                                                   kCFStringEncodingUTF8));
#endif
	return result;
}

+ (NSString*) decode:(NSString *) str
{
    NSString *result = @"";
#if defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    result = [str stringByRemovingPercentEncoding];
    
#else
    result = (NSString *)CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
                                                                                                   (CFStringRef)str,
                                                                                                   CFSTR(""),
                                                                                                   kCFStringEncodingUTF8));
#endif
	return result;
}

@end
