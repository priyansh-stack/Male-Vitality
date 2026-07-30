import 'package:flutter/material.dart';

class AppLogger {
  static void log(String message, {String? tag}) {
    final String prefix = tag != null ? '[$tag] ' : '';
    debugPrint('$prefix$message');
  }
  
  static void auth(String message) => log(message, tag: 'AUTH');
  static void router(String message) => log(message, tag: 'ROUTER');
  static void onboarding(String message) => log(message, tag: 'ONBOARDING');
  static void dashboard(String message) => log(message, tag: 'DASHBOARD');
}