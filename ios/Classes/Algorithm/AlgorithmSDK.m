//
//  Algorithm.m
//  GreatBody
//
//  Created by steven wu on 2019/6/25.
//

#import "AlgorithmSDK.h"
#import "HTBodyfat_SDK.h"

@implementation AlgorithmModel

@end


@implementation AlgorithmSDK


+ (AlgorithmModel *)getBodyfatWithWeight:(double)kgWeight adc:(int)adc sex:(AlgUserSex)sex age:(int)age height:(int)height algNum:(NSInteger)algNum{
    AlgorithmModel *bodymodel = [[AlgorithmModel alloc] init];
    
    if (kgWeight > 0 && kgWeight <= 220 &&
        age >= 0 && age <= 120 &&
        height > 0 && height < 270 &&
        (sex == AlgUserSex_Male || sex == AlgUserSex_Female) &&
        adc > 0 && adc <= 1000) {
        
        if (algNum == 1) {
            //品网晶华微算法
            bodymodel = [self getBodyfatWithWeight:kgWeight adc:adc sex:sex age:age height:height];
        }else if (algNum == 2){
            //HT算法
            bodymodel = [self getHTBodyfatWithWeight:kgWeight adc:adc sex:sex age:age height:height];
        }else{
            //默认品网晶华微算法
            bodymodel = [self getBodyfatWithWeight:kgWeight adc:adc sex:sex age:age height:height];
        }
        
    }else{
        NSString *log = [NSString stringWithFormat:@"input invalid params: weight[%f], adc[%d], sex[%zd], age[%d], height[%d]",kgWeight,adc,sex,age,height];
        NSLog(@"[INET☀️]%@",log);
    }
    
    return bodymodel;
}
#pragma mark ============ HT算法 序列2 ==============
+(AlgorithmModel *)getHTBodyfatWithWeight:(double)kgWeight adc:(int)adc sex:(AlgUserSex)sex age:(int)age height:(int)height{
    AlgorithmModel *bodymodel = [[AlgorithmModel alloc] init];
    if (kgWeight > 0 && kgWeight <= 220 &&
        age >= 0 && age <= 120 &&
        height > 0 && height < 270 &&
        (sex == AlgUserSex_Male || sex == AlgUserSex_Female) &&
        adc > 0 && adc <= 1000) {
        
        HTSexType htSex = HTSexTypeFemale;
        if (sex == AlgUserSex_Female) {
            htSex = HTSexTypeFemale;
        }else{
            htSex = HTSexTypeMale;
        }
        HTBodyBasicInfo *bodyBasicInfo = [[HTBodyBasicInfo alloc]initWithSex:htSex height:height weight:kgWeight age:age];

        bodyBasicInfo.htZAllBodyImpedance = adc;
        bodyBasicInfo.htZLeftLegImpedance = adc;
        bodyBasicInfo.htZRightLegImpedance = adc;
        bodyBasicInfo.htZLeftArmImpedance = adc;
        bodyBasicInfo.htZRightArmImpedance = adc;
        //计算
        HTBodyResultAllBody *bodyResultTwoLegs = [[HTBodyResultAllBody alloc]init];
        //显示体脂参数
        HTBodyfatErrorType errorType = [bodyResultTwoLegs getBodyfatWithBasicInfo:bodyBasicInfo];
        NSLog(@"HTBodyfatErrorType = %lu",errorType);
        if(errorType != HTBodyfatErrorTypeNone){
            NSMutableString *errorStr = [[NSMutableString alloc]initWithString:@""];
            if((errorType & HTBodyfatErrorTypeAge) == HTBodyfatErrorTypeAge){
                [errorStr appendString:@"年龄 "];
            }
            if((errorType & HTBodyfatErrorTypeWeight) == HTBodyfatErrorTypeWeight){
                [errorStr appendString:@"体重 "];
            }
            if((errorType & HTBodyfatErrorTypeHeight) == HTBodyfatErrorTypeHeight){
                [errorStr appendString:@"身高 "];
            }
            if((errorType & HTBodyfatErrorTypeSex) == HTBodyfatErrorTypeSex){
                [errorStr appendString:@"性别 "];
            }
            if((errorType & HTBodyfatErrorTypeImpedance) == HTBodyfatErrorTypeImpedance){
                [errorStr appendString:@"阻抗 "];
            }
            if((errorType & HTBodyfatErrorTypeImpedanceLeftLeg) == HTBodyfatErrorTypeImpedanceLeftLeg){
                [errorStr appendString:@"左脚阻抗 "];
            }
            if((errorType & HTBodyfatErrorTypeImpedanceRightLeg) == HTBodyfatErrorTypeImpedanceRightLeg){
                [errorStr appendString:@"右脚阻抗 "];
            }
            if((errorType & HTBodyfatErrorTypeImpedanceLeftArm) == HTBodyfatErrorTypeImpedanceLeftArm){
                [errorStr appendString:@"左手阻抗 "];
            }
            if((errorType & HTBodyfatErrorTypeImpedanceRightArm) == HTBodyfatErrorTypeImpedanceRightArm){
                [errorStr appendString:@"右手阻抗 "];
            }
            [errorStr appendString:@"参数有误！"];
            
            NSLog(@"errorType = %@",errorStr);
        }
        
        bodymodel.bmi = [NSString stringWithFormat:@"%.1f",bodyResultTwoLegs.htBMI];
        bodymodel.bfr = [NSString stringWithFormat:@"%.1f",bodyResultTwoLegs.htBodyfatPercentage];
        bodymodel.sfr = [NSString stringWithFormat:@"%.1f",bodyResultTwoLegs.htBodyfatSubcut];
        bodymodel.uvi = [NSString stringWithFormat:@"%ld",bodyResultTwoLegs.htVFAL];
        bodymodel.rom = [NSString stringWithFormat:@"%.1f",bodyResultTwoLegs.htMusclePercentage];
        bodymodel.bmr = [NSString stringWithFormat:@"%ld",bodyResultTwoLegs.htBMR];
        bodymodel.bm = [NSString stringWithFormat:@"%.1f",bodyResultTwoLegs.htBoneKg];
        bodymodel.vwc = [NSString stringWithFormat:@"%.1f",bodyResultTwoLegs.htWaterPercentage];
        bodymodel.physicalAge = [NSString stringWithFormat:@"%ld",bodyResultTwoLegs.htBodyAge];
        bodymodel.pp = [NSString stringWithFormat:@"%.1f",bodyResultTwoLegs.htProteinPercentage];
        
    }else{
        NSString *log = [NSString stringWithFormat:@"input invalid params: weight[%f], adc[%d], sex[%zd], age[%d], height[%d]",kgWeight,adc,sex,age,height];
        NSLog(@"[INET☀️]%@",log);
    }
    return bodymodel;
}

