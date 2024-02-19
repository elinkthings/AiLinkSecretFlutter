import 'dart:async';
import 'dart:typed_data';

import 'package:ailink/ailink.dart';
import 'package:ailink/utils/common_extensions.dart';
import 'package:ailink/utils/ble_common_util.dart';
import 'package:ailink_example/utils/extensions.dart';
import 'package:ailink_example/widgets/widget_ble_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class ConnectDevicePage extends StatefulWidget {
  const ConnectDevicePage({super.key});

  @override
  State<ConnectDevicePage> createState() => _ConnectDevicePageState();
}

class _ConnectDevicePageState extends State<ConnectDevicePage> {
  final logList = <String>[];

  final _ailinkPlugin = Ailink();

  BluetoothDevice? _bluetoothDevice;
  StreamSubscription<BluetoothConnectionState>? _connectionStateSubscription;
  StreamSubscription<List<int>>? _onReceiveDataSubscription;

  @override
  void initState() {
    super.initState();
    _addLog('initState');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _addLog('addPostFrameCallback');
      _bluetoothDevice = ModalRoute.of(context)?.settings.arguments as BluetoothDevice;
      _connectionStateSubscription = _bluetoothDevice?.connectionState.listen((state) {
        if (state.isConnected) {
          _addLog('Connected');
          _bluetoothDevice?.discoverServices().then((services) {
            _addLog('DiscoverServices success: ${services.map((e) => e.serviceUuid).join(',').toUpperCase()}');
            if (services.isNotEmpty) {
              _setNotify(services);
            }
          }, onError: (error) {
            _addLog('DiscoverServices error');
          });
        } else {
          _addLog('Disconnected: code(${_bluetoothDevice?.disconnectReason?.code}), desc(${_bluetoothDevice?.disconnectReason?.description})');
        }
      });
      _bluetoothDevice?.connect();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _bluetoothDevice?.advName ?? 'Unknown',
              style: const TextStyle(fontSize: 18),
            ),
            StreamBuilder<BluetoothConnectionState>(
              initialData: BluetoothConnectionState.disconnected,
              stream: _bluetoothDevice?.connectionState,
              builder: (context, snapshot) {
                final state = snapshot.data ?? BluetoothConnectionState.disconnected;
                return Text(
                  state.isConnected ? 'Connected' : 'Disconnected',
                  style: const TextStyle(fontSize: 14),
                );
              },
            )
          ],
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
        actions: [
          BleStateWidget(
            bluetoothDevice: _bluetoothDevice,
            onPressed: () {
              _bluetoothDevice?.connect();
            },
          ),
        ],
      ),
      body: ListView.separated(
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Text(
              '$index: ${logList[index]}',
              style: TextStyle(
                color: index % 2 == 0 ? Colors.black : Colors.black87,
                fontSize: 16
              ),
            ),
          );
        },
        separatorBuilder: (context, index) {
          return const Divider(
            height: 0.5,
            color: Colors.grey,
          );
        },
        itemCount: logList.length,
      ),
    );
  }

  void _setNotify(List<BluetoothService> services) async {
    final service = services.firstWhere((service) => service.serviceUuid.str.equal(ElinkBleCommonUtils.elinkConnectDeviceUuid));
    _addLog('_setNotify characteristics: ${service.characteristics.map((e) => e.uuid).join(',').toUpperCase()}');
    for (var characteristic in service.characteristics) {
      if (characteristic.uuid.str.equal(ElinkBleCommonUtils.elinkNotifyUuid) || characteristic.uuid.str.equal(ElinkBleCommonUtils.elinkWriteAndNotifyUuid)) {
        _addLog('_setNotify characteristics uuid: ${characteristic.uuid}');
        await characteristic.setNotifyValue(true);
        if (characteristic.uuid.str.equal(ElinkBleCommonUtils.elinkWriteAndNotifyUuid)) {
          _onReceiveDataSubscription = characteristic.onValueReceived.listen((data) {
            _addLog('OnValueReceived: ${data.toHex()}');
            if (ElinkBleCommonUtils.isSetHandShakeCmd(data)) {
              _replyHandShake(characteristic, data);
            }
            if (ElinkBleCommonUtils.isGetHandShakeCmd(data)) {
              Future.delayed(const Duration(milliseconds: 500), () async {
                final handShakeStatus = await _ailinkPlugin.checkHandShakeStatus(Uint8List.fromList(data));
                _addLog('handShakeStatus: $handShakeStatus');
              });
            }

          });
          await _setHandShake(characteristic);
        }
      }
    }
  }

  Future<void> _setHandShake(BluetoothCharacteristic characteristic) async {
    Uint8List data = (await _ailinkPlugin.initHandShake()) ?? Uint8List(0);
    _addLog('_setHandShake: ${data.toHex()}');
    await characteristic.write(data.toList(), withoutResponse: true);
  }

  Future<void> _replyHandShake(BluetoothCharacteristic characteristic, List<int> data) async {
    Uint8List replyData = (await _ailinkPlugin.getHandShakeEncryptData(Uint8List.fromList(data))) ?? Uint8List(0);
    _addLog('_replyHandShake: ${replyData.toHex()}');
    await characteristic.write(replyData.toList(), withoutResponse: true);
  }

  void _addLog(String log) {
    if(mounted) {
      setState(() {
        logList.add(log);
      });
    }
  }

  @override
  void dispose() {
    _bluetoothDevice?.disconnect();
    _bluetoothDevice = null;
    _onReceiveDataSubscription?.cancel();
    _connectionStateSubscription?.cancel();
    super.dispose();
  }
}
