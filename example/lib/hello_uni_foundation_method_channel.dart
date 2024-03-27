import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'hello_uni_foundation_platform_interface.dart';

/// An implementation of [HelloUniFoundationPlatform] that uses method channels.
class MethodChannelHelloUniFoundation extends HelloUniFoundationPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('hello_uni_foundation');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
