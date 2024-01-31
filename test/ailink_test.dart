import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:ailink/ailink.dart';
import 'package:ailink/ailink_platform_interface.dart';
import 'package:ailink/ailink_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockAilinkPlatform
    with MockPlatformInterfaceMixin
    implements AilinkPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<Uint8List?> decryptBroadcast(Uint8List? payload) => Future.value(null);

  @override
  Future<String?> getBodyFatData(String param) => Future.value(null);

  @override
  Future<Uint8List?> initHandShake() => Future.value(null);
}

void main() {
  final AilinkPlatform initialPlatform = AilinkPlatform.instance;

  test('$MethodChannelAilink is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelAilink>());
  });

  test('getPlatformVersion', () async {
    Ailink ailinkPlugin = Ailink();
    MockAilinkPlatform fakePlatform = MockAilinkPlatform();
    AilinkPlatform.instance = fakePlatform;

    expect(await ailinkPlugin.getPlatformVersion(), '42');
  });
}
