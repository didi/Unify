import 'package:unify/api/api.dart';

/// 定位经纬度信息 实体类
@UniModel()
class LocationInfoModel {
  /// 维度
  double? lat;

  /// 经度
  double? lng;
}