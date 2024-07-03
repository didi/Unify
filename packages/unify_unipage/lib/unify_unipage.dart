
import 'dart:async';

import 'package:flutter/services.dart';

export 'src/unipage.dart';
export 'src/unipage_provider.dart';

class UnifyUnipage {
  static const MethodChannel _channel = MethodChannel('unify_unipage');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
