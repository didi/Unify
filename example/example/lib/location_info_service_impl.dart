import 'package:hello_uni_foundation/location_info_model.dart';
import 'package:hello_uni_foundation/location_info_service.dart';
import 'package:hello_uni_foundation_example/my_event_bus.dart';

class LocationInfoServiceImpl extends LocationInfoService {
  @override
  void updateLocationInfo(LocationInfoModel model) {
    // TODO: implement updateLocationInfo
    myEventBus.fire(model.encode().toString());
  }
}
