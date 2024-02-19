import 'package:flutter/services.dart';

extension Uint8ListExtension on Uint8List {
  String toHex() {
    return map(
          (byte) => '0x${(byte.toRadixString(16).padLeft(2, '0')).toUpperCase()}',
    ).join(',');
  }
}

extension ListIntExtension on List<int> {
  String toHex() {
    return map(
          (byte) => '0x${(byte.toRadixString(16).padLeft(2, '0')).toUpperCase()}',
    ).join(',');
  }
}

extension StringExtension on String? {
  bool get isNullOrEmpty => this == null || this!.isEmpty || this == 'null';

  bool equal(String str, {bool ignoreCase = true}) {
    if (ignoreCase) {
      return this?.toLowerCase() == str.toLowerCase();
    }
    return this == str;
  }
}