package com.didi.unify_uni_bus;

import androidx.annotation.NonNull;

import java.util.Map;
import java.util.HashMap;
import java.util.List;
import java.util.ArrayList;
import java.util.concurrent.ConcurrentHashMap;

/**
 * UniBus - Android端事件总线
 * 实现Android端的事件监听和发送，并与Flutter端通信
 */
public class UniBus {
    // 单例实例
    private static volatile UniBus instance;
    
    // 事件监听器映射表
    private final ConcurrentHashMap<String, List<EventListener>> eventListeners = new ConcurrentHashMap<>();
    
    // 与Flutter通信的插件实例引用
    private UnifyUniBusPlugin pluginInstance;
    
    // 私有构造函数
    private UniBus() {
        // 私有构造，防止外部实例化
    }
    
    // 获取单例实例
    public static UniBus getInstance() {
        if (instance == null) {
            synchronized (UniBus.class) {
                if (instance == null) {
                    instance = new UniBus();
                }
            }
        }
        return instance;
    }
    
    // 设置插件实例，用于与Flutter通信
    public void setPluginInstance(UnifyUniBusPlugin plugin) {
        this.pluginInstance = plugin;
    }
    
    /**
     * 监听指定事件
     * @param eventName 事件名称
     * @param listener 事件监听器
     */
    public void on(String eventName, EventListener listener) {
        eventListeners.computeIfAbsent(eventName, k -> new ArrayList<>()).add(listener);
    }
    
    /**
     * 移除事件监听
     * @param eventName 事件名称
     * @param listener 要移除的监听器，如果为null则移除该事件的所有监听器
     */
    public void off(String eventName, EventListener listener) {
        List<EventListener> listeners = eventListeners.get(eventName);
        if (listeners != null) {
            if (listener == null) {
                listeners.clear();
            } else {
                listeners.remove(listener);
            }
            
            if (listeners.isEmpty()) {
                eventListeners.remove(eventName);
            }
        }
    }
    
    /**
     * 发送事件到Android端和Flutter端
     * @param eventName 事件名称
     * @param data 事件数据
     */
    public void fire(String eventName, Map<String, Object> data) {
        // 触发Android端的监听器
        notifyAndroidListeners(eventName, data);
        
        // 将事件发送到Flutter端
        if (pluginInstance != null) {
            pluginInstance.sendEventToFlutter(eventName, data);
        }
    }
    
    /**
     * 接收来自Flutter的事件，触发Android端监听器
     * @param eventName 事件名称
     * @param data 事件数据
     */
    public void receiveEventFromFlutter(String eventName, Map<String, Object> data) {
        notifyAndroidListeners(eventName, data);
    }
    
    /**
     * 通知Android端的事件监听器
     */
    private void notifyAndroidListeners(String eventName, Map<String, Object> data) {
        List<EventListener> listeners = eventListeners.get(eventName);
        if (listeners != null) {
            // 创建副本以避免并发修改异常
            List<EventListener> listenersCopy = new ArrayList<>(listeners);
            for (EventListener listener : listenersCopy) {
                listener.onEvent(data);
            }
        }
    }
    
    /**
     * 事件监听器接口
     */
    public interface EventListener {
        void onEvent(Map<String, Object> data);
    }
}
