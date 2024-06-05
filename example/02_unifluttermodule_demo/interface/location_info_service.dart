import 'package:unify/api/api.dart';
import 'location_info_model.dart';

@UniFlutterModule()
abstract class LocationInfoService {
  /// 更新定位信息
  void updateLocationInfo(LocationInfoModel model);
}