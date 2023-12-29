import 'dart:typed_data';

import 'ailink_platform_interface.dart';

class Ailink {
  Future<String?> getPlatformVersion() {
    return AilinkPlatform.instance.getPlatformVersion();
  }

  Future<Uint8List?> decryptBroadcast(Uint8List? payload) {
    return AilinkPlatform.instance.decryptBroadcast(payload);
  }
}
