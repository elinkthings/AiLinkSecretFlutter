import 'dart:typed_data';

import 'package:ailink/utils/body_data_utils.dart';
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

  @override
  Future<bool> checkHandShakeStatus(Uint8List? payload) => Future.value(true);

  @override
  Future<Uint8List?> getHandShakeEncryptData(Uint8List? payload) => Future.value(null);

  @override
  Future<Uint8List> mcuEncrypt(Uint8List cid, Uint8List mac, Uint8List payload) => Future(() => Uint8List(0));

  @override
  Future<Uint8List> mcuDecrypt(Uint8List mac, Uint8List payload) => Future(() => Uint8List(0));
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

  test('bodyDataUtils', () async {
    const sex = 1;
    const height = 175.0;
    const weight = 65.6;
    const bfr = 14.2;
    const rom = 51.1;
    const pp = 18.4;
    final standardWeight = BodyDataUtils.getStandardWeight(sex, height, fractionDigits: 4);
    print('standardWeight: $standardWeight');
    final weightControl = BodyDataUtils.getWeightControl(weight, sex, height, fractionDigits: 4);
    print('weightControl: $weightControl');
    final fatMass = BodyDataUtils.getFatMass(weight, bfr, fractionDigits: 4);
    print('fatMass: $fatMass');
    final leanBodyMass = BodyDataUtils.getLeanBodyMass(weight, bfr, fractionDigits: 4);
    print('leanBodyMass: $leanBodyMass');
    final muscleMass = BodyDataUtils.getMuscleMass(weight, rom, fractionDigits: 4);
    print('muscleMass: $muscleMass');
    final proteinMass = BodyDataUtils.getProteinMass(weight, pp, fractionDigits: 4);
    print('proteinMass: $proteinMass');
    final level = BodyDataUtils.getObesityLevel(weight, sex, height);
    print('level: $level');

    final ailink = Ailink();
    final decrypted = await ailink.mcuDecrypt(Uint8List.fromList([0xA6, 0x03, 0x42, 0x01, 0x00, 0x46, 0x6A]), Uint8List.fromList([167, 0, 4, 5, 87, 147, 226, 237, 183, 121, 122]));

    print('decrypted: $decrypted');
  });
}
