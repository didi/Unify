import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:hello_uni_foundation/device_info_model.dart';
import 'package:hello_uni_foundation/device_info_service.dart';
import 'package:hello_uni_foundation/hello_uni_foundation.dart';
import 'package:hello_uni_foundation/location_info_service.dart';
import 'package:hello_uni_foundation_example/my_event_bus.dart';

import 'location_info_service_impl.dart';

Future<void> main() async {
  runApp(const MyApp());
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
  final _helloUniFoundationPlugin = HelloUniFoundation();

  @override
  void initState() {
    super.initState();
    // initPlatformState();
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
      platformVersion = await _helloUniFoundationPlugin.getPlatformVersion() ??
          'Unknown platform version';
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
              Text('设备信息: $_platformVersion\n'),
              OutlinedButton(
                child: const Text("获取设备信息"),
                onPressed: () {
                  DeviceInfoService.getDeviceInfo().then((deviceInfoModel) {
                    setState(() {
                      _platformVersion = "\n${deviceInfoModel.encode()}";
                    });
                  });
                },
              ),
              Text('当前经纬度: \n$_locationInfo\n'),
            ],
          ),
        ),
      ),
    );
  }
}