#pragma mark ====== 晶华微算法 序列1
/**
 *     晶华微的算法--序列号为 1
 *     秤返回506，小数点1位，则originKgWeight=50.6 //性别0或2都是女的
 */
+ (AlgorithmModel *)getBodyfatWithWeight:(double)kgWeight adc:(int)adc sex:(AlgUserSex)sex age:(int)age height:(int)height {
    
    double      weight      = kgWeight;
    float       userAge     = age;
    float       userHeight  = height;
    AlgUserSex  userSex     = sex;
    
    AlgorithmModel *bodymodel = [[AlgorithmModel alloc] init];
    
    if (weight > 0 && weight <= 220 &&
        userAge >= 0 && userAge <= 120 &&
        userHeight > 0 && userHeight < 270 &&
        (userSex == AlgUserSex_Male || userSex == AlgUserSex_Female) &&
        adc > 0 && adc <= 1000) {

        double hei = [self getHeight:userHeight];
        double bmi = [[self getBMI:weight height:hei] doubleValue];
        double bm  = [self getBM:userSex bmi:bmi height:hei age:userAge adc:adc weight:weight];
        double rom = [self getROM:userSex weight:weight height:hei age:userAge adc:adc];
        double moi = [self getMOI:userSex bmi:bmi adc:adc age:userAge];
        double bfr = [self getBFR:userSex bmi:bmi adc:adc age:userAge];
        double sfr = [self getSFR:userSex age:userAge bfr:bfr];
        double pp  = [self getPP:bfr moi:moi bm:bm weight:weight age:userAge sex:userSex];
        NSInteger uvi    = [self getUVI:userSex weight:weight height:hei age:userAge adc:adc];
        NSInteger bmr = [self getBMR:userSex weight:weight height:hei age:userAge adc:adc];
        NSInteger physicalAge     = [self getPA:userAge bmi:bmi sex:userSex];
        
        bodymodel.bmi = [self returnOneDecimalUp:bmi];//bmi已经是1位小数,此处调用只是为了转为string
        bodymodel.bm  = [self returnOneDecimal:bm];
        bodymodel.rom = [self returnOneDecimal:rom];
        bodymodel.vwc = [self returnOneDecimal:moi];
        bodymodel.bfr = [self returnOneDecimalUp:bfr];
        bodymodel.sfr = [self returnOneDecimal:sfr];
        bodymodel.pp  = [self returnOneDecimal:pp];
        bodymodel.uvi = [NSString stringWithFormat:@"%zd", uvi];
        bodymodel.bmr = [NSString stringWithFormat:@"%zd",bmr];
        bodymodel.physicalAge  = [NSString stringWithFormat:@"%zd",physicalAge];
        
    } else {
        NSString *log = [NSString stringWithFormat:@"input invalid params: weight[%f], adc[%d], sex[%zd], age[%d], height[%d]",kgWeight,adc,sex,age,height];
        NSLog(@"[INET☀️]%@",log);
    }
    
    return bodymodel;
}



