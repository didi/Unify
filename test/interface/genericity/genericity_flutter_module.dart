import 'package:unify/api/api.dart';

import 'genericity_model.dart';

@UniFlutterModule()
abstract class GenericityFlutterModule {
  void test1(GenericityModel data);
  void test2(List<GenericityModel> data);
  void test3(List<GenericityModel>? data);
  void test4(Map<String, List<GenericityModel>?> data);
  void test5(Map<String, List<GenericityModel>?>? data);

  GenericityModel test6(Map<String, List<GenericityModel>?>? data);
  GenericityModel? test7(Map<String, List<GenericityModel>?>? data);

  List<GenericityModel> test8(Map<String, List<GenericityModel>?>? data);
  List<GenericityModel>? test9(Map<String, List<GenericityModel>?>? data);
  List<GenericityModel?>? test10(Map<String, List<GenericityModel>?>? data);

  Map<String, List<GenericityModel?>?> test11(
      Map<String, List<GenericityModel>?>? data);
  Map<String, List<GenericityModel?>?>? test12(
      Map<String, List<GenericityModel>?>? data);

  List<Map<String, List<GenericityModel?>?>?> test13(
      Map<String, List<GenericityModel>?>? data);
  List<Map<String, List<GenericityModel?>?>?> test14(
      List<Map<String, List<GenericityModel>?>?> data);

  Future<List<Map<String, List<GenericityModel?>?>?>> test15(
      List<Map<String, List<GenericityModel>?>?> data);
  Future<List<Map<String, List<GenericityModel?>?>?>>? test16(
      List<Map<String, List<GenericityModel>?>?> data);
  Future<void> test17(
      Map<String, List<Map<String, List<GenericityModel>?>?>> data);
}
