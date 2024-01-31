import 'package:flutter/foundation.dart';

class LogUtils {
  static LogUtils? _instance;

  LogUtils._() {
    _instance = this;
  }

  factory LogUtils() => _instance ?? LogUtils._();

  void log(String msg) {
    if (kDebugMode) {
      print('[LogUtils] $msg');
    }
  }
}
