import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'unify_uni_bus_method_channel.dart';

abstract class UnifyUniBusPlatform extends PlatformInterface {
  /// Constructs a UnifyUniBusPlatform.
  UnifyUniBusPlatform() : super(token: _token);

  static final Object _token = Object();

  static UnifyUniBusPlatform _instance = MethodChannelUnifyUniBus();

  /// The default instance of [UnifyUniBusPlatform] to use.
  ///
  /// Defaults to [MethodChannelUnifyUniBus].
  static UnifyUniBusPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [UnifyUniBusPlatform] when
  /// they register themselves.
  static set instance(UnifyUniBusPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    return _instance.getPlatformVersion();
  }
}
