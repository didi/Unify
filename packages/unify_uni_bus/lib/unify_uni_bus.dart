// This code is inspired by the dart-event-bus project (https://github.com/marcojakob/dart-event-bus),
// which is licensed under the MIT License.
// We thank the authors of dart-event-bus for their work.

import 'dart:async';

import 'unify_uni_bus_platform_interface.dart';

class UniBus {
  StreamController _streamController;

  StreamController get streamController => _streamController;

  UniBus() : _streamController = StreamController.broadcast();

  Future<String?> getPlatformVersion() {
    return UnifyUniBusPlatform.instance.getPlatformVersion();
  }
}
