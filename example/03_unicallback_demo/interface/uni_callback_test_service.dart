import 'package:unicallback_demo/uniapi/uni_callback.dart';
import 'package:unify_flutter/api/api.dart';
import 'location_info_model.dart';

@UniNativeModule()
abstract class UniCallbackTestService {
  /// 更新定位信息
  void doCallbackAction0(UniCallback<LocationInfoModel> callback);

  void doCallbackAction1(UniCallback<String> callback);
}
