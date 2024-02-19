import 'package:flutter_blue_plus/flutter_blue_plus.dart';

extension BluetoothConnectionStateExtension on BluetoothConnectionState {
  bool get isConnected => this == BluetoothConnectionState.connected;
}