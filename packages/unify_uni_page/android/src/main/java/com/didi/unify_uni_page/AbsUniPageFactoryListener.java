package com.didi.unify_uni_page;

import android.content.Context;

import androidx.annotation.Nullable;

public interface AbsUniPageFactoryListener {
    void onPlatformViewCreate(Context context, int viewId, @Nullable Object args);

    void onPlatformViewDispose(Context context, int viewId);
}
