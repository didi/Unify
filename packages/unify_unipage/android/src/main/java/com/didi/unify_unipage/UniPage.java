package com.didi.unify_unipage;

import android.content.Context;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;

public abstract class UniPage implements PlatformView {
    private View view;
    private Context context;
    private int viewId;
    private Map<String, Object> creationParams;

    public UniPage() {
    }

    /**********************************************
     *  UniPage 生命周期
     **********************************************/

    /**
     * 嵌原生页面创建
     * @return 嵌原生页面的根视图
     */
    public abstract View onCreate();

    /**
     * 嵌原生页面释放
     * 释放页面所依赖的资源，避免内存泄漏
     */
    public abstract void onDispose();

    /**********************************************
     *  资源获取
     **********************************************/

    public Context getContext() {
        return context;
    }

    public int getViewId() {
        return viewId;
    }

    public Map<String, Object> getCreationParams() {
        return creationParams;
    }

    /**********************************************
     *  Flutter Navigator 路由
     **********************************************/

    public void pushNamed(String routePath, Map<String, Object> params) {
        Map<String, Object> paramsMap = new HashMap<>();
        paramsMap.put(Constants.UNI_PAGE_CHANNEL_PARAMS_PATH, routePath);
        paramsMap.put(Constants.UNI_PAGE_CHANNEL_PARAMS_PARAMS, params);
        UniPageRegister.channel.invokeMethod(Constants.UNI_PAGE_ROUTE_PUSH_NAMED, paramsMap);
    }

    public void pop(Object result) {
        Map<String, Object> paramsMap = new HashMap<>();
        paramsMap.put(Constants.UNI_PAGE_CHANNEL_PARAMS_PARAMS, result);
        UniPageRegister.channel.invokeMethod(Constants.UNI_PAGE_ROUTE_POP, paramsMap);
    }

    /**********************************************
     *  嵌原生接口
     **********************************************/

    public void init(@NonNull Context context, int id, @Nullable Map<String, Object> creationParams) {
        this.context = context;
        this.viewId = id;
        this.creationParams = creationParams;
    }

    @Nullable
    @Override
    public View getView() {
        if (view == null) {
            view = onCreate();
        }
        return view;
    }

    @Override
    public void dispose() {
        onDispose();
        this.context = null;
    }
}
