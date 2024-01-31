import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleStateWidget extends StatelessWidget {
  final BluetoothDevice? bluetoothDevice;
  final Function? onPressed;

  const BleStateWidget({
    this.bluetoothDevice,
    this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<BluetoothAdapterState>(
      initialData: FlutterBluePlus.adapterStateNow,
      stream: FlutterBluePlus.adapterState,
      builder: (context, snapshot) {
        final bool isBluetoothOn = snapshot.hasData && snapshot.data == BluetoothAdapterState.on;
        return StreamBuilder<BluetoothConnectionState>(
          initialData: BluetoothConnectionState.disconnected,
          stream: bluetoothDevice?.connectionState,
          builder: (context, snapshot) {
            final bool isConnect = snapshot.hasData && snapshot.data == BluetoothConnectionState.connected;
            return IconButton(
              onPressed: () {
                if (Platform.isAndroid && !isBluetoothOn) {
                  FlutterBluePlus.turnOn();
                }
                if (!isConnect) {
                  onPressed?.call();
                }
              },
              icon: Icon(
                isBluetoothOn
                    ? (isConnect ? Icons.bluetooth_connected : Icons.bluetooth)
                    : Icons.bluetooth_disabled,
                color: Colors.white,
              ),
            );
          },
        );
      },
    );
  }
}
