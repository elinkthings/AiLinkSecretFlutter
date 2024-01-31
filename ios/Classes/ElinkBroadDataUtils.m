//
//  ElinkBroadDataUtils.m
//  ailink
//
//  Created by Suzy on 2024/1/31.
//

#import "ElinkBroadDataUtils.h"
#import <AILinkSecretTool/ELEncryptTool.h>

@implementation ElinkBroadDataUtils

+ (NSData *)decryptBroadcast:(NSData *)payload {
    if (payload.length >= 20) {
        Byte * byte = (Byte *)[payload bytes];
        Byte byteCid = byte[0];
        int vid = byte[1];
        int pid = byte[2];
        
        NSData *chechsumData = [payload subdataWithRange:NSMakeRange(9, 11)];
        
        if ([self broadcastChecksum:chechsumData]) {
            //Get encrypted data
            NSData *data = [payload subdataWithRange:NSMakeRange(10, 8)];
            //Decrypt encrypted data
            data = [ELEncryptTool broadcastDecryptTEA:data cid:byteCid vid:vid pid:pid];
            //Get the 2 bytes of data at the end of the packet
            NSData *tailData = [payload subdataWithRange:NSMakeRange(18, 2)];
            //Get final data
            NSMutableData *result = [NSMutableData dataWithData:data];
            [result appendData:tailData];
            return result;
        }
    }
    return payload;
}

+ (BOOL)broadcastChecksum:(NSData *)data{
    if (data.length != 11) {
        return NO;
    }else{
        BOOL is = NO;
        Byte *bytes = (Byte *)[data bytes];
        //校验和
        Byte checksum = 0x00;
        for (int i=1; i<data.length; i++) {
            checksum += bytes[i];
            
        }
        if (checksum == bytes[0]) {
            is = YES;
        }
        return is;
    }
}

@end
