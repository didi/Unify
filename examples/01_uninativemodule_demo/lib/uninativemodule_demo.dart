
import 'dart:async';

import 'package:flutter/services.dart';

class UninativemoduleDemo {
  static const MethodChannel _channel = MethodChannel('uninativemodule_demo');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
