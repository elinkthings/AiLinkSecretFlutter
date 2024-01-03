//
//  HTBodyfat_SDK.h
//
//  Created by Holtek on 17/12/21.
//  Copyright © 2017年 Holtek. All rights reserved.
//
//  Version: 3.06, SDK for armV7、arm64、x86_x64, OS ≥ iOS 8.0
//
#import <UIKit/UIKit.h>

@class HTBodyInfo;
@class HTBodyResult;
@class HTBodyResultAllBody;
@class HTBodyResultTwoLegs;
@class HTBodyResultTwoArms;
@class HTBodyResultArmsLegs;

///性别类型
typedef NS_ENUM(NSInteger, HTSexType){
    HTSexTypeFemale,        //!< 女性
    HTSexTypeMale           //!< 男性
};

///错误类型(针对输入的参数)
typedef NS_ENUM(NSInteger, HTBodyfatErrorType){
    HTBodyfatErrorTypeNone,         //!< 无错误(可读取所有参数)
    HTBodyfatErrorTypeAge    = 0x01,       //!< 年龄参数有误，需在 6   ~ 99岁(不计算除BMI/idealWeightKg以外参数)
    HTBodyfatErrorTypeWeight = 0x02,       //!< 体重参数有误，需在 10  ~ 200kg(有误不计算所有参数)
    HTBodyfatErrorTypeHeight = 0x04,       //!< 身高参数有误，需在 90 ~ 220cm(不计算所有参数)
    HTBodyfatErrorTypeSex    = 0x08,       //!< 性别参数有误，需为0或1
    HTBodyfatErrorTypeImpedance = 0x10,    //!< 阻抗系数有误,阻抗有误时, 不计算除BMI/idealWeightKg以外参数(写0)
    HTBodyfatErrorTypeImpedanceLeftLeg  = 0x20,    //!< 左脚阻抗系数有误,
    HTBodyfatErrorTypeImpedanceRightLeg = 0x40,    //!< 右脚阻抗系数有误,
    HTBodyfatErrorTypeImpedanceLeftArm  = 0x80,    //!< 左手阻抗系数有误,
    HTBodyfatErrorTypeImpedanceRightArm = 0x100,   //!< 右手阻抗系数有误,
};

///身体类型
typedef NS_ENUM(NSInteger, HTBodyType){
    HTBodyTypeThin,             //!< 偏瘦型
    HTBodyTypeLThinMuscle,      //!< 偏瘦肌肉型
    HTBodyTypeMuscular,         //!< 肌肉发达型
    
    HTBodyTypeLackofexercise,   //!< 缺乏运动型
    HTBodyTypeStandard,         //!< 标准型
    HTBodyTypeStandardMuscle,   //!< 标准肌肉型
    
    HTBodyTypeObesFat,          //!< 浮肿肥胖型
    HTBodyTypeLFatMuscle,       //!< 偏胖肌肉型
    HTBodyTypeMuscleFat,        //!< 肌肉型偏胖
};

///测量类型
typedef NS_ENUM(NSInteger, HTBodyMeasureType){
    HTBodyMeasureTypeTwoLegs,      //!< 双脚
    HTBodyMeasureTypeAllBody,      //!< 全身
    HTBodyMeasureTypeTwoArms,      //!< 双手
    HTBodyMeasureTypeArmsLegs,     //!< 双手双脚
    HTBodyMeasureTypeThighArms,    //!< 大腿到手
    HTBodyMeasureTypeThigh         //!< 大腿
};

