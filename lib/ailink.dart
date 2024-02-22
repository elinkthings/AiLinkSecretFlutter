import 'dart:typed_data';

import 'ailink_platform_interface.dart';

class Ailink {
  Future<String?> getPlatformVersion() {
    return AilinkPlatform.instance.getPlatformVersion();
  }

  Future<Uint8List?> decryptBroadcast(Uint8List? payload) {
    return AilinkPlatform.instance.decryptBroadcast(payload);
  }

  Future<String?> getBodyFatData(String param) {
    return AilinkPlatform.instance.getBodyFatData(param);
  }

  Future<Uint8List?> initHandShake() {
    return AilinkPlatform.instance.initHandShake();
  }

  Future<Uint8List?> getHandShakeEncryptData(Uint8List? payload) {
    return AilinkPlatform.instance.getHandShakeEncryptData(payload);
  }

  Future<bool> checkHandShakeStatus(Uint8List? payload) {
    return AilinkPlatform.instance.checkHandShakeStatus(payload);
  }

  Future<Uint8List> mcuEncrypt(Uint8List cid, Uint8List mac, Uint8List payload) {
    return AilinkPlatform.instance.mcuEncrypt(cid, mac, payload);
  }

  Future<Uint8List> mcuDecrypt(Uint8List mac, Uint8List payload) {
    return AilinkPlatform.instance.mcuDecrypt(mac, payload);
  }
}
