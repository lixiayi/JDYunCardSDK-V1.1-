//
//  JDLog.m
//  JDYunCardSDK
//
//  Created by xiaoyi li on 16/9/22.
//  Copyright © 2016年 xiaoyi li. All rights reserved.
//

#import "JDLog.h"

@implementation JDLog

+ (void)file:(char*)sourceFile function:(char*)functionName lineNumber:(int)lineNumber format:(NSString*)format,...{
    va_list ap;
    NSString *print,*file,*function;
    
    va_start(ap, format);
    
    file     = [[NSString alloc] initWithBytes:sourceFile length:strlen(sourceFile) encoding:NSUTF8StringEncoding];
    function = [NSString stringWithCString:functionName encoding:NSUTF8StringEncoding];
    print    = [[NSString alloc] initWithFormat:format arguments:ap];
    
    va_end(ap);
    NSLog(@"\nClass：%@: Line：%d Function：%@; Print：%@", [file lastPathComponent], lineNumber, function, print);
    
}


@end
