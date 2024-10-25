import 'package:unify_flutter/api/api.dart';

import 'model/upgrade_data.dart';

@UniNativeModule()
abstract class UpgradeService {
  void upgrade(UpgradeData data);
}
