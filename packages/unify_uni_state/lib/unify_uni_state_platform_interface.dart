import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'unify_uni_state_method_channel.dart';

abstract class UnifyUniStatePlatform extends PlatformInterface {
  /// Constructs a UnifyUniStatePlatform.
  UnifyUniStatePlatform() : super(token: _token);

  static final Object _token = Object();

  static UnifyUniStatePlatform _instance = MethodChannelUnifyUniState();

  /// The default instance of [UnifyUniStatePlatform] to use.
  ///
  /// Defaults to [MethodChannelUnifyUniState].
  static UnifyUniStatePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [UnifyUniStatePlatform] when
  /// they register themselves.
  static set instance(UnifyUniStatePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
