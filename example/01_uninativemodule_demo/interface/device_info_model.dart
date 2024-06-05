import 'package:unify_flutter/api/api.dart';

/// 设备信息 实体类
@UniModel()
class DeviceInfoModel {
  /// 系统版本
  String? osVersion;

  /// 内存信息
  String? memory;

  /// 手机型号
  String? plaform;
}
