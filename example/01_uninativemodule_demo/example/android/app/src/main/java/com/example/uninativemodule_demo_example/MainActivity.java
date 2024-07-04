package com.example.uninativemodule_demo_example;

import android.util.Log;

import androidx.annotation.NonNull;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;

import com.example.uninativemodule_demo.DeviceInfoService;
import com.example.uninativemodule_demo.DeviceInfoServiceRegister;
import com.example.uninativemodule_demo.UDUniAPI;

public class MainActivity extends FlutterActivity {

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        // UniNativeModule 初始化，在此注入原生实现
        DeviceInfoServiceRegister.setup(
                flutterEngine.getDartExecutor(),
                new DeviceInfoServiceImpl());

        // 在 Android 端以统一调用方式调用 Unify 模块
        UDUniAPI.get(DeviceInfoService.class).getDeviceInfo(
                result -> Log.d("Unify", result.toMap().toString()));
    }
}
