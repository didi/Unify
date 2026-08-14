import 'package:unifluttermodule_demo/location_info_model.dart';
import 'package:unifluttermodule_demo/location_info_service.dart';
import 'package:unifluttermodule_demo_example/my_event_bus.dart';

class LocationInfoServiceImpl extends LocationInfoService {
  @override
  void updateLocationInfo(LocationInfoModel model) {
    // TODO: implement updateLocationInfo
    myEventBus.fire(model.encode().toString());
  }

  @override
  int test(bool st) {
    // TODO: implement test
    throw UnimplementedError();
  }

  @override
  bool test2(double st) {
    // TODO: implement test2
    throw UnimplementedError();
  }

  @override
  String test3(int st) {
    // TODO: implement test3
    throw UnimplementedError();
  }

  @override
  int? test4(int st) {
    // TODO: implement test4
    throw UnimplementedError();
  }

  @override
  Future<int> test5(Map<String, int> st) {
    // TODO: implement test5
    throw UnimplementedError();
  }
}
