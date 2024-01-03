#import "AilinkPlugin.h"
#import <AILinkSecretTool/ELEncryptTool.h>
#import "Algorithm/AlgorithmSDK.h"

@implementation AilinkPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"ailink"
                                     binaryMessenger:[registrar messenger]];
    AilinkPlugin* instance = [[AilinkPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"getPlatformVersion" isEqualToString:call.method]) {
        result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
    } else if ([@"decryptBroadcast" isEqualToString:call.method]) {
        FlutterStandardTypedData *typedData = call.arguments;
        NSData * data = typedData.data;
        NSData *decryptData = [self decryptBroadcast: data];
        NSLog(@"data: %@", typedData.data);
        NSLog(@"decryptData: %@", decryptData);
        result(decryptData);
    } else if ([@"getBodyFatData" isEqualToString:call.method]) {
        NSLog(@"argment: %@", call.arguments);
        NSData *jsonData = [call.arguments dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
        // 检查解析是否成功
        if (jsonDictionary) {
            double weight = [jsonDictionary[@"weight"] doubleValue];
            int adc = [jsonDictionary[@"adc"] intValue];
            int sex = [jsonDictionary[@"sex"] intValue];
            int age = [jsonDictionary[@"age"] intValue];
            int height = [jsonDictionary[@"height"] intValue];
            int algNum = [jsonDictionary[@"algNum"] intValue];
            
            if (sex == 2) {
                sex = 0;
            }
            NSLog(@"weight: %f, adc: %d, sex: %d, age: %d, height: %d, algNum: %d", weight, adc, sex, age, height, algNum);
            AlgorithmModel *model = [AlgorithmSDK getBodyfatWithWeight:weight adc:adc sex:AlgUserSex_Male age:age height:height algNum:algNum];
            NSString *bodyFatDataJsonStr = [NSString stringWithFormat:@"{\"bmi\": %@, \"bfr\": %@, \"sfr\": %@, \"uvi\": %@, \"rom\": %@, \"bmr\": %@, \"bm\": %@, \"vwc\": %@, \"physicalAge\": %@, \"pp\": %@}", model.bmi, model.bfr, model.sfr, model.uvi, model.rom, model.bmr, model.bm, model.vwc, model.physicalAge, model.pp];
            NSLog(@"getBodyFatData: %@", bodyFatDataJsonStr);
            result(bodyFatDataJsonStr);
        } else {
            // 处理解析错误
            NSLog(@"Error parsing JSON: %@", error.localizedDescription);
            result(nil);
        }
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (NSData *)decryptBroadcast:(NSData *)payload {
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

-(BOOL)broadcastChecksum:(NSData *)data{
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
