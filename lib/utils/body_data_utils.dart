class BodyDataUtils {
  /// 标准体重
  /// @param: sex(1: male; Others: Female)
  /// @param: height(cm)
  /// @result: (kg)
  static double getStandardWeight(int sex, double height) {
    if (sex == 1) {
      return (height - 80) * 0.7;
    } else {
      return (height - 70) * 0.6;
    }
  }

  /// 体重控制量
  /// @param: weight(kg)
  /// @param: sex(1: male; Others: Female)
  /// @param: height(cm)
  /// @result: (positive number: lose weight, negative number: gain weight), kg
  static double getWeightControl(double weight, int sex, double height) {
    final standardWeight = getStandardWeight(sex, height);
    return weight - standardWeight;
  }

  /// 脂肪量
  /// @param: weight(kg)
  /// @param: bfr(体脂率 body fat rate)
  /// @result: (kg)
  static double getFatMass(double weight, double bfr) {
    return weight * bfr / 100;
  }

  /// 去脂体重
  /// @param: weight(kg)
  /// @param: bfr(体脂率 body fat rate)
  /// @result: (kg)
  static double getLeanBodyMass(double weight, double bfr) {
    double fatMass = getFatMass(weight, bfr);
    return weight - fatMass;
  }

  /// 肌肉量
  /// @param: weight(kg)
  /// @param: rom(肌肉率 muscle rate)
  /// @result: (kg)
  static double getMuscleMass(double weight, double rom) {
    return weight * rom / 100;
  }

  /// 蛋白量
  /// @param: weight(kg)
  /// @param: pp(蛋白率 protein rate)
  /// @result: (kg)
  static double getProteinMass(double weight, double pp) {
    return weight * pp / 100;
  }

  /// 肥胖等级 Obesity level
  /// @param: weight(kg)
  /// @param: sex(1: male; Others: Female)
  /// @param: height(cm)
  /// @result: ObesityLevel
  static ObesityLevel getObesityLevel(double weight, int sex, double height) {
    final standardWeight = getStandardWeight(sex, height);
    final result = (weight - standardWeight) / standardWeight;
    if (result < -0.2) {
      return ObesityLevel.underweight;
    } else if (result < -0.1) {
      return ObesityLevel.thin;
    } else if (result <= 0.1) {
      return ObesityLevel.standard;
    } else if (result <= 0.2) {
      return ObesityLevel.biased;
    } else {
      return ObesityLevel.overweight;
    }
  }
}

enum ObesityLevel {
  ///体重不足
  underweight,
  ///偏瘦
  thin,
  ///标准
  standard,
  ///偏重
  biased,
  ///超重
  overweight,
}
