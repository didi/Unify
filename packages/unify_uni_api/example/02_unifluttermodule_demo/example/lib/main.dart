import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:unifluttermodule_demo/location_info_service.dart';
import 'package:unifluttermodule_demo/unifluttermodule_demo.dart';
import 'package:unifluttermodule_demo_example/my_event_bus.dart';

import 'location_info_service_impl.dart';

void main() {
  runApp(const MyApp());
  // 设置 LocationInfoService 实现接口类
  LocationInfoService.setup(LocationInfoServiceImpl());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  String _locationInfo = '';

  @override
  void initState() {
    super.initState();
    initPlatformState();
    myEventBus.on().listen((event) {
      setState(() {
        _locationInfo = event.toString();
      });
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await UnifluttermoduleDemo.platformVersion ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: [
              Text('当前经纬度: \n$_locationInfo\n'),
            ],
          ),
        ),
      ),
    );
  }
}
