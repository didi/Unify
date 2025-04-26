package com.didi.unify_uni_bus_example;

import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.FrameLayout;

import androidx.annotation.Nullable;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

import com.didi.unify_uni_bus.UniBus;

import java.util.HashMap;
import java.util.Map;

public class MainActivity extends FlutterActivity {
    private static final String TAG = "UniBusDemo";
    private static final String TEST_EVENT_NAME = "test_event";
    
    private MethodChannel channel;
    private UniBus.EventListener androidEventListener;
    private Button sendEventButton;
    
    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        
        // 注册Android端的事件监听器
        registerAndroidEventListener();
        
        // 在Flutter视图上覆盖添加Android按钮
        addAndroidButtonToFlutter();
    }
    
    // 在Flutter UI上添加Android原生按钮
    private void addAndroidButtonToFlutter() {
        // 从布局文件创建Android按钮视图
        View buttonView = getLayoutInflater().inflate(R.layout.android_button_layout, null);
        sendEventButton = buttonView.findViewById(R.id.btn_send_event);
        
        // 设置按钮点击事件
        sendEventButton.setOnClickListener(v -> {
            sendEventFromAndroid();
        });
        
        // 获取Flutter活动的根视图
        final ViewGroup decorView = (ViewGroup) getWindow().getDecorView();
        final ViewGroup flutterView = decorView.findViewById(android.R.id.content);
        
        // 创建FrameLayout容器参数
        FrameLayout.LayoutParams params = new FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
        );
        params.gravity = Gravity.BOTTOM;
        
        // 添加到Flutter视图上
        new Handler(Looper.getMainLooper()).post(() -> {
            if (flutterView != null) {
                flutterView.addView(buttonView, params);
            }
        });
    }
    
    // 注册Android端的事件监听
    private void registerAndroidEventListener() {
        // 创建事件监听器
        androidEventListener = data -> {
            Log.i(TAG, "Android: 收到事件 \"" + TEST_EVENT_NAME + "\" 数据: " + data.toString());
        };

        // 注册到UniBus
        UniBus.getInstance().on(TEST_EVENT_NAME, androidEventListener);

        Log.i(TAG, "Android: 已注册事件监听器");
    }
    
    // 从Android发送事件到总线
    private void sendEventFromAndroid() {
        new Handler(Looper.getMainLooper()).post(() -> {
            Map<String, Object> eventData = new HashMap<>();
            eventData.put("message", "Hello from Android");
            eventData.put("timestamp", System.currentTimeMillis());
            
            Log.i(TAG, "Android: 发送事件 \"" + TEST_EVENT_NAME + "\" 数据: " + eventData);
            
            // 通过UniBus发送事件
            UniBus.getInstance().fire(TEST_EVENT_NAME, eventData);
        });
    }
    
    @Override
    protected void onDestroy() {
        // 移除事件监听器
        if (androidEventListener != null) {
            UniBus.getInstance().off(TEST_EVENT_NAME, androidEventListener);
            Log.i(TAG, "Android: 已移除事件监听器");
        }
        
        // 移除方法调用处理器
        if (channel != null) {
            channel.setMethodCallHandler(null);
        }
        
        super.onDestroy();
    }
}
