import 'package:flutter_test/flutter_test.dart';
import 'package:hello_uni_foundation/hello_uni_foundation.dart';
import 'package:hello_uni_foundation/hello_uni_foundation_platform_interface.dart';
import 'package:hello_uni_foundation/hello_uni_foundation_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockHelloUniFoundationPlatform
    with MockPlatformInterfaceMixin
    implements HelloUniFoundationPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final HelloUniFoundationPlatform initialPlatform = HelloUniFoundationPlatform.instance;

  test('$MethodChannelHelloUniFoundation is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelHelloUniFoundation>());
  });

  test('getPlatformVersion', () async {
    HelloUniFoundation helloUniFoundationPlugin = HelloUniFoundation();
    MockHelloUniFoundationPlatform fakePlatform = MockHelloUniFoundationPlatform();
    HelloUniFoundationPlatform.instance = fakePlatform;

    expect(await helloUniFoundationPlugin.getPlatformVersion(), '42');
  });
}
