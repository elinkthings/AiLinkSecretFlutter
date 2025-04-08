import 'package:ailink/model/elink_ble_data.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class ConnectDeviceModel {
  final BluetoothDevice device;
  final ElinkBleData bleData;

  ConnectDeviceModel({
    required this.device,
    required this.bleData,
  });
}
