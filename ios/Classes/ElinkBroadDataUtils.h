//
//  ElinkBroadDataUtils.h
//  ailink
//  广播数据处理工具类
//  Broadcast data processing tools
//
//  Created by Suzy on 2024/1/31.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ElinkBroadDataUtils : NSObject

+ (NSData *)decryptBroadcast:(NSData *)payload;

@end

NS_ASSUME_NONNULL_END
