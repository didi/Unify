package com.didi.unify_uni_page;

import android.app.Activity;
import android.app.Application;
import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

/**
 * UniPage 的 Activity 生命周期回调。
 * 在 Application 中使用 registerActivityLifecycleCallbacks 注册该类后，
 * UniPage 方可响应 onForeground 与 onBackground。
 */
public class UniPageLifecycleCallbacks implements Application.ActivityLifecycleCallbacks {
    @Override
    public void onActivityCreated(@NonNull Activity activity, @Nullable Bundle savedInstanceState) {

    }

    @Override
    public void onActivityStarted(@NonNull Activity activity) {
        UniPageLifecycleHolder.getInstance().notifyOnForeground(activity);
    }

    @Override
    public void onActivityResumed(@NonNull Activity activity) {

    }

    @Override
    public void onActivityPaused(@NonNull Activity activity) {

    }

    @Override
    public void onActivityStopped(@NonNull Activity activity) {
        UniPageLifecycleHolder.getInstance().notifyOnBackground(activity);
    }

    @Override
    public void onActivitySaveInstanceState(@NonNull Activity activity, @NonNull Bundle outState) {

    }

    @Override
    public void onActivityDestroyed(@NonNull Activity activity) {
        UniPageLifecycleHolder.getInstance().unbindActivity(activity);
    }
}
