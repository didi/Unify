// This code is inspired by the dart-event-bus project (https://github.com/marcojakob/dart-event-bus),
// which is licensed under the MIT License.
// We thank the authors of dart-event-bus for their work.

import 'dart:async';
import 'package:flutter/services.dart';

class UniBus {
  // 私有构造函数
  UniBus._internal()
      : _streamController = StreamController.broadcast(),
        _methodChannel = const MethodChannel('unify_uni_bus') {
    // 初始化与Android通信的事件流
    _initPlatformEventChannel();
  }

  // 静态私有实例
  static final UniBus _instance = UniBus._internal();

  // 私有实例访问器
  static UniBus get instance => _instance;

  // 工厂构造函数，返回单例实例
  factory UniBus() {
    return _instance;
  }

  // 本地事件流控制器
  late StreamController<Map<String, dynamic>> _streamController;

  // 与原生端通信的方法通道
  final MethodChannel _methodChannel;

  StreamController<Map<String, dynamic>> get streamController =>
      _streamController;

  // 初始化平台事件通道
  void _initPlatformEventChannel() {
    _methodChannel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onEvent':
          final argument = Map<String, dynamic>.from(call.arguments);
          final String? eventName = argument['eventName'];
          final Map<String, dynamic>? data = argument['data'] != null ? Map<String, dynamic>.from(argument['data']) : null;

          if (eventName != null) {
            // 将原生端事件发送到本地事件总线
            _streamController.add({'eventName': eventName, 'data': data});
          }
      }
    });
  }

  /// 监听指定事件
  ///
  /// [eventName] 事件名称
  Stream<Map<String, dynamic>> on(String eventName) {
    // 返回包含该事件数据的流
    return _streamController.stream
        .where((event) => event['eventName'] == eventName)
        .map((event) => event['data']);
  }

  /// 发送事件
  ///
  /// [eventName] 事件名称
  /// [data] 事件数据
  Future<void> fire(String eventName, Map<String, dynamic> data) async {
    // 将事件添加到本地事件流
    _streamController.add({'eventName': eventName, 'data': data});

    // 将事件发送到原生端
    try {
      await _methodChannel.invokeMethod('fire', {
        'eventName': eventName,
        'data': data,
      });
    } catch (e) {
      print('UniBus 向原生端发送事件失败: $e');
    }
  }
}
