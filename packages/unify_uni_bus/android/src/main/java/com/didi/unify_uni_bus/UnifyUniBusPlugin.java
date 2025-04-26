package com.didi.unify_uni_bus;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

/** 
 * UnifyUniBusPlugin 
 * 实现Flutter与Android之间的事件通信
 * 支持多引擎环境
 */
public class UnifyUniBusPlugin implements FlutterPlugin, MethodCallHandler {
  // 存储每个引擎的方法通道，用于接收Flutter的方法调用和发送事件
  private final Map<Object, MethodChannel> methodChannels = new HashMap<>();
  
  // 使用Set存储已经连接的引擎标识
  private final Set<Object> connectedEngines = new HashSet<>();

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    // 获取BinaryMessenger作为引擎的唯一标识
    Object engineKey = flutterPluginBinding.getBinaryMessenger();
    
    // 初始化当前引擎的方法通道
    MethodChannel methodChannel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "unify_uni_bus");
    methodChannel.setMethodCallHandler(this);
    methodChannels.put(engineKey, methodChannel);
    connectedEngines.add(engineKey);
    
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
    // 获取要释放的引擎标识
    Object engineKey = binding.getBinaryMessenger();
    
    // 清除该引擎的方法通道
    MethodChannel methodChannel = methodChannels.remove(engineKey);
    if (methodChannel != null) {
      methodChannel.setMethodCallHandler(null);
    }
    
    // 从已连接引擎集合中移除
    connectedEngines.remove(engineKey);
  }
  
  
  /**
   * 将Android端的事件发送到Flutter端
   * @param eventName 事件名称
   * @param data 事件数据
   */
  public void sendEventToFlutter(String eventName, Map<String, Object> data) {
    // 创建事件数据
    Map<String, Object> event = new HashMap<>();
    event.put("eventName", eventName);
    event.put("data", data);
    
    // 向所有已连接的引擎广播事件
    for (Object engineKey : connectedEngines) {
      MethodChannel channel = methodChannels.get(engineKey);
      if (channel != null) {
        try {
          // 使用invokeMethod发送事件到Flutter
          channel.invokeMethod("onEvent", event);
        } catch (Exception e) {
          System.err.println("Error sending event to Flutter: " + e.getMessage());
        }
      }
    }
  }
}
