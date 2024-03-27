
import 'hello_uni_foundation_platform_interface.dart';

class HelloUniFoundation {
  Future<String?> getPlatformVersion() {
    return HelloUniFoundationPlatform.instance.getPlatformVersion();
  }
}
