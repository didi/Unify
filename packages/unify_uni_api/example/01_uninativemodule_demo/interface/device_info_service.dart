import 'package:unify_flutter/api/api.dart';
import 'device_info_model.dart';

@UniNativeModule()
abstract class DeviceInfoService {
  /// 获取设备信息
  Future<DeviceInfoModel> getDeviceInfo();
}
