package com.example.uninativemodule_demo_example;

import androidx.annotation.NonNull;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;

import com.example.uninativemodule_demo.DeviceInfoServiceRegister;

public class MainActivity extends FlutterActivity {

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        // UniNativeModule 初始化，在此注入原生实现
        DeviceInfoServiceRegister.setup(
                flutterEngine.getDartExecutor(),
                new DeviceInfoServiceImpl());
    }
}
