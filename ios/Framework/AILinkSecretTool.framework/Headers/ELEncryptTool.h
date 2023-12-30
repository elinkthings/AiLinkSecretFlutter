//
//  ELEncryptTool.h
//  AILinkSDK
//
//  Created by iot_user on 2019/5/7.
//  Copyright © 2019 IOT. All rights reserved.
//

#import <Foundation/Foundation.h>



NS_ASSUME_NONNULL_BEGIN


@interface ELEncryptTool : NSObject

/**
 app发送此A6数据主动开始与ble进行握手
 */
+(NSData *)handshake;

/**
 此方法将ble检验app的A6数据进行加密，app发给设备，否则设备将断开app
 */
+(NSData *)blueToothHandshakeWithData:(NSData *)receiveData;


/**
 A7数据加/解密方法

 @param macXOR mac地址对应的数据，传ELPeripheralModel的macXOR
 @param deviceTypeXOR 设备类型对应的数据，传ELPeripheralModel的deviceTypeXOR
 @param dataXOR 要加/解密的数据
 @return 加/解密后的数据
 */
+ (NSData *)encryptXOR:(NSData *)macXOR deviceTypeXOR:(NSData *)deviceTypeXOR withXORData:(NSData *)dataXOR;


/// AILink广播设备(广播体脂秤、广播营养秤)解密方法
/// @param encryptData 广播数据中加密数据
+ (NSData *)broadcastDecryptTEA:(NSData * _Nonnull)encryptData cid:(Byte)cid vid:(Byte)vid pid:(Byte)pid;

@end

NS_ASSUME_NONNULL_END
