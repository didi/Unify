import 'package:flutter/services.dart';
import 'package:unify_uni_bus/unify_uni_bus.dart';

class UniState {
  static const String _uniStateEvent = 'unify_uni_state_event';
  static const String _uniStateChannel = 'unify_uni_state_channel';

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

  // 初始化平台事件通道
  void _initPlatformEventChannel() {
    _methodChannel.setMethodCallHandler((call) async {
      switch (call.method) {}
    });
  }

  void _initEventBus() {
    // 监听 EventBus 事件
    UniBus.instance.on(_uniStateEvent).listen((stateAction) {});
  }
}
