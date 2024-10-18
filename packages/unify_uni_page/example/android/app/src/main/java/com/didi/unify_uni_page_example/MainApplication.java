package com.didi.unify_uni_page_example;

import com.didi.unify_uni_page.UniPageLifecycleCallbacks;
import com.didi.unify_uni_page.UnifyUniPagePlugin;
import com.didi.unify_uni_page_example.uni_pages.DemoUniPage;
import com.didi.unify_uni_page_example.uni_pages.DemoComplexUniPage;

import io.flutter.app.FlutterApplication;

public class MainApplication extends FlutterApplication {

    @Override
    public void onCreate() {
        UnifyUniPagePlugin.registerUniPage("demo_uni_page", DemoUniPage.class);
        UnifyUniPagePlugin.registerUniPage("demo", DemoComplexUniPage.class);
        registerActivityLifecycleCallbacks(new UniPageLifecycleCallbacks());
        super.onCreate();
    }
}
