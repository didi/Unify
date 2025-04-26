// This code is inspired by the dart-event-bus project (https://github.com/marcojakob/dart-event-bus),
// which is licensed under the MIT License.
// We thank the authors of dart-event-bus for their work.

import 'dart:async';

class UniBus {
  StreamController _streamController;

  StreamController get streamController => _streamController;

  UniBus() : _streamController = StreamController.broadcast();

  Stream<Map<String, dynamic>> on(String eventName) {
    return _streamController.stream
        .where((event) => event['eventName'] == eventName)
        .map((event) => event['data']);
  }

  void fire(String eventName, Map<String, dynamic> data) {
    _streamController.add({'eventName': eventName, 'data': data});
  }

  void destroy() {
    _streamController.close();
  }
}
