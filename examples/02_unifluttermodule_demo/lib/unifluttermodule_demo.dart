
import 'dart:async';

import 'package:flutter/services.dart';

class UnifluttermoduleDemo {
  static const MethodChannel _channel = MethodChannel('unifluttermodule_demo');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
