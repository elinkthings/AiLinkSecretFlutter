import 'package:ailink/impl/elink_common_data_parse_callback.dart';
import 'package:ailink/utils/elink_cmd_utils.dart';

typedef OnGetBmVersion = void Function(String version);

class ElinkCommonDataParseUtils {
  static ElinkCommonDataParseUtils? _instance;

  OnGetBmVersion? _onGetBmVersion;

  ElinkCommonDataParseUtils._() {
    _instance = this;
  }

  factory ElinkCommonDataParseUtils() {
    _instance ??= ElinkCommonDataParseUtils._();
    return _instance!;
  }

  void setElinkCommonDataParseCallback(ElinkCommonDataParseCallback callback) {
    _onGetBmVersion = callback.onGetBmVersion;
  }

  void parseElinkCommonData(List<int> data) {
    if (ElinkCmdUtils.checkElinkCmdSum(data)) {
      if (ElinkCmdUtils.isElinkA6Data(data)) {
        final payload = ElinkCmdUtils.formatA6Data(data);
        switch (payload[0]) {
          case 0x0E:
            _parseBmVersion(payload);
            break;
        }
      }
    }
  }

  void _parseBmVersion(List<int> payload) {
    if (payload.length >= 10) {
      String version = "";

      // 产品型号
      String nameStr = String.fromCharCodes([payload[1], payload[2]]);
      version += nameStr;
      version += (payload[3] & 0xff).toString().padLeft(2, '0');

      // 硬件版本号
      version += "H${payload[4] & 0xff}";

      // 软件版本号
      version += "S${((payload[5] & 0xff) / 10.0).toStringAsFixed(1)}";

      // 定制版本号
      version += ".${payload[6] & 0xff}";

      // 日期
      String year = "_${(payload[7] & 0xff) + 2000}";
      String month = (payload[8] & 0xff).toString().padLeft(2, '0');
      String day = (payload[9] & 0xff).toString().padLeft(2, '0');
      version += "$year$month$day";

      _onGetBmVersion?.call(version);
    }
  }
}
