class ParamBodyFatData {
  double weight;
  int adc;
  int sex;
  int age;
  int height;
  int algNum;

  ParamBodyFatData(this.weight, this.adc, this.sex, this.age, this.height, this.algNum);

  String toJson() {
    final data = <String, dynamic>{};
    data['weight'] = weight;
    data['adc'] = adc;
    data['sex'] = sex;
    data['age'] = age;
    data['height'] = height;
    data['algNum'] = algNum;
    return '{"weight": $weight, "adc": $adc, "sex": $sex, "age": $age, "height": $height, "algNum": $algNum}';
  }
}
