import 'package:ailink_example/weight_data.dart';
import 'dart:math' as math;

class BroadcastScaleDataUtils {
  int _oldNumberId = -1;
  int _oldStatus = -1;

  static const int UNIT_ST = 4;

  static BroadcastScaleDataUtils? _instance;

  BroadcastScaleDataUtils._() {
    _instance = this;
  }

  factory BroadcastScaleDataUtils() => _instance ?? BroadcastScaleDataUtils._();

  WeightData? getWeightData(List<int>? data) {
    if (data != null && data.length > 9) {
      int numberId = data[0] & 0xff;
      int status = data[1] & 0xff;

      if (_oldNumberId == numberId && _oldStatus == status) {
        // The data is the same, and the type is the same. It has been processed and will not be processed again.
        return null;
      }

      _oldNumberId = numberId;
      _oldStatus = status;
      // Temperature unit: 0=℃, 1=℉
      int tempUnit = _getBits(data[2], 6, 1);
      // Weight unit:
      // 0000: kg
      // 0001: Jin
      // 0100: st:lb
      // 0110: lb
      int weightUnit = _getBits(data[2], 3, 3);
      // Decimal points in weight:
      // 00: No decimal point
      // 01: 1 decimal point
      // 10: 2 decimal points
      // 11: 3 decimal points
      int weightDecimal = _getBits(data[2], 1, 2);
      // 0: Real-time weight, 1: Stable weight
      int weightStatus = _getBits(data[2], 0, 1);
      // The highest bit = 0: Positive weight, 1: Negative weight
      int weightNegative = _getBits(data[3], 7, 1);
      // Weight, big-endian
      int weight = ((data[3] & 0x7f) << 8) | (data[4] & 0xff);
      // Impedance, big-endian
      int adc = ((data[5] & 0xff) << 8) + (data[6] & 0xff);
      // Body fat scale algorithm ID
      int algorithmId = data[7] & 0xff;
      // The highest bit = 0: Positive temperature, 1: Negative temperature
      int tempNegative = _getBits(data[8], 7, 1);
      int temp = ((data[8] & 0x7f) << 8) + (data[9] & 0xff);

      if (tempNegative == 1 && temp == 4095) {
        // No temperature measurement, indicated by 0xFFFF
        tempNegative = -1;
        temp = -1;
      }
      return WeightData(
        status,
        tempUnit,
        weightUnit,
        _weightUnitToString(weightUnit),
        weightDecimal,
        weightStatus,
        weightNegative,
        weight,
        _realWeight(weight, weightDecimal),
        adc,
        algorithmId,
        tempNegative,
        temp,
      );
    }
    return null;
  }

  String _realWeight(int data, int decimal) {
    if (decimal > 0) {
      final result = data / math.pow(10, decimal);
      return result.toStringAsFixed(decimal);
    }
    return data.toString();
  }

  String _weightUnitToString(int unit) {
    if (unit == 0) {
      return 'kg';
    }
    if (unit == 1) {
      return '斤';
    }
    if (unit == 6) {
      return 'lb';
    }
    return 'st:lb';
  }

  int _getBits(int b, int start, int length) {
    return (b >> start) & ((1 << length) - 1);
  }
}
