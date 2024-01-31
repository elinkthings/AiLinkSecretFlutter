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
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }

  @override
  Future<Uint8List?> decryptBroadcast(Uint8List? payload) async {
    final decryptPayload = await methodChannel.invokeMethod<Uint8List?>(
      'decryptBroadcast',
      payload,
    );
    return decryptPayload;
  }

  @override
  Future<String?> getBodyFatData(String param) async {
    final bodyFatData = await methodChannel.invokeMethod<String?>(
      'getBodyFatData',
      param,
    );
    return bodyFatData;
  }

  @override
  Future<Uint8List?> initHandShake() async {
    final handShakeData = await methodChannel.invokeMethod<Uint8List?>(
      'initHandShake',
    );
    return handShakeData;
  }

  @override
  Future<Uint8List?> getHandShakeEncryptData(Uint8List? payload) async {
    final encryptData = await methodChannel.invokeMethod<Uint8List?>(
      'getHandShakeEncryptData',
      payload,
    );
    return encryptData;
  }

  @override
  Future<bool> checkHandShakeStatus(Uint8List? payload) async {
    final status = await methodChannel.invokeMethod<bool?>(
      'checkHandShakeStatus',
      payload,
    );
    return status ?? false;
  }
}
