package com.didi.unify_unipage_example;

import com.didi.unify_unipage.UnifyUniPagePlugin;
import com.didi.unify_unipage_example.unipages.UniPageDemo;

import io.flutter.app.FlutterApplication;

public class MainApplication extends FlutterApplication {

    @Override
    public void onCreate() {
        super.onCreate();
        UnifyUniPagePlugin.registerUniPage("demo", UniPageDemo.class);
    }
}
