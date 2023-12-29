import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'ailink_platform_interface.dart';

/// An implementation of [AilinkPlatform] that uses method channels.
class MethodChannelAilink extends AilinkPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('ailink');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
