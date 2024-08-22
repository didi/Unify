package com.didi.unify_uni_page;

import androidx.annotation.NonNull;

import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;

/**
 * UnifyUniPagePlugin
 */
public class UnifyUniPagePlugin implements FlutterPlugin {

    private static final Map<String, Class<? extends UniPage>> pageRegister = new HashMap<>();

    public static void registerUniPage(String viewType, Class<? extends UniPage> pageClass) {
        if (!pageRegister.containsKey(viewType)) {
            pageRegister.put(viewType, pageClass);
        }
    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        for (Map.Entry<String, Class<? extends UniPage>> item : pageRegister.entrySet()) {
            flutterPluginBinding.getPlatformViewRegistry().registerViewFactory(item.getKey(), new AbsUniPageFactory() {
                @Override
                Class<? extends UniPage> pageClass() {
                    return item.getValue();
                }

                @Override
                String viewType() {
                    return item.getKey();
                }

                @Override
                BinaryMessenger getBinaryMessenger() {
                    return flutterPluginBinding.getBinaryMessenger();
                }
            });
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    }
}
