package com.didi.unify_unipage;

import android.content.Context;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

public abstract class AbsUniPageFactory extends PlatformViewFactory {

    public AbsUniPageFactory() {
        super(StandardMessageCodec.INSTANCE);
    }

    abstract Class<? extends UniPage> pageClass();

    abstract String viewType();

    abstract BinaryMessenger getBinaryMessenger();

    @NonNull
    @Override
    public PlatformView create(Context context, int viewId, @Nullable Object args) {
        MethodChannel channel = new MethodChannel(
                getBinaryMessenger(),
                Constants.createChannelName(viewType(), viewId));
        try {
            UniPage instance = pageClass().newInstance();
            instance.init(context, viewType(), viewId, channel, (Map<String, Object>) args);
            return instance;
        } catch (IllegalAccessException e) {
            throw new RuntimeException(e);
        } catch (InstantiationException e) {
            throw new RuntimeException(e);
        }
    }
}
