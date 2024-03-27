import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'hello_uni_foundation_method_channel.dart';

abstract class HelloUniFoundationPlatform extends PlatformInterface {
  /// Constructs a HelloUniFoundationPlatform.
  HelloUniFoundationPlatform() : super(token: _token);

  static final Object _token = Object();

  static HelloUniFoundationPlatform _instance = MethodChannelHelloUniFoundation();

  /// The default instance of [HelloUniFoundationPlatform] to use.
  ///
  /// Defaults to [MethodChannelHelloUniFoundation].
  static HelloUniFoundationPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [HelloUniFoundationPlatform] when
  /// they register themselves.
  static set instance(HelloUniFoundationPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
