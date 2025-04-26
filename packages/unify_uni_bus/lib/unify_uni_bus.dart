// This code is inspired by the dart-event-bus project (https://github.com/marcojakob/dart-event-bus),
// which is licensed under the MIT License.
// We thank the authors of dart-event-bus for their work.

import 'dart:async';

class UniBus {
  // 私有构造函数
  UniBus._internal() : _streamController = StreamController.broadcast();

  // 静态私有实例
  static final UniBus _instance = UniBus._internal();

  // 私有实例访问器
  static UniBus get instance => _instance;

  // 工厂构造函数，返回单例实例
  factory UniBus() {
    return _instance;
  }

  late StreamController<Map<String, dynamic>> _streamController;

  StreamController<Map<String, dynamic>> get streamController =>
      _streamController;

  Stream<Map<String, dynamic>> on(String eventName) {
    return _streamController.stream
        .where((event) => event['eventName'] == eventName)
        .map((event) => event['data']);
  }

  void fire(String eventName, Map<String, dynamic> data) {
    _streamController.add({'eventName': eventName, 'data': data});
  }
}
