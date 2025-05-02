
import 'unify_uni_state_platform_interface.dart';

class UnifyUniState {
  Future<String?> getPlatformVersion() {
    return UnifyUniStatePlatform.instance.getPlatformVersion();
  }
}
