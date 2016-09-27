//
//  zipAndUnzip.h
//  STZipAndUnzip
//
//  Created by xiaoyi li on 16/8/25.
//  Copyright © 2016年 xiaoyi li. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface zipAndUnzip : NSObject

/**
 *  解压
 *
 *  @param data  待解压的二进制数据
 *
 *  @return 解压后的二进制数据
 */
- (NSData *)gzipInflate:(NSData *)data;



/**
 *  压缩
 *
 *  @param data 待压缩的二进制数据
 *
 *  @return 返回压缩后的二进制数据
 */
- (NSData *)gzipDeflate:(NSData *)data;

@end
