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
