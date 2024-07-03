package com.didi.unify_unipage;

import android.content.Context;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.util.Map;

import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

public abstract class AbsUniPageFactory extends PlatformViewFactory {

    public AbsUniPageFactory() {
        super(StandardMessageCodec.INSTANCE);
    }

    abstract Class<? extends UniPage> pageClass();

    @NonNull
    @Override
    public PlatformView create(Context context, int viewId, @Nullable Object args) {
        try {
            UniPage instance = pageClass().newInstance();
            instance.init(context, viewId, (Map<String, Object>) args);
            return instance;
        } catch (IllegalAccessException e) {
            throw new RuntimeException(e);
        } catch (InstantiationException e) {
            throw new RuntimeException(e);
        }
    }
}
