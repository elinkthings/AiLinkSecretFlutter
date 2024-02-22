import 'dart:convert';

import 'package:ailink/ailink.dart';
import 'package:ailink/utils/broadcast_scale_data_utils.dart';
import 'package:ailink/utils/common_extensions.dart';
import 'package:ailink/utils/ble_common_util.dart';
import 'package:ailink/utils/elink_broadcast_data_utils.dart';
import 'package:ailink/model/param_body_fat_data.dart';
import 'package:ailink/model/body_fat_data.dart';
import 'package:ailink_example/utils/constants.dart';
import 'package:ailink_example/utils/log_utils.dart';
import 'package:ailink_example/widgets/widget_ble_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _ailinkPlugin = Ailink();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('AiLink Secret Tool example app'),
          actions: const [
            BleStateWidget(),
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

  Widget get _buildOperatorWidget => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Builder(builder: (context) {
            return _buildOperatorBtn(
              'Scan',
              () => FlutterBluePlus.startScan(withServices: [
                ///Filter specified scales by serviceUUID
                Guid(ElinkBleCommonUtils.elinkBroadcastDeviceUuid),
                Guid(ElinkBleCommonUtils.elinkConnectDeviceUuid)
              ]).onError((error, stackTrace) {
                LogUtils().log('startScan error: ${error.toString()}');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(prettyException(error)),
                    backgroundColor: Colors.red,
                  ),
                );
              }),
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
          return ListView.separated(
            itemCount: list.length,
            itemBuilder: (context, index) {
              List<int> manufacturerData = getManufacturerData(list[index].advertisementData.manufacturerData);
              final uuids = list[index].advertisementData.serviceUuids.map((uuid) => uuid.str.toUpperCase()).toList();
              final isBroadcastDevice = ElinkBleCommonUtils.isBroadcastDevice(uuids);
              final elinkBleData = ElinkBroadcastDataUtils.getElinkBleData(manufacturerData, isBroadcastDevice: isBroadcastDevice);
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
                      'MAC: ${elinkBleData.mac}',
                    ),
                    Text(
                      'CID: ${elinkBleData.cidStr}(${elinkBleData.cid}), VID: ${elinkBleData.vidStr}(${elinkBleData.vid}), PID: ${elinkBleData.pidStr}(${elinkBleData.pid})',
                    ),
                    Text(
                      'UUIDs: ${uuids.join(', ').toUpperCase()}',
                    ),
                    Text(
                      'Data: ${manufacturerData.toHex()}',
                    ),
                    isBroadcastDevice
                        ? _buildBroadcastWidget(manufacturerData)
                        : _buildConnectDeviceWidget(list[index]),
                  ],
                ),
                trailing: Text(
                  list[index].rssi.toString(),
                ),
              );
            },
            separatorBuilder: (context, index) {
              return const Divider(
                height: 0.5,
                color: Colors.grey,
              );
            },
          );
        },
      );

  Widget _buildBroadcastWidget(List<int> manufacturerData) {
    return FutureBuilder(
      future: _ailinkPlugin.decryptBroadcast(
        Uint8List.fromList(manufacturerData),
      ),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          final weightData =
              BroadcastScaleDataUtils().getWeightData(snapshot.data);
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
              weightData == null || weightData.isAdcError == true
                  ? Container()
                  : FutureBuilder(
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
    );
  }

  Widget _buildConnectDeviceWidget(ScanResult scanResult) {
    final device = scanResult.device;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        InkWell(
          onTap: () {
            FlutterBluePlus.stopScan();
            Navigator.pushNamed(context, page_connect_device, arguments: device);
          },
          child: Container(
            color: Colors.black,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Text(
                'Connect',
                style: TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        )
      ],
    );
  }

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
