import 'package:flutter/material.dart';

import 'package:unicallback_demo/location_info_model.dart';
import 'package:unicallback_demo/uni_callback_test_service.dart';
import 'package:unicallback_demo/uniapi/uni_callback.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // 方式1：定义相关对象
  UniCallback<LocationInfoModel> uniCallback =
      UniCallback<LocationInfoModel>((model, disposable) {
    print('uniCallback lat: ${model.lat} lng: ${model.lng}');
  });

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    // 方式1：释放资源
    uniCallback.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Plugin example app'),
          ),
          body: Column(
            children: [
              OutlinedButton(
                  onPressed: () {
                    UniCallBackTestService.doCallbackAction0(uniCallback);
                  },
                  child: const Text('doCallbackAction0')),
              OutlinedButton(
                  onPressed: () {
                    // 方式2：通过方法参数定义 UniCallback 对象
                    UniCallBackTestService.doCallbackAction1(
                        UniCallback<String>((value, disposable) {
                      print('【doCallbackAction1】- uniCallback value: $value');
                      // 方式2：释放资源
                      disposable.dispose();
                    }));
                  },
                  child: const Text('doCallbackAction1'))
            ],
          )),
    );
  }
}
