package com.didi.unify_uni_page;

import android.content.Context;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

public abstract class AbsUniPageFactory extends PlatformViewFactory {

    private AbsUniPageFactoryListener factoryListener;

    public AbsUniPageFactory() {
        super(StandardMessageCodec.INSTANCE);
    }

    public void setFactoryListener(AbsUniPageFactoryListener factoryListener) {
        this.factoryListener = factoryListener;
    }

    abstract Class<? extends UniPage> pageClass();

    abstract String viewType();

    abstract BinaryMessenger getBinaryMessenger();

    @NonNull
    @Override
    public PlatformView create(Context context, int viewId, @Nullable Object args) {
        if (factoryListener != null) {
            factoryListener.onPlatformViewCreate(context, viewId, args);
        }
        try {
            UniPage instance = pageClass().newInstance();
            instance.init(context, viewType(), viewId, getBinaryMessenger(), (Map<String, Object>) args);
            return instance;
        } catch (IllegalAccessException e) {
            throw new RuntimeException(e);
        } catch (InstantiationException e) {
            throw new RuntimeException(e);
        }
    }
}
