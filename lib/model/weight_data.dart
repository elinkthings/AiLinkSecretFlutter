class WeightData {
  /// 0x00: Start testing
  /// 0x01: Measuring weight (impedance value is 0 at this time)
  /// 0x02: Measuring impedance (impedance value is 0 at this time)
  /// 0x03: Impedance measurement successful
  /// 0x04: Impedance measurement failed (impedance value is 0xFFFF at this time)
  /// 0xFF: Test completed
  int status;
  int tempUnit; //Temperature unit 0=℃, 1=℉
  int weightUnit; //Weight unit
  String weightUnitStr;
  int weightDecimal; //Weight decimal point
  int weightStatus; //0: Real-time weight, 1: Stable weight
  int weightNegative; //0: Positive weight; 1: Negative weight
  int weight; //Raw data
  String weightStr;
  int adc; //Impedance, 65535 indicates impedance measurement failure
  int algorithmId; //Algorithm ID
  int tempNegative; //0: Positive temperature; 1: Negative temperature; -1 means not supported
  int temp; //Temperature value, precision 0.1; -1 means not supported

  WeightData(
    this.status,
    this.tempUnit,
    this.weightUnit,
    this.weightUnitStr,
    this.weightDecimal,
    this.weightStatus,
    this.weightNegative,
    this.weight,
    this.weightStr,
    this.adc,
    this.algorithmId,
    this.tempNegative,
    this.temp,
  );

  String get statusStr {
    switch (status) {
      case 0x00:
        return 'Start testing';
      case 0x01:
        return 'Measuring weight';
      case 0x02:
        return 'Measuring impedance';
      case 0x03:
        return 'Impedance measurement successful';
      case 0x04:
        return 'Impedance measurement failed';
      case 0xFF:
        return 'Test completed';
      default:
        return 'Unknown status';
    }
  }

  bool get isAdcError => adc == 65535 || adc == 0;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['status'] = status;
    data['tempUnit'] = tempUnit;
    data['weightUnit'] = weightUnit;
    data['weightUnitStr'] = weightUnitStr;
    data['weightDecimal'] = weightDecimal;
    data['weightStatus'] = weightStatus;
    data['weightNegative'] = weightNegative;
    data['weight'] = weight;
    data['weightStr'] = weightStr;
    data['adc'] = adc;
    data['algorithmId'] = algorithmId;
    data['tempNegative'] = tempNegative;
    data['temp'] = temp;
    return data;
  }
}
