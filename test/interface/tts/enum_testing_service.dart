import 'package:unify_flutter/api/api.dart';

import 'model/tts_data.dart';

@UniNativeModule()
abstract class EnumTestingService {
  void testField(TtsData data);
}