#pragma mark - HTBodyBasicInfo
// 计算体脂参数所需数据model
@interface HTBodyBasicInfo : NSObject
//测量者基本信息
@property (nonatomic,assign) HTSexType            htSex;         //!< 性别
@property (nonatomic,assign) NSInteger            htHeightCm;    //!< 身高(cm)，需在 90 ~ 220cm
@property (nonatomic,assign) CGFloat              htWeightKg;    //!< 体重(kg)，需在 10  ~ 200kg
@property (nonatomic,assign) NSInteger            htAge;         //!< 年龄(岁)，需在6 ~ 99岁
//测量双脚时需赋值
@property (nonatomic,assign) NSInteger            htTwoLegsImpedance;     //!< 双脚阻抗系数
//测量双手时需赋值
@property (nonatomic,assign) NSInteger            htTwoArmsImpedance;     //!< 双手阻抗系数
//测量全身时需赋值
@property (nonatomic,assign) CGFloat              htZAllBodyImpedance;    //!< 全身阻抗系数
@property (nonatomic,assign) CGFloat              htZLeftLegImpedance;    //!< 左脚阻抗系数
@property (nonatomic,assign) CGFloat              htZRightLegImpedance;   //!< 右脚阻抗系数
@property (nonatomic,assign) CGFloat              htZLeftArmImpedance;    //!< 左手阻抗系数
@property (nonatomic,assign) CGFloat              htZRightArmImpedance;   //!< 右手阻抗系数

/**
 *  初始化人体数据
 *
 *  @param sex      性别
 *  @param height   身高，单位cm
 *  @param weight   体重，单位kg
 *  @param age      年龄
 *
 *  @return 人体数据model
 */
- (id)initWithSex:(HTSexType)sex height:(NSInteger)height weight:(CGFloat)weight age:(NSInteger)age;

@end

#pragma mark - HTBodyResult

/**
 * 体脂测量结果的基类
 * 所有标准的字典使用说明如下:
 * 1.以BMI为例
 * 小于"瘦－普通"为瘦,小于“普通－偏胖”为普通，小于"偏胖－肥胖"为偏胖，其它肥胖
 
 * 2.以体脂率为例
 * 小于"偏瘦－标准"        为偏瘦
 * 小于“标准－警惕”        为标准
 * 小于"警惕－偏胖"        为警惕
 * 小于"偏胖－肥胖"        为偏胖
 * 其它                   肥胖
 */
@interface HTBodyResult : NSObject

@property (nonatomic,assign) HTBodyfatErrorType   htErrorType;   //!< 错误类型，数据/计算是否有误

@property (nonatomic,assign) CGFloat              htProteinPercentage;    //!< 蛋白质,分辨率0.1, 范围2.0% ~ 30.0%
@property (nonatomic,copy)   NSDictionary*        htProteinRatingList;    //!< 蛋白健康标准字典,"不足－标准"“标准－优秀”

@property (nonatomic,assign) CGFloat              htBMI;                  //!< Body Mass Index 人体质量指数, 分辨率0.1, 范围10.0 ~ 90.0
@property (nonatomic,copy) NSDictionary*          htBMIRatingList;        //!< BMI健康标准字典,"瘦－普通"“普通－偏胖”“偏胖－肥胖”

@property (nonatomic,assign) NSInteger            htBMR;                  //!< Basal Metabolic Rate基础代谢, 分辨率1, 范围500 ~ 10000
@property (nonatomic,copy) NSDictionary*          htBMRRatingList;        //!< 基础代谢健康标准字典:"偏低－达标"

@property (nonatomic,assign) NSInteger            htVFAL;                 //!< Visceral fat area leverl内脏脂肪, 分辨率1, 范围1 ~ 60
@property (nonatomic,copy) NSDictionary*          htVFALRatingList;       //!< 内脏脂肪等级标准字典,"标准-警惕""警惕-危险"

@property (nonatomic,assign) CGFloat              htBoneKg;               //!< 骨量(kg), 分辨率0.1, 范围0.5 ~ 8.0
@property (nonatomic,copy) NSDictionary*          htBoneRatingList;       //!< 骨量等级标准字典,"不足－标准"“标准－优秀”

@property (nonatomic,assign) CGFloat              htBodyfatSubcut;        //!< 皮下脂肪率(%), 分辨率0.1, 范围0.1 ~ 60.0
@property (nonatomic,assign) CGFloat              htBodyfatSubcutKg;      //!< 皮下脂肪量(kg)
@property (nonatomic,copy) NSDictionary*          htBodyfatSubcutList;    //!< 皮下脂肪等级标准

@property (nonatomic,assign) CGFloat              htBodyfatFreeMass;      //!< 去脂体重(kg)

