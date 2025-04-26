import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:unify_uni_bus/unify_uni_bus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _uniBus = UniBus.instance;
  bool _isListening = false;
  StreamSubscription? _eventSubscription;

  // 定义示例事件名称常量
  static const String _testEventName = 'test_event';

  // 记录最后收到的消息
  String _lastReceivedMessage = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }

  // 注册Flutter端的事件监听
  void _startListening() {
    if (_isListening) return;

    print('Flutter: 开始监听事件 "$_testEventName"');

    _eventSubscription = _uniBus.on(_testEventName).listen((data) {
      print('Flutter: 收到事件 "$_testEventName" 数据: $data');

      setState(() {
        _lastReceivedMessage = '收到消息: ${data['message'] ?? '未知消息'}';
      });
    });

    setState(() {
      _isListening = true;
    });
  }

  // 取消Flutter端的事件监听
  void _stopListening() {
    if (!_isListening) return;

    _eventSubscription?.cancel();
    _eventSubscription = null;

    print('Flutter: 停止监听事件 "$_testEventName"');

    setState(() {
      _isListening = false;
      _lastReceivedMessage = '';
    });
  }

  // Flutter端发送事件
  void _sendEventFromFlutter() async {
    final Map<String, dynamic> eventData = {
      'message': 'Hello from Flutter',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    print('Flutter: 发送事件 "$_testEventName" 数据: $eventData');

    // 使用UniBus发送事件
    await _uniBus.fire(_testEventName, eventData);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('UniBus 演示应用'),
        ),
        body: Column(
          children: [
            _buildControlPanel(),
            if (_lastReceivedMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    _lastReceivedMessage,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // 控制面板，包含各种操作按钮
  Widget _buildControlPanel() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8.0),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '控制面板',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: Icon(_isListening ? Icons.pause : Icons.play_arrow),
                  label: Text(_isListening ? '停止监听' : '开始监听'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isListening
                        ? Theme.of(context).colorScheme.errorContainer
                        : Theme.of(context).colorScheme.primaryContainer,
                    foregroundColor: _isListening
                        ? Theme.of(context).colorScheme.onErrorContainer
                        : Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  onPressed: _isListening ? _stopListening : _startListening,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.send),
                  label: const Text('Flutter发送事件'),
                  onPressed: _sendEventFromFlutter,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '注意: Android端有独立按钮发送消息',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
