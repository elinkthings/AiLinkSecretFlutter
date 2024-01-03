//
//  Algorithm.h
//  GreatBody
//
//  Created by steven wu on 2019/6/25.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, AlgUserSex) {
    AlgUserSex_Female = 0,//2,
    AlgUserSex_Male = 1, 
};


@interface AlgorithmModel : NSObject

///bmi
@property (nonatomic, copy) NSString *bmi;
///体脂率 bodyfatRate
@property (nonatomic, copy) NSString *bfr;
///皮下脂肪率 subcutaneousFat rate
@property (nonatomic, copy) NSString *sfr;
///内脏脂肪指数 visceralFat rate
@property (nonatomic, copy) NSString *uvi;
///肌肉率 muscle rate
@property (nonatomic, copy) NSString *rom;
///基础代谢率 BMR
@property (nonatomic, copy) NSString *bmr;
///骨骼质量 boneMass
@property (nonatomic, copy) NSString *bm;
///水含量vwc: moisture
@property (nonatomic, copy) NSString *vwc;
///身体年龄 physicalAge
@property (nonatomic, copy) NSString *physicalAge;
///蛋白率 proteinRate
@property (nonatomic, copy) NSString *pp;


/* For example
 bmi : 23.7;
 bfr : 22.2;
 rom : 51;
 vwc : 57;
 bm : 2.8;
 sfr : 19.9;
 bmi : 1549;
 pp : 16.6;
 uvi : 7;
 physicalAge : 26;
 */
@end


@interface AlgorithmSDK : NSObject

/**
 *  Inet AlgorithmSDK  品网算法
 *  Incoming user information + adc, calculate 10 original body fat data (the connected scale is calculated by the scale end and transmitted to the app via Bluetooth, and the broadcast scale calls this SDK calculation) 传入用户信息+adc，计算出10项原始体脂数据(连接秤由秤端计算并蓝牙传给app，广播秤调用本SDK计算)
 *  eg:
 *  kgWeight: 50.6  age: 25   height: 175
 */
+ (AlgorithmModel *)getBodyfatWithWeight:(double)kgWeight adc:(int)adc sex:(AlgUserSex)sex age:(int)age height:(int)height;


/**
 算法(位==1)

 @param kgWeight 体重（kg）
 @param adc 阻抗
 @param sex 性别
 @param age 年龄
 @param height 身高(cm)
 @return 结果
 */
+ (AlgorithmModel *)getBodyfatWithWeight:(double)kgWeight adc:(int)adc sex:(AlgUserSex)sex age:(int)age height:(int)height algNum:(NSInteger)algNum;
@end


