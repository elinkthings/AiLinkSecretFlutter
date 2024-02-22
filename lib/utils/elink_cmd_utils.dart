import 'dart:typed_data';

import 'package:ailink/ailink.dart';

class ElinkCmdUtils {
  static const int elinkDataA6Start = 0xA6;
  static const int elinkData6AEnd = 0x6A;
  static const int elinkDataA7Start = 0xA7;
  static const int elinkData7AEnd = 0x7A;

  static List<int> getElinkA6Data(List<int> payload) {
    /*if (payload.length > 16) {
      throw Exception(
          'GetElinkA6Data error: The maximum length of payload is 16!');
    }*/
    final result = List.filled(4 + payload.length, 0);
    result[0] = elinkDataA6Start;
    final mutablePayload = List<int>.from(payload);
    mutablePayload.insert(0, mutablePayload.length);
    result.setRange(1, mutablePayload.length + 1, mutablePayload);
    result[result.length - 2] = getElinkCmdSum(mutablePayload);
    result[result.length - 1] = elinkData6AEnd;
    return result;
  }

  static Future<List<int>> getElinkA7Data(
    List<int> cid,
    List<int> mac,
    List<int> payload,
  ) async {
    final encryptPayload = await Ailink().mcuEncrypt(Uint8List.fromList(cid), Uint8List.fromList(mac), Uint8List.fromList(payload));
    final result = List.filled(4 + cid.length + encryptPayload.length, 0);
    result[0] = elinkDataA7Start;
    final mutablePayload = List<int>.from(encryptPayload);
    mutablePayload.insert(0, encryptPayload.length);
    mutablePayload.insertAll(0, cid);
    result.setRange(1, mutablePayload.length + 1, mutablePayload);
    result[result.length - 2] = getElinkCmdSum(mutablePayload);
    result[result.length - 1] = elinkData7AEnd;
    return result;
  }

  static List<int> getElinkDateTime({DateTime? date}) {
    DateTime now = date ?? DateTime.now();
    int year = now.year - 2000;
    int month = now.month;
    int day = now.day;
    int hour = now.hour;
    int minute = now.minute;
    int second = now.second;
    int weekday = now.weekday; // 1=Monday, 7=Sunday
    return [year, month, day, hour, minute, second, weekday];
  }

  static int getElinkCmdSum(List<int> payload) {
    return payload.fold(0, (prev, element) => prev + element) & 0xFF;
  }

  static bool checkElinkCmdSum(List<int> data) {
    final payload = data.sublist(1, data.length - 2);
    final sum = getElinkCmdSum(payload);
    return sum == (data[data.length - 2] & 0xFF);
  }

  static bool isElinkA6Data(List<int> data) =>
      data.first == elinkDataA6Start && data.last == elinkData6AEnd;

  static bool isElinkA7Data(List<int> data) =>
      data.first == elinkDataA7Start && data.last == elinkData7AEnd;

  /// Format A6 data, remove header, trailer and checksum
  static List<int> formatA6Data(List<int> data) {
    List<int> returnData = [];
    int startIndex = 2;
    //有包头, 长度
    int two = data[1] & 0xFF;
    if (data.length >= (two + startIndex)) {
      returnData = data.sublist(startIndex, two + startIndex);
    }
    return returnData;
  }

  /// Format A7 data, remove CID, packet header, packet trailer and checksum
  static List<int> formatA7Data(List<int> data) {
    List<int> returnData = [];
    int startIndex = 4;
    //有包头, 2cid, 长度
    int two = data[3] & 0xFF;
    if (data.length >= (two + startIndex)) {
      returnData = data.sublist(startIndex, two + startIndex);
    }
    return returnData;
  }

  static List<int> intToBytes(
    int value, {
    int length = 4,
    bool littleEndian = true,
  }) {
    List<int> bytes = [];
    if (littleEndian) {
      for (int i = 0; i < length; i++) {
        bytes.add((value >> (i * 8)) & 0xFF);
      }
    } else {
      for (int i = length - 1; i >= 0; i--) {
        bytes.add((value >> (i * 8)) & 0xFF);
      }
    }
    return bytes;
  }

  static List<int> doubleToBytes(double value, {bool littleEndian = true}) {
    var buffer = ByteData(8);
    buffer.setFloat64(0, value, littleEndian ? Endian.little : Endian.big);
    return buffer.buffer.asUint8List();
  }

  static int bytesToInt(List<int> bytes, {bool littleEndian = true}) {
    int value = 0;
    int length = bytes.length;
    if (littleEndian) {
      for (int i = 0; i < length; i++) {
        value += bytes[i] << (i * 8);
      }
    } else {
      for (int i = 0; i < length; i++) {
        value += bytes[i] << ((length - 1 - i) * 8);
      }
    }
    return value;
  }

  static double bytesToDouble(List<int> bytes, {bool littleEndian = true}) {
    var buffer = ByteData.sublistView(Uint8List.fromList(bytes));
    return buffer.getFloat64(0, littleEndian ? Endian.little : Endian.big);
  }
}
