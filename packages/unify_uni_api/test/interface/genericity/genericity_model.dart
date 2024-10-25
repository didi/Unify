import 'package:unify_flutter/api/api.dart';

import 'genericity_data.dart';

@UniModel()
class GenericityModel {
  List<String>? a;
  Map<String, List<String>?>? b;
  List<Map<String, List<String>?>>? c;
  List<Map<String, List<Map<String, List<GenericityData>?>>?>>? d;
  int? e;
}
