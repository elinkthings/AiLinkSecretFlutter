class ElinkBleCommonUtils {
  static const elinkBroadcastDeviceUuid = 'F0A0';
  static const elinkConnectDeviceUuid = 'FFE0';
  static const elinkNotifyDescriptionUuid = '2902';
  static const elinkWriteUuid = 'FFE1';
  static const elinkNotifyUuid = 'FFE2';
  static const elinkWriteAndNotifyUuid = 'FFE3';

  static const elinkSendBleStart = 0xA6;
  static const elinkSetHandShake = 0x23;
  static const elinkGetHandShake = 0x24;

  static isBroadcastDevice(List<String> uuids) {
    return uuids.contains(elinkBroadcastDeviceUuid);
  }

  static isSetHandShakeCmd(List<int> data) {
    return data[0] == elinkSendBleStart && data[2] == elinkSetHandShake;
  }

  static isGetHandShakeCmd(List<int> data) {
    return data[0] == elinkSendBleStart && data[2] == elinkGetHandShake;
  }
}
