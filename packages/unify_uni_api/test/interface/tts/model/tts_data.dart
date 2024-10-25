import 'package:unify_flutter/api/api.dart';

import 'audio.dart';

@UniModel()

/// 注释:存储TTS数据内容
class TtsData {
  /// 注释:TTS文件名称
  String? name;
  Audio? audio;
}
