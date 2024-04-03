package com.example.uninativemodule_demo_example;

import com.example.uninativemodule_demo.DeviceInfoModel;
import com.example.uninativemodule_demo.DeviceInfoService;

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
