import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:ailink/ailink.dart';
import 'package:ailink_example/body_fat_data.dart';
import 'package:ailink_example/broadcast_scale_data_utils.dart';
import 'package:ailink_example/param_body_fat_data.dart';
import 'package:flutter/material.dart';
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

void main() {
  FlutterBluePlus.setLogLevel(LogLevel.verbose, color: true);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _ailinkPlugin = Ailink();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('AiLink Secret Tool example app'),
          actions: [
            _buildBluetoothStateWidget,
          ],
        ),
        body: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildNotSupportedWidget,
              _buildOperatorWidget,
              Expanded(child: _buildScanResultWidget)
            ],
          ),
        ),
      ),
    );
  }

  Widget get _buildNotSupportedWidget => FutureBuilder<bool>(
        future: FlutterBluePlus.isSupported,
        builder: (context, snapshot) {
          return Visibility(
            visible: !(snapshot.hasData && snapshot.data == true),
            child: const Text(
              'Bluetooth is not supported',
              style: TextStyle(color: Colors.red, fontSize: 18),
            ),
          );
        },
      );

  Widget get _buildBluetoothStateWidget => StreamBuilder<BluetoothAdapterState>(
        initialData: FlutterBluePlus.adapterStateNow,
        stream: FlutterBluePlus.adapterState,
        builder: (context, snapshot) {
          final bool isBluetoothOn =
              snapshot.hasData && snapshot.data == BluetoothAdapterState.on;
          return IconButton(
            onPressed: () {
              if (Platform.isAndroid && !isBluetoothOn) {
                FlutterBluePlus.turnOn();
              }
            },
            icon: Icon(
              isBluetoothOn ? Icons.bluetooth : Icons.bluetooth_disabled,
              color: Colors.white,
            ),
          );
        },
      );

  Widget get _buildOperatorWidget => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Builder(builder: (context) {
            return _buildOperatorBtn(
              'Scan',
              () => FlutterBluePlus.startScan(withServices: [Guid('F0A0')]).onError( ///Filter specified scales by serviceUUID
                (error, stackTrace) =>
                    ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(prettyException(error)),
                    backgroundColor: Colors.red,
                  ),
                ),
              ),
            );
          }),
          _buildOperatorBtn(
            'StopScan',
            () async => await FlutterBluePlus.stopScan(),
          ),
        ],
      );

  Widget _buildOperatorBtn(String title, Function() onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 18),
      ),
    );
  }

  Widget get _buildScanResultWidget => StreamBuilder<List<ScanResult>>(
        stream: FlutterBluePlus.onScanResults,
        builder: (context, snapshot) {
          final List<ScanResult> list = snapshot.hasData ? (snapshot.data ?? []) : [];
          list.sort((a, b) => b.rssi.compareTo(a.rssi));
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              List<int> manufacturerData = getManufacturerData(list[index].advertisementData.manufacturerData);
              return ListTile(
                title: Text(
                  list[index].device.advName.isEmpty
                      ? 'Unknown'
                      : list[index].device.advName,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MAC: ${list[index].device.remoteId.toString()}',
                    ),
                    Text(
                      'UUIDs: ${list[index].advertisementData.serviceUuids.join(', ').toUpperCase()}',
                    ),
                    Text(
                      'Data: ${manufacturerData.toHex()}',
                    ),
                    FutureBuilder(
                      future: _ailinkPlugin.decryptBroadcast(
                        Uint8List.fromList(manufacturerData),
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data != null) {
                          final weightData = BroadcastScaleDataUtils().getWeightData(snapshot.data);
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ParseResult: ${snapshot.data?.toHex()}',
                              ),
                              Text('Status: ${weightData?.statusStr}'),
                              Text('Impedance value: ${weightData?.adc}'),
                              Text(
                                'WeightData: ${weightData?.weightStr} ${weightData?.weightUnitStr}',
                              ),
                              weightData == null || weightData.isAdcError == true ? Container() : FutureBuilder(
                                future: _ailinkPlugin.getBodyFatData(ParamBodyFatData(double.parse(weightData.weightStr), weightData.adc, 0, 34, 170, weightData.algorithmId).toJson()),
                                builder: (context, snapshot) {
                                  if (weightData.status == 0xFF) {
                                    if (snapshot.hasData && snapshot.data != null) {
                                      return Text(
                                        'BodyFatData: ${BodyFatData.fromJson(json.decode(snapshot.data!)).toJson()}',
                                      );
                                    }
                                  }
                                  return Container();
                                },
                              )
                            ],
                          );
                        } else {
                          return Container();
                        }
                      },
                    ),
                  ],
                ),
                trailing: Text(
                  list[index].rssi.toString(),
                ),
              );
            },
          );
        },
      );

  String prettyException(dynamic e) {
    if (e is FlutterBluePlusException) {
      return "${e.description}";
    } else if (e is PlatformException) {
      return "${e.message}";
    }
    return e.toString();
  }

  List<int> getManufacturerData(Map<int, List<int>> data) {
    return data.entries
        .map((entry) {
          List<int> manufacturerData = intToLittleEndian(entry.key, 2);
          List<int> results = List.empty(growable: true);
          results.addAll(manufacturerData);
          results.addAll(entry.value);
          return results;
        })
        .expand((element) => element)
        .toList();
  }

  List<int> intToLittleEndian(int value, int length) {
    List<int> result = List<int>.filled(length, 0);

    for (int i = 0; i < length; i++) {
      result[i] = (value >> (i * 8)) & 0xFF;
    }

    return result;
  }
}
