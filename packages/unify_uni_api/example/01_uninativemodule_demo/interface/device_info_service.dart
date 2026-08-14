import 'package:unify_flutter/api/api.dart';
import 'device_info_model.dart';

@UniNativeModule()
abstract class DeviceInfoService {
  /// 获取设备信息
  Future<DeviceInfoModel> getDeviceInfo();

  int test(bool st);
  bool test2(double st);
  String test3(int st);
  int? test4(int st);

  Future<int> test5(Map<String,int> st);
}
