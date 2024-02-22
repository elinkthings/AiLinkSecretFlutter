import 'package:ailink/utils/elink_broadcast_data_utils.dart';

class ElinkBleData {
  /// 产品类型(product type)
  final List<int> cidArr;

  /// 厂商ID(Manufacturer ID)
  final List<int> vidArr;

  /// 产品ID(Product ID)
  final List<int> pidArr;

  /// MAC地址(MAC address)
  final List<int> macArr;

  ElinkBleData(this.cidArr, this.vidArr, this.pidArr, this.macArr);

  int get cid =>
      cidArr.length == 2 ? ((cidArr[0] & 0xFF) << 8) | (cidArr[1] & 0xFF) : 0;

  int get vid =>
      vidArr.length == 2 ? ((vidArr[0] & 0xFF) << 8) | (vidArr[1] & 0xFF) : 0;

  int get pid =>
      pidArr.length == 2 ? ((pidArr[0] & 0xFF) << 8) | (pidArr[1] & 0xFF) : 0;

  String get cidStr =>
    '0x${cidArr.map((e) => (e.toRadixString(16).padLeft(2, '0')).toUpperCase()).join('')}';

  String get vidStr =>
    '0x${vidArr.map((e) => (e.toRadixString(16).padLeft(2, '0')).toUpperCase()).join('')}';

  String get pidStr =>
    '0x${pidArr.map((e) => (e.toRadixString(16).padLeft(2, '0')).toUpperCase()).join('')}';

  String get mac => ElinkBroadcastDataUtils.littleBytes2MacStr(macArr);
}
