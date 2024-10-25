package com.example.unifluttermodule_demo_example;

import android.os.Bundle;
import android.os.Handler;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.example.unifluttermodule_demo.LocationInfoModel;
import com.example.unifluttermodule_demo.LocationInfoService;
import com.example.unifluttermodule_demo.UFUniAPI;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;

public class MainActivity extends FlutterActivity {
    private Handler mHandler;

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        // UniFlutterModule 初始化，只需要关联引擎 BinaryMessenger
        LocationInfoService locationInfoService = new LocationInfoService();
        locationInfoService.setup(flutterEngine.getDartExecutor());
    }

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mHandler = new Handler();
        mHandler.postDelayed(this::sendMockLocation, 5000);
    }

    // 演示原生侧如何调用 UniFlutterModule 模块方法（实现在 Flutter 侧），并接受调用返回值
    private void sendMockLocation() {
        LocationInfoModel locationInfoModel = new LocationInfoModel();
        // 设置 Mock 经纬度，并发送到 Flutter 侧
        locationInfoModel.setLat(100.0);
        locationInfoModel.setLng(100.0);
        UFUniAPI.get(LocationInfoService.class).updateLocationInfo(locationInfoModel);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        mHandler.removeCallbacks(this::sendMockLocation);
        mHandler = null;
    }
}
