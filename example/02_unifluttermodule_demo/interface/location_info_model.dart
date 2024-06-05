import 'package:unify_flutter/api/api.dart';

/// 定位经纬度信息 实体类
@UniModel()
class LocationInfoModel {
  /// 纬度
  double? lat;

  /// 经度
  double? lng;
}
