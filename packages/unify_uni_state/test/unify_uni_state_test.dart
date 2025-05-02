import 'package:flutter_test/flutter_test.dart';
import 'package:unify_uni_state/unify_uni_state.dart';
import 'package:unify_uni_state/unify_uni_state_platform_interface.dart';
import 'package:unify_uni_state/unify_uni_state_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockUnifyUniStatePlatform
    with MockPlatformInterfaceMixin
    implements UnifyUniStatePlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final UnifyUniStatePlatform initialPlatform = UnifyUniStatePlatform.instance;

  test('$MethodChannelUnifyUniState is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelUnifyUniState>());
  });

  test('getPlatformVersion', () async {
    UnifyUniState unifyUniStatePlugin = UnifyUniState();
    MockUnifyUniStatePlatform fakePlatform = MockUnifyUniStatePlatform();
    UnifyUniStatePlatform.instance = fakePlatform;

    expect(await unifyUniStatePlugin.getPlatformVersion(), '42');
  });
}
