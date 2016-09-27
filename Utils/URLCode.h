
#import <Foundation/Foundation.h>


@interface URLCode : NSObject

+ (NSString *) encode:(NSString *) str;

+ (NSString *) decode:(NSString *) str;

@end
