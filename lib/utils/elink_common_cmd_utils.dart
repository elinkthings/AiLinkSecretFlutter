import 'package:ailink/utils/elink_cmd_utils.dart';

class ElinkCommonCmdUtils {

  static List<int> getElinkBmVersion() {
    final payload = [0x0E];
    return ElinkCmdUtils.getElinkA6Data(payload);
  }

  static List<int> clearElinkHandShake() {
    final payload = List.filled(3, 0);
    payload[0] = 0x42;
    payload[1] = 0x01;
    return ElinkCmdUtils.getElinkA6Data(payload);
  }

  static List<int> restartElinkBleModule() {
    final payload = [0x21, 0x01];
    return ElinkCmdUtils.getElinkA6Data(payload);
  }
}