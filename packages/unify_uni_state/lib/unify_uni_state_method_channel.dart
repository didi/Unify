import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'unify_uni_state_platform_interface.dart';

/// An implementation of [UnifyUniStatePlatform] that uses method channels.
class MethodChannelUnifyUniState extends UnifyUniStatePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('unify_uni_state');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
