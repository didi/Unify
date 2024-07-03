package com.didi.unify_unipage;

import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformViewRegistry;

public class UniPageRegister {

    public static MethodChannel channel;

    private static final Map<String, Class<? extends UniPage>> pageRegister = new HashMap<>();

    public static void registerUniPage(String pageType, Class<? extends UniPage> pageClass) {
        if (!pageRegister.containsKey(pageType)) {
            pageRegister.put(pageType, pageClass);
        }
    }

    public static void attachToEngine(FlutterEngine engine) {
        channel = new MethodChannel(engine.getDartExecutor().getBinaryMessenger(), Constants.UNI_PAGE_CHANNEL);
        for (Map.Entry<String, Class<? extends UniPage>> item : pageRegister.entrySet()) {
            engine.getPlatformViewsController().getRegistry().registerViewFactory(item.getKey(), new AbsUniPageFactory() {
                @Override
                Class<? extends UniPage> pageClass() {
                    return item.getValue();
                }
            });
        }
    }
}
