import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

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

extension BluetoothConnectionStateExtension on BluetoothConnectionState {
  bool get isConnected => this == BluetoothConnectionState.connected;
}

extension StringExtension on String? {
  bool get isNullOrEmpty => this == null || this!.isEmpty || this == 'null';
}