/**
 计算身高(cm -> m)
 
 @param height 例如：175
 @return 例如：1.75
 */
+ (double)getHeight:(NSInteger)height {
    
    return (double)height/100.0;
}



/**
 计算bmi
 */
+ (NSString *)getBMI:(double)weight height:(double)height {
    double bmi = weight/(height*height);
    return [self returnOneDecimalUp:bmi];
}


/**
 计算骨量(bone mass)
 */
+ (double)getBM:(NSInteger)sex bmi:(double)bmi height:(double)height age:(NSInteger)age adc:(NSInteger)adc weight:(double)weight {
    double bm = 1.0; //何俊新算法：0 -》1.0
    if (age < 10) {
        return bm;
    }
    
    if (age < 15) {// 年齡小於15
        switch (sex) {
            case AlgUserSex_Male:
                bm = 0.015 * weight + (2 - 0.00055 * adc) * height + 0.035 * age - 1.79;
                break;
            case AlgUserSex_Female:
                bm = 0.000022 * adc * weight + (4.99 - 0.00284 * adc) * height + 0.0012 * adc - 4.45;
                break;
        }
    } else {// 年齡大於等於15
        switch (sex) {
            case AlgUserSex_Male:
                bm = 0.015 * weight + (2 - 0.00055 * adc) * height - 1.15;
                break;
            case AlgUserSex_Female:
                bm = 0.000022 * adc * weight + (4.99 - 0.00284 * adc) * height + 0.0012 * adc - 4.45;
                break;
        }
    }
    
    if (bm < weight * 0.02) {
        bm = weight * 0.02;
    }
    if (bm > weight * 0.15) {
        bm = weight * 0.15;
    }
    if (bm<1.0){
        bm = 1.0;
    }
    return bm;
}

/**
 * 肌肉率
 */
