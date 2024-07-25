package com.didi.unify_uni_page_example;

import com.didi.unify_uni_page.UnifyUniPagePlugin;
import com.didi.unify_uni_page_example.uni_pages.UniPageDemo;

import io.flutter.app.FlutterApplication;

public class MainApplication extends FlutterApplication {

    @Override
    public void onCreate() {
        super.onCreate();
        UnifyUniPagePlugin.registerUniPage("demo", UniPageDemo.class);
    }
}
