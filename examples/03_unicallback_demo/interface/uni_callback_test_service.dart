import 'package:unicallback_demo/uniapi/uni_callback.dart';
import 'package:unify/api/api.dart';
import 'location_info_model.dart';

@UniNativeModule()
abstract class UniCallBackTestService {
  /// 更新定位信息
  void doCallbackAction0(UniCallback<LocationInfoModel> callback);

  void doCallbackAction1(UniCallback<String> callback);
}