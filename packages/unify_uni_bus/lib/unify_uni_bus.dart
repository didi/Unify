
import 'dart:async';

import 'unify_uni_bus_platform_interface.dart';

class UniBus {
  StreamController _streamController;

  StreamController get streamController => _streamController;
  
  Future<String?> getPlatformVersion() {
    return UnifyUniBusPlatform.instance.getPlatformVersion();
  }
}
