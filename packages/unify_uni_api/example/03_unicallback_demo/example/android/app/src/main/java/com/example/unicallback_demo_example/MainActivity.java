package com.example.unicallback_demo_example;

import androidx.annotation.NonNull;

import com.example.unifluttermodule_demo.UniCallbackTestServiceRegister;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;

public class MainActivity extends FlutterActivity {

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        UniCallbackTestServiceRegister.setup(
                flutterEngine.getDartExecutor(),
                new UniCallbackTestServiceImpl());
    }
}
