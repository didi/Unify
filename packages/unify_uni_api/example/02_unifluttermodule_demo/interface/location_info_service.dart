import 'package:unify_flutter/api/api.dart';
import 'location_info_model.dart';

@UniFlutterModule()
abstract class LocationInfoService {
  /// 更新定位信息
  ///
  /// 通过 @UniBufferSize 将该 channel 的消息缓冲区扩大到 100,
  /// 避免原生在 Dart 侧 handler 注册前连续发消息导致的丢消息问题。
  @UniBufferSize(100)
  void updateLocationInfo(LocationInfoModel model);
  int test(bool st);
  bool test2(double st);
  String test3(int st);
  int? test4(int st);

  @UniBufferSize(999)
  Future<int> test5(Map<String, int> st);
}
