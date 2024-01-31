import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class ElinkBleCommonUtils {
  static final elinkBroadcastDeviceUuid = Guid('F0A0');
  static final elinkConnectDeviceUuid = Guid('FFE0');
  static final elinkNotifyDescriptionUuid = Guid('2902');
  static final elinkWriteUuid = Guid('FFE1');
  static final elinkNotifyUuid = Guid('FFE2');
  static final elinkWriteAndNotifyUuid = Guid('FFE3');

  static const elinkSendBleStart = 0xA6;
  static const elinkSetHandShake = 0x23;
  static const elinkGetHandShake = 0x24;

  static isBroadcastDevice(List<Guid> uuids) {
    return uuids.contains(elinkBroadcastDeviceUuid);
  }

  static isSetHandShakeCmd(List<int> data) {
    return data[0] == elinkSendBleStart && data[2] == elinkSetHandShake;
  }

  static isGetHandShakeCmd(List<int> data) {
    return data[0] == elinkSendBleStart && data[2] == elinkGetHandShake;
  }
}