+ (double)getROM:(NSInteger)sex weight:(double)weight height:(double)height age:(NSInteger)age adc:(NSInteger)adc {
    double rom = 5.0;
    if (age < 10) { // 年齡小於10
        return rom;
    }
    
    if (age < 16) {// 年齡小於16
        switch (sex) {
            case AlgUserSex_Male:
                rom = (0.0001262 * adc + 0.2196) * weight + (49.64 - 0.031 * adc) * height + 0.018 * adc + 0.52 * age - 46.5;
                break;
            case AlgUserSex_Female:
                rom = (0.0001555 * adc + 0.0448) * weight + (55.76 - 0.032 * adc) * height + 0.0225 * adc - 44.41;
                break;
        }
    } else {// 年齡大於等於16
        switch (sex) {
            case AlgUserSex_Male:
                rom = (0.0001262 * adc + 0.2196) * weight + (49.64 - 0.031 * adc) * height + 0.018 * adc - 36.12;
                break;
            case AlgUserSex_Female:
                rom = (0.0001555 * adc + 0.0448) * weight + (55.76 - 0.032 * adc) * height + 0.026 * adc - 45.51;
                break;
        }
    }
    
    if (rom > 75.0) {
        rom = 75.0;
    }
    if (rom < 15.0) {
        rom = 15.0;
    }
    return rom;
}

/**
 * 水分
 */
+ (double)getMOI:(NSInteger)sex bmi:(double)bmi adc:(NSInteger)adc age:(NSInteger)age {
    double moi = 60.0;
    if (age < 5) {
        return moi; //婴儿含水量设为默认60%
    } else {
        switch (sex) {
            case AlgUserSex_Male:
                moi = 1000000 / (bmi * (2.688 * adc - 78.28)) - 10058.0 / adc - 0.05 * age + 47.1;
                break;
            case AlgUserSex_Female:
                moi = 1000000 / (bmi * (2.467 * adc - 75.37)) - 14215.0 / adc - 0.034 * age + 43.2;
                break;
        }
        if (moi < 20) {
            moi =  20;
        }
        if (moi > 70) {
            moi =  70;
        }
        return moi;
    }
    
}

/**
 * 体脂率
 */
+(double)getBFR:(NSInteger)sex bmi:(double)bmi adc:(NSInteger)adc age:(NSInteger)age {
    double bfr = 5.0;
    if (age < 10) {
        return bfr;
    }
    if (age < 15) {// 年齡小於15
        switch (sex) {
            case AlgUserSex_Male:
                bfr = -1000000 / (bmi * (1.966 * adc - 58.46)) + 13176.0 / adc - 1.8 * age + 67.04;
                break;
            case AlgUserSex_Female:
                bfr = -1000000 / (bmi * (1.803 * adc - 45.22)) + 18911.0 / adc - 0.485 * age + 49.1;
                break;
        }
    } else {// 年齡大於等於15
        switch (sex) {
            case AlgUserSex_Male:
                bfr = -1000000 / (bmi * (1.966 * adc - 58.46)) + 13176.0 / adc + 0.067 * age + 36.79;
                break;
            case AlgUserSex_Female:
                bfr = -1000000 / (bmi * (1.803 * adc - 45.22)) + 18911.0 / adc + 0.046 * age + 41.5;
        }
    }
    if (bfr > 50) {
        return 50;
    }
    if (bfr < 5) {
        return 5;
    }
    return bfr;
    
}

/**
 * 皮下脂肪率
 */
+ (double)getSFR:(NSInteger)sex age:(NSInteger)age bfr:(double)bfr {
    double sfr = 10.0;
    if (age < 5) {
        return sfr;
    } else {
        switch (sex) {
            case AlgUserSex_Male:
                sfr = 0.898*bfr;
                break;
            case AlgUserSex_Female:
                sfr = 0.876*bfr+1.66;
                break;
        }
        if (sfr < 10.0) {
            sfr = 10;
        }
        return sfr;
    }
    
}

/**
 * 骨骼肌率(写法和安卓不一致,但此方法未调用,故不影响)
 */
+ (double)getROSM:(NSInteger)sex moi:(double)moi bfr:(double)bfr {
    double rosm = 0;
    switch (sex) {
        case AlgUserSex_Male:
            rosm = 0.895 * moi;
            break;
        case AlgUserSex_Female:
            rosm = 0.857 * moi-0.36;
            break;
    }
    return rosm;
}

