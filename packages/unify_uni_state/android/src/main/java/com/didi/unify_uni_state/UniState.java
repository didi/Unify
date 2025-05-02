package com.didi.unify_uni_state;

import com.didi.unify_uni_bus.UniBus;

import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Objects;
import java.util.Set;

public class UniState {
    private static final String UNI_STATE_EVENT = "unify_uni_state_event";

    private static final String EVENT_KEY_TYPE = "type";
    private static final String EVENT_KEY_STATE = "state";
    private static final String EVENT_KEY_VALUE = "value";
    private static final String EVENT_TYPE_STATE_CHANGE = "onStateChange";
    private static volatile UniState instance;

    // 与Flutter通信的插件实例引用
    private UnifyUniStatePlugin pluginInstance;

    // Key: StateKey, Value: List<UniStateListener> 状态监听器列表
    private Map<String, Set<UniStateListener>> stateListeners;

    // 状态键值对 key: StateKey, Value: StateValue
    private Map<String, Object> states;

    // 私有构造函数
    private UniState() {
        // 私有构造，防止外部实例化
        stateListeners = new HashMap<>();
        states = new HashMap<>();
        initEventBus();
    }

    public static UniState getInstance() {
        if (instance == null) {
            synchronized (UniState.class) {
                if (instance == null) {
                    instance = new UniState();
                }
            }
        }
        return instance;
    }

    void set(String stateKey, Object stateValue) {
        // 更新内部状态
        states.put(stateKey, stateValue);

        // 发送通知
        HashMap<String, Object> event = new HashMap<>();
        event.put(EVENT_KEY_TYPE, EVENT_TYPE_STATE_CHANGE);
        event.put(EVENT_KEY_STATE, stateKey);
        event.put(EVENT_KEY_VALUE, stateValue);

        UniBus.getInstance().fire(UNI_STATE_EVENT, event);
    }

    Object read(String stateKey) {
        return states.get(stateKey);
    }

    void watch(String stateKey, UniStateListener listener) {
        // 创建或获取状态监听器列表
        createListenerListIfNotExist(stateKey);

        // 添加监听器到列表
        Objects.requireNonNull(stateListeners.get(stateKey)).add(listener);
    }

    void unwatch(String stateKey, UniStateListener listener) {
        // 获取状态监听器列表
        Set<UniStateListener> listeners = stateListeners.get(stateKey);
        if (listeners != null) {
            // 移除监听器
            listeners.remove(listener);
        }
    }

    // 设置插件实例，用于与Flutter通信
    public void setPluginInstance(UnifyUniStatePlugin plugin) {
        this.pluginInstance = plugin;
    }

    private void initEventBus() {
        UniBus.getInstance().on(UNI_STATE_EVENT, data -> {
            String type = (String) data.get(EVENT_KEY_TYPE);
            if (type == null) {
                return;
            }

            String state = (String) data.get(EVENT_KEY_STATE);
            if (state == null || state.isEmpty()) {
                return;
            }

            createListenerListIfNotExist(state);
            for (UniStateListener listener : Objects.requireNonNull(stateListeners.get(state))) {
                listener.onStateChanged(data.get(EVENT_KEY_VALUE));
            }
        });
    }

    private void createListenerListIfNotExist(String stateKey) {
        Set<UniStateListener> listeners = stateListeners.get(stateKey);
        if (listeners == null) {
            listeners = new HashSet<>();
            stateListeners.put(stateKey, listeners);
        }
    }
}
