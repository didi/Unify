package com.example.unicallback_demo_example;

import com.example.unifluttermodule_demo.UniCallbackTestService;

public class UniCallbackTestServiceImpl implements UniCallbackTestService {
    private OnDoCallbackAction0Callback mCallback;

    /**
     * UniCallback 的第一种使用方法，可将 callback 保存起来
     * 该方法适合于：在业务其它地方调用回传，比如在原生定位 SDK 的回调中调用
     * @param callback
     */
    @Override
    public void doCallbackAction0(OnDoCallbackAction0Callback callback) {
        mCallback = callback;
    }

    /**
     * UniCallback 的第二种种使用方法，在函数（doCallbackAction1）内执行异步操作，通过 callback 返回结果
     * 该方法适合于：原生执行一个诸如网络请求的异步操作，将结果异步回传
     * @param callback
     */
    @Override
    public void doCallbackAction1(OnDoCallbackAction1Callback callback) {
        callback.onEvent("I come from the function doCallbackAction1");
    }
}
