
import 'ailink_platform_interface.dart';

class Ailink {
  Future<String?> getPlatformVersion() {
    return AilinkPlatform.instance.getPlatformVersion();
  }
}
