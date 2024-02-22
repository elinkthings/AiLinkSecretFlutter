import 'dart:typed_data';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'ailink_method_channel.dart';

abstract class AilinkPlatform extends PlatformInterface {
  /// Constructs a AilinkPlatform.
  AilinkPlatform() : super(token: _token);

  static final Object _token = Object();

  static AilinkPlatform _instance = MethodChannelAilink();

  /// The default instance of [AilinkPlatform] to use.
  ///
  /// Defaults to [MethodChannelAilink].
  static AilinkPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AilinkPlatform] when
  /// they register themselves.
  static set instance(AilinkPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<Uint8List?> decryptBroadcast(Uint8List? payload) {
    throw UnimplementedError('decryptBroadcast() has not been implemented.');
  }

  Future<String?> getBodyFatData(String param) {
    throw UnimplementedError('getBodyFatData() has not been implemented.');
  }

  Future<Uint8List?> initHandShake() {
    throw UnimplementedError('initHandShake() has not been implemented.');
  }

  Future<Uint8List?> getHandShakeEncryptData(Uint8List? payload) {
    throw UnimplementedError('getHandShakeEncryptData() has not been implemented.');
  }

  Future<bool> checkHandShakeStatus(Uint8List? payload) {
    throw UnimplementedError('checkHandShakeStatus() has not been implemented.');
  }

  Future<Uint8List> mcuEncrypt(Uint8List cid, Uint8List mac, Uint8List payload) {
    throw UnimplementedError('mcuEncrypt() has not been implemented.');
  }

  Future<Uint8List> mcuDecrypt(Uint8List mac, Uint8List payload) {
    throw UnimplementedError('mcuDecrypt() has not been implemented.');
  }
}
