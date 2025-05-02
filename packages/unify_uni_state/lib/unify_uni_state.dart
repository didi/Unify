import 'dart:async';

import 'package:flutter/services.dart';
import 'package:unify_uni_bus/unify_uni_bus.dart';

class UniState {
  static const String _uniStateEvent = 'unify_uni_state_event';
  static const String _uniStateChannel = 'unify_uni_state_channel';

  static const String _eventKeyType = 'type';
  static const String _eventKeyState = 'state';
  static const String _eventKeyValue = 'value';
  static const String _eventTypeOnStateChange = 'onStateChange';

  // 私有构造函数
  UniState._internal()
      : _methodChannel = const MethodChannel(_uniStateChannel) {
    // 初始化与Android通信的事件流
    _initPlatformEventChannel();

    // 初始化 EventBus
    _initEventBus();
  }

  // 静态私有实例
  static final UniState _instance = UniState._internal();

  // 私有实例访问器
  static UniState get instance => _instance;

  final MethodChannel _methodChannel;

  // 所有状态的事件流
  // Key: stateKey, value: Stream<dynamic>
  final Map<String, StreamController> _StateStreams = {};

  Future<void> set(String key, dynamic value) async {
  }

  Future<dynamic> read(String key) async {

  }

  Future<Stream?> watch(String key) async {
  }

  // 初始化平台事件通道
  void _initPlatformEventChannel() {
    _methodChannel.setMethodCallHandler((call) async {
      switch (call.method) {}
    });
  }

  void _initEventBus() {
    // 监听 EventBus 事件
    UniBus.instance.on(_uniStateEvent).listen((stateAction) {
      String? type = stateAction[_eventKeyType];
      if (type != _eventTypeOnStateChange) {
        return;
      }

      String? state = stateAction[_eventKeyState];
      if (state == null) {
        return;
      }

      // 创建状态流
      _createStreamIfNotExisted(state);
      // 将状态值发送到状态流
      _StateStreams[state]!.add(stateAction[_eventKeyValue]);
    });
  }

  void _createStreamIfNotExisted(String stateKey) {
    if (!_StateStreams.containsKey(stateKey)) {
      _StateStreams[stateKey] = StreamController<dynamic>.broadcast();
    }
  }
}
