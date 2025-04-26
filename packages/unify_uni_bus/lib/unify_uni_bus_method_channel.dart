import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'unify_uni_bus_platform_interface.dart';

/// An implementation of [UnifyUniBusPlatform] that uses method channels.
class MethodChannelUnifyUniBus extends UnifyUniBusPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('unify_uni_bus');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
