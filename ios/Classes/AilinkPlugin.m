#import "AilinkPlugin.h"
#import <AILinkSecretTool/ELEncryptTool.h>
#import "Algorithm/AlgorithmSDK.h"
#import "ElinkBroadDataUtils.h"

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
        NSData *data = typedData.data;
        NSData *decryptData = [ElinkBroadDataUtils decryptBroadcast: data];
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
            AlgorithmModel *model = [AlgorithmSDK getBodyfatWithWeight:weight adc:adc sex:sex age:age height:height algNum:0];
            NSString *bodyFatDataJsonStr = [NSString stringWithFormat:@"{\"bmi\": %@, \"bfr\": %@, \"sfr\": %@, \"uvi\": %@, \"rom\": %@, \"bmr\": %@, \"bm\": %@, \"vwc\": %@, \"physicalAge\": %@, \"pp\": %@}", model.bmi, model.bfr, model.sfr, model.uvi, model.rom, model.bmr, model.bm, model.vwc, model.physicalAge, model.pp];
            NSLog(@"getBodyFatData: %@", bodyFatDataJsonStr);
            result(bodyFatDataJsonStr);
        } else {
            // 处理解析错误
            NSLog(@"Error parsing JSON: %@", error.localizedDescription);
            result(nil);
        }
    } else if ([@"initHandShake" isEqualToString:call.method]) {
        result([ELEncryptTool handshake]);
    } else if ([@"getHandShakeEncryptData" isEqualToString:call.method]) {
        FlutterStandardTypedData *typedData = call.arguments;
        NSData *data = typedData.data;
        result([ELEncryptTool blueToothHandshakeWithData:data]);
    } else if ([@"checkHandShakeStatus" isEqualToString:call.method]) {
        result([NSNumber numberWithBool:YES]);
    } else if ([@"mcuEncrypt" isEqualToString:call.method]) {
        NSLog(@"mcuEncrypt: %@", call.arguments);
        FlutterStandardTypedData *cidTypedData = call.arguments[@"cid"];
        FlutterStandardTypedData *macTypedData = call.arguments[@"mac"];
        FlutterStandardTypedData *payloadTypedData = call.arguments[@"payload"];
        NSData *cid = cidTypedData.data;
        NSData *mac = macTypedData.data;
        NSData *payload = payloadTypedData.data;
        NSLog(@"mcuEncrypt: cid=%@, mac=%@, payload=%@", cid, mac, payload);
        result([ELEncryptTool encryptXOR:mac deviceTypeXOR:cid withXORData:payload]);
    } else if ([@"mcuDecrypt" isEqualToString:call.method]) {
        NSLog(@"mcuDecrypt: %@", call.arguments);
        FlutterStandardTypedData *macTypedData = call.arguments[@"mac"];
        FlutterStandardTypedData *payloadTypedData = call.arguments[@"payload"];
        NSData *mac = macTypedData.data;
        NSData *payload = payloadTypedData.data;
        NSData *cid = [payload subdataWithRange:NSMakeRange(1, 2)];
        NSData *data = [ElinkBroadDataUtils returnMcuDataFormat: payload];
        NSLog(@"mcuDecrypt: cid=%@, mac=%@, payload=%@", cid, mac, data);
        result([ELEncryptTool encryptXOR:mac deviceTypeXOR:cid withXORData:data]);
    } else {
        result(FlutterMethodNotImplemented);
    }
}

@end
