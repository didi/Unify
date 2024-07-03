package com.didi.unify_unipage_example;

import androidx.annotation.NonNull;

import com.didi.unify_unipage.UniPageRegister;
import com.didi.unify_unipage_example.unipages.UniPageDemo;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;

public class MainActivity extends FlutterActivity {
    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        // Todo 这里后面改成 Builder 模式
        UniPageRegister.registerUniPage("demo", UniPageDemo.class);
        UniPageRegister.attachToEngine(flutterEngine);
    }
}