/**
 * 运动消耗量:kcal/30分钟, 字典key值如下，value为NSNumber类型
 *   步行:walking,     慢跑:jogging,         自行车:bicycle,    游泳:swim,             爬山:mountain_climbing,
 *   有氧操:aerobic,   乒乓球:tabletennis,    网球:tennis,      足球:football,         击剑:oriental_fencing,
 *   门球:gateball,    羽毛球:badminton,      壁球:racketball,  跆拳道:tae_kwon_do,    弹力球:squash,
 *   篮球:basketball,  跳绳:ropejumping,     高尔夫:golf
 */
@property (nonatomic,copy) NSDictionary*          htExercisePlannerList;  //!< 运动计划，运动消耗量表

@property (nonatomic,assign) CGFloat              htBodyfatKg;            //!< 脂肪量(kg)
@property (nonatomic,assign) CGFloat              htBodyfatPercentage;    //!< 脂肪率(%), 分辨率0.1, 范围5.0% ~ 75.0%
@property (nonatomic,copy) NSDictionary*          htBodyfatRatingList;    //!< 脂肪率健康标准字典"偏瘦－标准"“标准－警惕”“警惕－偏胖”“偏胖－肥胖”

@property (nonatomic,assign) CGFloat              htWaterPercentage;      //!< 水分率(%), 分辨率0.1, 范围35.0% ~ 75.0%
@property (nonatomic,copy) NSDictionary*          htWaterRatingList;      //!< 水分率健康标准 "不足－标准"“标准－优秀”

@property (nonatomic,assign) CGFloat              htMuscleKg;             //!< 肌肉量(kg), 分辨率0.1, 范围10.0 ~ 120.0
@property (nonatomic,assign) CGFloat              htMusclePercentage;     //!< 肌肉率(%),分辨率0.1，范围5%~90%
@property (nonatomic,copy) NSDictionary*          htMuscleRatingList;     //!< 肌肉量健康标准 "不足－标准"“标准－优秀”

@property (nonatomic,assign) NSInteger            htBodyAge;              //!< 身体年龄,6~99岁
@property (nonatomic,assign) CGFloat              htIdealWeightKg;        //!< 理想体重(kg)
@property (nonatomic,assign) HTBodyType           htBodyType;             //!< 身体类型
@property (nonatomic,assign) NSInteger            htBodyScore;            //!< 身体得分，50 ~ 100分

/**
 *  根据测量类型获取体脂参数，调用之前需先给相应测量类型的阻抗系数赋值
 *
 *  @param basicInfo  人体参数基本信息
 *
 *  @return 体脂计算结果，判断是否有错误
 */
- (HTBodyfatErrorType )getBodyfatWithBasicInfo:(HTBodyBasicInfo *)basicInfo;

@end

#pragma mark - HTBodyResultTwoLegs
/**
 * 双脚的测量结果类
 */
@interface HTBodyResultTwoLegs : HTBodyResult

@property (nonatomic,assign) CGFloat              htZTwoLegs;    //!< 脚对脚阻抗值(Ω), 范围200.0 ~ 1200.0

@end

#pragma mark - HTBodyResultAllBody
/**
 * 全身的测量结果类
 */
@interface HTBodyResultAllBody : HTBodyResult

@property (nonatomic,assign) CGFloat              htZAllBody;    //!< 全身阻抗值(Ω), 范围75.0 ~ 1500.0
@property (nonatomic,assign) CGFloat              htZLeftLeg;    //!< 左脚阻抗值(Ω), 范围75.0 ~ 1500.0
@property (nonatomic,assign) CGFloat              htZRightLeg;   //!< 右脚阻抗值(Ω), 范围75.0 ~ 1500.0
@property (nonatomic,assign) CGFloat              htZLeftArm;    //!< 左手阻抗值(Ω), 范围75.0 ~ 1500.0
@property (nonatomic,assign) CGFloat              htZRightArm;   //!< 右手阻抗值(Ω), 范围75.0 ~ 1500.0

