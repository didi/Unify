package com.didi.unify_uni_state;

import androidx.annotation.NonNull;

import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/** UnifyUniStatePlugin */
public class UnifyUniStatePlugin implements FlutterPlugin, MethodCallHandler {
  // 存储每个引擎的方法通道，用于接收Flutter的方法调用和发送事件
  private final Map<Object, MethodChannel> methodChannels = new HashMap<>();

  // 使用Set存储已经连接的引擎标识
  private final Set<Object> connectedEngines = new HashSet<>();

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    // 获取BinaryMessenger作为引擎的唯一标识
    Object engineKey = flutterPluginBinding.getBinaryMessenger();

    // 初始化当前引擎的方法通道
    MethodChannel methodChannel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "unify_uni_state_channel");
    methodChannel.setMethodCallHandler(this);
    methodChannels.put(engineKey, methodChannel);
    connectedEngines.add(engineKey);

    // 将插件实例注册到UniBus单例
    UniState.getInstance().setPluginInstance(this);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    switch (call.method) {
      case "get":
        try {
          // 从Flutter接收事件，转发给Android端UniState
          String key = call.argument("state");
          if (key != null) {
            Object value = UniState.getInstance().read(key);
            result.success(value);
          } else {
            result.error("INVALID_ARGUMENTS", "State key is null", null);
          }
        } catch (Exception e) {
          result.error("EXCEPTION", "Error getting state: " + e.getMessage(), null);
        }
        break;
      case "set":
        try {
          // 从Flutter接收事件，转发给Android端UniState
          String key = call.argument("state");
          Object value = call.argument("value");
          if (key != null) {
            UniState.getInstance().set(key, value);
            result.success(true);
          } else {
            result.error("INVALID_ARGUMENTS", "State key is null", null);
          }
        } catch (Exception e) {
          result.error("EXCEPTION", "Error setting state: " + e.getMessage(), null);
        }
        break;
      case "readAll":
        try {
          // 从Flutter接收事件，转发给Android端UniState
          result.success(UniState.getInstance().getState());
        } catch (Exception e) {
          result.error("EXCEPTION", "Error reading all states: " + e.getMessage(), null);
        }
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
}
