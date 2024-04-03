import 'package:unifluttermodule_demo/location_info_model.dart';
import 'package:unifluttermodule_demo/location_info_service.dart';
import 'package:unifluttermodule_demo_example/my_event_bus.dart';

class LocationInfoServiceImpl extends LocationInfoService {
  @override
  void updateLocationInfo(LocationInfoModel model) {
    // TODO: implement updateLocationInfo
    myEventBus.fire(model.encode().toString());
  }
}
