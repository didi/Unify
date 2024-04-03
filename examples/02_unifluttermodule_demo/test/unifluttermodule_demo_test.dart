import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unifluttermodule_demo/unifluttermodule_demo.dart';

void main() {
  const MethodChannel channel = MethodChannel('unifluttermodule_demo');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await UnifluttermoduleDemo.platformVersion, '42');
  });
}
