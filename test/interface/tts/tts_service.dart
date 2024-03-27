import 'package:unify/api/api.dart';

import 'model/tts_data.dart';

@UniNativeModule()
abstract class TtsService {
  /// 方法注释:播放
  void playTts(TtsData? data);

  int version();
}
