package com.example.hello_uni_foundation_example;

import com.didi.hello_uni_foundation.DeviceInfoModel;
import com.didi.hello_uni_foundation.DeviceInfoService;

public class DeviceInfoServiceImpl implements DeviceInfoService {
    @Override
    public void getDeviceInfo(Result<DeviceInfoModel> result) {
        DeviceInfoModel model = new DeviceInfoModel();
        model.setPlaform("Android");
        model.setOsVersion("12");
        model.setMemory("8GB");
        result.success(model);
    }
}
