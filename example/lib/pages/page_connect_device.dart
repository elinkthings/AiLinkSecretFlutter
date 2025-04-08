import 'dart:async';
import 'dart:typed_data';

import 'package:ailink/ailink.dart';
import 'package:ailink/impl/elink_common_data_parse_callback.dart';
import 'package:ailink/model/elink_ble_data.dart';
import 'package:ailink/utils/ble_common_util.dart';
import 'package:ailink/utils/common_extensions.dart';
import 'package:ailink/utils/elink_broadcast_data_utils.dart';
import 'package:ailink/utils/elink_cmd_utils.dart';
import 'package:ailink/utils/elink_common_cmd_utils.dart';
import 'package:ailink/utils/elink_common_data_parse_utils.dart';
import 'package:ailink_example/model/connect_device_model.dart';
import 'package:ailink_example/utils/extensions.dart';
import 'package:ailink_example/utils/log_utils.dart';
import 'package:ailink_example/widgets/widget_ble_state.dart';
import 'package:ailink_example/widgets/widget_operate_btn.dart';
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
  final ScrollController _controller = ScrollController();

  ElinkBleData? _bleData;
  BluetoothDevice? _bluetoothDevice;
  StreamSubscription<BluetoothConnectionState>? _connectionStateSubscription;
  StreamSubscription<List<int>>? _onReceiveDataSubscription;
  StreamSubscription<List<int>>? _onReceiveA7DataSubscription;

  BluetoothCharacteristic? _dataA6Characteristic;
  BluetoothCharacteristic? _dataA7Characteristic;
  late ElinkCommonDataParseUtils _elinkCommonDataParseUtils;

  @override
  void initState() {
    super.initState();
    // _addLog('initState');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _addLog('addPostFrameCallback');
      final deviceModel = ModalRoute.of(context)?.settings.arguments as ConnectDeviceModel;
      _bluetoothDevice = deviceModel.device;
      _bleData = deviceModel.bleData;
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
          _dataA6Characteristic = null;
          _dataA7Characteristic = null;
          _addLog('Disconnected: code(${_bluetoothDevice?.disconnectReason?.code}), desc(${_bluetoothDevice?.disconnectReason?.description})');
        }
      });
      _bluetoothDevice?.connect();
    });

    _elinkCommonDataParseUtils = ElinkCommonDataParseUtils();
    _elinkCommonDataParseUtils.setElinkCommonDataParseCallback(ElinkCommonDataParseCallback((version) {
        _addLog('onGetBmVersion: $version');
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _bluetoothDevice?.advName ?? 'Unknown',
              style: const TextStyle(fontSize: 18, color: Colors.white),
            ),
            StreamBuilder<BluetoothConnectionState>(
              initialData: BluetoothConnectionState.disconnected,
              stream: _bluetoothDevice?.connectionState,
              builder: (context, snapshot) {
                final state =
                    snapshot.data ?? BluetoothConnectionState.disconnected;
                return Text(
                  state.isConnected ? 'Connected' : 'Disconnected',
                  style: const TextStyle(fontSize: 14, color: Colors.white),
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
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              OperateBtnWidget(
                onPressed: () async {
                  if (_dataA6Characteristic != null) {
                    _restartBleModule(_dataA6Characteristic!);
                  }
                },
                title: 'RestartBle',
              ),
              OperateBtnWidget(
                onPressed: () async {
                  if (_dataA6Characteristic != null) {
                    _getBmVersion(_dataA6Characteristic!);
                  }
                },
                title: 'GetBmVersion',
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              OperateBtnWidget(
                onPressed: () async {
                  if (_dataA6Characteristic != null) {
                    _setHandShake(_dataA6Characteristic!);
                  }
                },
                title: 'SetHandShake',
              ),
              OperateBtnWidget(
                onPressed: () async {
                  if (_dataA6Characteristic != null) {
                    _clearHandShake(_dataA6Characteristic!);
                  }
                },
                title: 'ClearHandShake',
              ),
            ],
          ),
          Expanded(
            child: ListView.separated(
              controller: _controller,
              itemBuilder: (context, index) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  child: Text(
                    '${DateTime.now()}: \n${logList[index]}',
                    style: TextStyle(
                      color: index % 2 == 0 ? Colors.black : Colors.black87,
                      fontSize: 16,
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
          ),
        ],
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
            _addLog('OnValueReceived [${characteristic.uuid.str}]: ${data.toHex()}, checked: ${ElinkCmdUtils.checkElinkCmdSum(data)}');
            if (ElinkBleCommonUtils.isSetHandShakeCmd(data)) {
              _replyHandShake(characteristic, data);
            }
            if (ElinkBleCommonUtils.isGetHandShakeCmd(data)) {
              Future.delayed(const Duration(milliseconds: 500), () async {
                final handShakeStatus = await _ailinkPlugin.checkHandShakeStatus(Uint8List.fromList(data));
                _addLog('handShakeStatus: $handShakeStatus');
              });
            }
            _elinkCommonDataParseUtils.parseElinkCommonData(data);
          });
          _dataA6Characteristic = characteristic;
          await _setHandShake(characteristic);
        } else if (characteristic.uuid.str.equal(ElinkBleCommonUtils.elinkNotifyUuid)) {
          _onReceiveA7DataSubscription = characteristic.onValueReceived.listen((data) async {
            final checked = ElinkCmdUtils.checkElinkCmdSum(data);
            final cid = data.sublist(1, 3);
            final mac = _bleData?.macArr ?? [];
            final decrypted = await Ailink().mcuDecrypt(Uint8List.fromList(mac), Uint8List.fromList(data));
            _addLog('OnValueReceived [${characteristic.uuid.str}]: ${data.toHex()}, decrypted: ${decrypted.toHex()}, cid: ${cid.toHex()}, mac: ${ElinkBroadcastDataUtils.littleBytes2MacStr(mac)}, checked: $checked');
          });
        }
      } else if (characteristic.uuid.str.equal(ElinkBleCommonUtils.elinkWriteUuid)) {
        _dataA7Characteristic = characteristic;
      }
    }
  }

  Future<void> _setHandShake(BluetoothCharacteristic characteristic) async {
    Uint8List data = (await _ailinkPlugin.initHandShake()) ?? Uint8List(0);
    _addLog('_setHandShake: ${data.toHex()}');
    await characteristic.write(data.toList(), withoutResponse: true);
  }

  Future<void> _clearHandShake(BluetoothCharacteristic characteristic) async {
    final data = ElinkCommonCmdUtils.clearElinkHandShake();
    _addLog('_clearHandShake: ${data.toHex()}');
    await characteristic.write(data, withoutResponse: true);
  }

  Future<void> _restartBleModule(BluetoothCharacteristic characteristic) async {
    final data = ElinkCommonCmdUtils.restartElinkBleModule();
    _addLog('_restartBleModule: ${data.toHex()}');
    await characteristic.write(data, withoutResponse: true);
  }

  Future<void> _getBmVersion(BluetoothCharacteristic characteristic) async {
    final data = ElinkCommonCmdUtils.getElinkBmVersion();
    _addLog('_getBmVersion: ${data.toHex()}');
    await characteristic.write(data, withoutResponse: true);
  }

  Future<void> _replyHandShake(BluetoothCharacteristic characteristic, List<int> data) async {
    Uint8List replyData = (await _ailinkPlugin.getHandShakeEncryptData(Uint8List.fromList(data))) ?? Uint8List(0);
    _addLog('_replyHandShake: ${replyData.toHex()}');
    await characteristic.write(replyData.toList(), withoutResponse: true);
  }

  void _addLog(String log) {
    if (mounted) {
      setState(() {
        logList.insert(0, log);
      });
    }
  }

  void _scrollToBottom() {
    _controller.animateTo(
      _controller.position.maxScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _bluetoothDevice?.disconnect();
    _bluetoothDevice = null;
    _dataA6Characteristic = null;
    _onReceiveDataSubscription?.cancel();
    _connectionStateSubscription?.cancel();
    _onReceiveA7DataSubscription?.cancel();
    _controller.dispose();
    super.dispose();
  }
}
