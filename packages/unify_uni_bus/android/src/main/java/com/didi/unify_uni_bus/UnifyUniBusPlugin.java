package com.didi.unify_uni_bus;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.EventChannel.EventSink;
import io.flutter.plugin.common.EventChannel.StreamHandler;

import java.util.HashMap;
import java.util.Map;

/** 
 * UnifyUniBusPlugin 
 * 实现Flutter与Android之间的事件通信
 */
public class UnifyUniBusPlugin implements FlutterPlugin, MethodCallHandler, StreamHandler {
  // 方法通道，用于接收Flutter的方法调用
  private MethodChannel methodChannel;
  
  // 事件通道，用于向Flutter发送事件流
  private EventChannel eventChannel;
  
  // 事件接收器，用于向Flutter发送事件
  private EventSink eventSink;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    // 初始化方法通道
    methodChannel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "unify_uni_bus");
    methodChannel.setMethodCallHandler(this);
    
    // 初始化事件通道
    eventChannel = new EventChannel(flutterPluginBinding.getBinaryMessenger(), "unify_uni_bus_events");
    eventChannel.setStreamHandler(this);
    
    // 将插件实例注册到UniBus单例
    UniBus.getInstance().setPluginInstance(this);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    switch (call.method) {
      case "getPlatformVersion":
        result.success("Android " + android.os.Build.VERSION.RELEASE);
        break;
      case "fire":
        try {
          // 从Flutter接收事件，转发给Android端UniBus
          String eventName = call.argument("eventName");
          Map<String, Object> data = call.argument("data");
          if (eventName != null && data != null) {
            UniBus.getInstance().receiveEventFromFlutter(eventName, data);
            result.success(true);
          } else {
            result.error("INVALID_ARGUMENTS", "Event name or data is null", null);
          }
        } catch (Exception e) {
          result.error("EXCEPTION", "Error firing event: " + e.getMessage(), null);
        }
        break;
      case "on":
        // Flutter端注册监听，在Android端不需要特殊处理
        // 因为Android端发来的事件会通过eventSink发送到Flutter
        result.success(true);
        break;
      default:
        result.notImplemented();
        break;
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    methodChannel.setMethodCallHandler(null);
    eventChannel.setStreamHandler(null);
    methodChannel = null;
    eventChannel = null;
  }
  
  // EventChannel.StreamHandler 接口实现
  @Override
  public void onListen(Object arguments, EventSink events) {
    this.eventSink = events;
  }
  
  @Override
  public void onCancel(Object arguments) {
    this.eventSink = null;
  }
  
  /**
   * 将Android端的事件发送到Flutter端
   * @param eventName 事件名称
   * @param data 事件数据
   */
  public void sendEventToFlutter(String eventName, Map<String, Object> data) {
    if (eventSink != null) {
      try {
        Map<String, Object> event = new HashMap<>();
        event.put("eventName", eventName);
        event.put("data", data);
        eventSink.success(event);
      } catch (Exception e) {
        eventSink.error("ERROR", "Error sending event to Flutter: " + e.getMessage(), null);
      }
    }
  }
}
