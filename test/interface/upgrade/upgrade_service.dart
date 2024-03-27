import 'package:unify/api/api.dart';

import 'model/upgrade_data.dart';

@UniNativeModule()
abstract class UpgradeService {
  void upgrade(UpgradeData data);
}
