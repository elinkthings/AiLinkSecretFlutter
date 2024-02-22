import 'package:ailink/model/elink_ble_data.dart';
import 'package:ailink/utils/elink_cmd_utils.dart';

class ElinkBroadcastDataUtils {
  /// 解析蓝牙广播数据获取cid,vid,pid和mac
  /// Parse Bluetooth broadcast data to obtain cid, vid, pid and mac
  static ElinkBleData getElinkBleData(
    List<int> manufacturerData, {
    bool isBroadcastDevice = false,
  }) {
    final cid = List.filled(2, 0);
    final vid = List.filled(2, 0);
    final pid = List.filled(2, 0);
    final mac = List.filled(6, 0);
    final length = manufacturerData.length;
    if (isBroadcastDevice && length >= 3) {
      int start = 0;
      cid.setRange(1, cid.length, manufacturerData.sublist(start, start += 1));
      vid.setRange(1, vid.length, manufacturerData.sublist(start, start += 1));
      pid.setRange(1, pid.length, manufacturerData.sublist(start, start += 1));
      if (length >= 10) {
        mac.setRange(0, mac.length, manufacturerData.sublist(start, start + mac.length));
      }
    } else if (manufacturerData[0] == 0x6E && manufacturerData[1] == 0x49 && length >= 14) {
      int start = 2;
      cid.setRange(0, cid.length, manufacturerData.sublist(start, start += cid.length));
      vid.setRange(0, vid.length, manufacturerData.sublist(start, start += vid.length));
      pid.setRange(0, pid.length, manufacturerData.sublist(start, start += pid.length));
      mac.setRange(0, mac.length, manufacturerData.sublist(start, start + mac.length));
    }
    return ElinkBleData(cid, vid, pid, mac);
  }

  static String littleBytes2MacStr(List<int> bytes) {
    StringBuffer stringBuffer = StringBuffer();
    for (int i = bytes.length - 1; i >= 0; i--) {
      final byteStr = bytes[i].toRadixString(16).padLeft(2, '0').toUpperCase();
      if (i != 0) {
        stringBuffer.write('$byteStr:');
      } else {
        stringBuffer.write(byteStr);
      }
    }
    return stringBuffer.toString();
  }

  static List<int> getManufacturerData(Map<int, List<int>> data) {
    return data.entries
        .map((entry) {
          List<int> manufacturerData = ElinkCmdUtils.intToBytes(entry.key, length: 2);
          List<int> results = List.empty(growable: true);
          if (manufacturerData[0] == 0x6E && manufacturerData[1] == 0x49) {
            results.addAll(manufacturerData);
            results.addAll(entry.value);
          }
          return results;
        })
        .expand((element) => element)
        .toList();
  }
}