/**
 * 蛋白率
 */
+ (double)getPP:(double)bfr moi:(double)moi bm:(double)bm weight:(double)weight age:(NSInteger)age sex:(NSInteger)sex{
    double pp = 10.0;
    if (age < 5) {
        return pp;
    } else {
        switch (sex) {
            case AlgUserSex_Male:
                pp = 0.8 * (100 - bfr - moi - bm / weight);
                break;
            case AlgUserSex_Female:
                pp = 0.75 * (100 - bfr - moi - bm / weight);
                break;
        }
        
        if (pp < 10.0) {
            pp = 10.0;
        }
        if (pp > 50.0) {
            pp = 50.0;
        }
        return pp;
    }
}

/**
 * 内脏脂肪指数
 */
+ (NSInteger)getUVI:(NSInteger)sex weight:(double)weight height:(double)height age:(NSInteger)age adc:(NSInteger)adc{
    double uvi = 1.0;
    if (age < 5) {
        return 1;
    } else {
        switch (sex) {
            case AlgUserSex_Male:
                uvi = 0.224 * weight - 25.58 * height + 0.151 * age + 0.005 * adc + 29.0;
                break;
            case AlgUserSex_Female:
                uvi = 0.183 * weight - 15.34 * height + 0.063 * age + 0.005 * adc + 14.2;
                break;
        }
        
        NSInteger result = (NSInteger)round(uvi);
        if (result < 1) {
            result = 1;
        }
        if (result > 20) {
            result = 20;
        }
        return result;
    }
    
}

/**
 * 基础代谢率
 */
+ (NSInteger)getBMR:(NSInteger)sex weight:(double)weight height:(double)height age:(NSInteger)age adc:(NSInteger)adc {
    double bmr = 0;
    if (age < 5) {
        return 0;
    } else {
        switch (sex) {
            case AlgUserSex_Male:
                bmr = (9.937 + 0.0015 * adc) * weight + (1350 - 0.88 * adc) * height + 3088.0 / age + 0.748 * adc - 1263;
                break;
            case AlgUserSex_Female:
                bmr = (0.00307 * adc + 7.194) * weight + (1459 - 0.989 * adc) * height + 3105.0 / age + 0.923 * adc - 1386;
                break;
        }
        return (NSInteger)round(bmr);
    }
    
}

/**
 * 身体年龄
 */
+ (NSInteger)getPA:(NSInteger)age bmi:(double)bmi sex:(NSInteger)sex{
    double pAge = 0;
    if (age < 18) {
        return age;
    }
    else {
        switch (sex) {
            case AlgUserSex_Male:
                if (bmi < 22) {
                    pAge = age * (1 + 0.04 * (bmi - 22));
                } else {
                    pAge = age * (1 + 0.02 * (bmi - 22));
                }
                break;
            case AlgUserSex_Female:
                if (bmi < 21.2) {
                    pAge = age * (1 + 0.04 * (bmi - 21.2));
                } else {
                    pAge = age * (1 + 0.02 * (bmi - 21.2));
                }
                break;
        }
        if (pAge < age - 10) {
            pAge = age - 10;
        }
        if (pAge > age + 10) {
            pAge = age + 10;
        }
        
        NSInteger ret = (NSInteger)round(pAge);
        return ret;
    }
    
}


/**
 保留一位小数，不四舍五入，向下取整，3.19 -> 3.1
 */
+ (NSString *)returnOneDecimal:(double)d {
    NSString *sv = [NSString stringWithFormat:@"%.1f", floor(d * 10) / 10];
    return sv;
}


/**
 保留一位小数，使用四舍五入，即 3.13 -> 3.1 但 3.19 -> 3.2
 */
+ (NSString *)returnOneDecimalUp:(double)d {
    NSString *string = [NSString stringWithFormat:@"%.1lf",d]; //占位符%.1lf作用：把d四舍五入保留一位小数后输出。%f格式化float、%lf格式化double
    return string;
}


@end