@property (nonatomic,assign) CGFloat              htMusclePercentageTrunk;       //!< 躯干肌肉率(%), 分辨率0.1, 范围5.0% ~ 90.0%
@property (nonatomic,assign) CGFloat              htMusclePercentageLeftLeg;     //!< 左脚肌肉率(%), 分辨率0.1, 范围5.0% ~ 90.0%
@property (nonatomic,assign) CGFloat              htMusclePercentageRightLeg;    //!< 右脚肌肉率(%), 分辨率0.1, 范围5.0% ~ 90.0%
@property (nonatomic,assign) CGFloat              htMusclePercentageLeftArm;     //!< 左手肌肉率(%), 分辨率0.1, 范围5.0% ~ 90.0%
@property (nonatomic,assign) CGFloat              htMusclePercentageRightArm;    //!< 右手肌肉率(%), 分辨率0.1, 范围5.0% ~ 90.0%

@property (nonatomic,assign) CGFloat              htBodyfatPercentageTrunk;      //!< 躯干脂肪率(%), 分辨率0.1, 范围5.0% ~ 75.0%
@property (nonatomic,assign) CGFloat              htBodyfatPercentageLeftLeg;    //!< 左脚脂肪率(%), 分辨率0.1, 范围5.0% ~ 75.0%
@property (nonatomic,assign) CGFloat              htBodyfatPercentageRightLeg;   //!< 右脚脂肪率(%), 分辨率0.1, 范围5.0% ~ 75.0%
@property (nonatomic,assign) CGFloat              htBodyfatPercentageLeftArm;    //!< 左手脂肪率(%), 分辨率0.1, 范围5.0% ~ 75.0%
@property (nonatomic,assign) CGFloat              htBodyfatPercentageRightArm;   //!< 右手脂肪率(%), 分辨率0.1, 范围5.0% ~ 75.0%

@property (nonatomic,assign) CGFloat              htMuscleKgTrunk;               //!< 躯干肌肉量(kg), 分辨率0.1, 范围0.0 ~ 200kg
@property (nonatomic,assign) CGFloat              htMuscleKgeLeftLeg;            //!< 左脚肌肉量(kg), 分辨率0.1, 范围0.0 ~ 200kg
@property (nonatomic,assign) CGFloat              htMuscleKgRightLeg;            //!< 右脚肌肉量(kg), 分辨率0.1, 范围0.0 ~ 200kg
@property (nonatomic,assign) CGFloat              htMuscleKgLeftArm;             //!< 左手肌肉量(kg), 分辨率0.1, 范围0.0 ~ 200kg
@property (nonatomic,assign) CGFloat              htMuscleKgRightArm;            //!< 右手肌肉量(kg), 分辨率0.1, 范围0.0 ~ 200kg

@property (nonatomic,assign) CGFloat              htBodyfatKgTrunk;              //!< 躯干脂肪量(kg), 分辨率0.1, 范围0.0 ~ 200kg
@property (nonatomic,assign) CGFloat              htBodyfatKgLeftLeg;            //!< 左脚脂肪量(kg), 分辨率0.1, 范围0.0 ~ 200kg
@property (nonatomic,assign) CGFloat              htBodyfatKgRightLeg;           //!< 右脚脂肪量(kg), 分辨率0.1, 范围0.0 ~ 200kg
@property (nonatomic,assign) CGFloat              htBodyfatKgLeftArm;            //!< 左手脂肪量(kg), 分辨率0.1, 范围0.0 ~ 200kg
@property (nonatomic,assign) CGFloat              htBodyfatKgRightArm;           //!< 右手脂肪量(kg), 分辨率0.1, 范围0.0 ~ 200kg


@end

#pragma mark - HTBodyResultTwoArms
/**
 * 双手的测量结果类
 */
@interface HTBodyResultTwoArms : HTBodyResult

@property (nonatomic,assign) CGFloat              htZTwoArms;    //!< 手对手阻抗值(Ω), 范围200.0 ~ 1200.0

@end

#pragma mark - HTBodyResultArmsLegs
/**
 * 双手双脚的测量结果类，预留
 */
@interface HTBodyResultArmsLegs : HTBodyResult


@end


