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
}
