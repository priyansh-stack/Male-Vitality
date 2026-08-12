import 'package:flutter/foundation.dart';

class AppLogger {
  static void i(String message) {
    debugPrint('[INFO] $message');
  }

  static void w(String message) {
    debugPrint('[WARNING] $message');
  }

  static void e(String message, [dynamic error]) {
    debugPrint('[ERROR] $message ${error != null ? "- $error" : ""}');
  }
}