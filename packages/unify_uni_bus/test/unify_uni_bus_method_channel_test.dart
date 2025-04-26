import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unify_uni_bus/unify_uni_bus_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelUnifyUniBus platform = MethodChannelUnifyUniBus();
  const MethodChannel channel = MethodChannel('unify_uni_bus');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
