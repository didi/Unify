import 'package:flutter_test/flutter_test.dart';
import 'package:unify_uni_bus/unify_uni_bus.dart';
import 'package:unify_uni_bus/unify_uni_bus_platform_interface.dart';
import 'package:unify_uni_bus/unify_uni_bus_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockUnifyUniBusPlatform
    with MockPlatformInterfaceMixin
    implements UnifyUniBusPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final UnifyUniBusPlatform initialPlatform = UnifyUniBusPlatform.instance;

  test('$MethodChannelUnifyUniBus is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelUnifyUniBus>());
  });

  test('getPlatformVersion', () async {
    UnifyUniBus unifyUniBusPlugin = UnifyUniBus();
    MockUnifyUniBusPlatform fakePlatform = MockUnifyUniBusPlatform();
    UnifyUniBusPlatform.instance = fakePlatform;

    expect(await unifyUniBusPlugin.getPlatformVersion(), '42');
  });
}
