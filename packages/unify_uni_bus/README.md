# UnifyUniBus

UniBus 是一个 Flutter 事件总线，特色在于彻底打通了 Flutter 与 Android 的双端壁垒，实现了真正的**混合 EventBus 机制** - 在任意一端注册监听，都能接收来自两端的事件，一套代码打通全平台通信。让混合开发告别繁琐的平台通道代码 🚀

## 特性

- ✅ **双向事件监听**：在 Flutter 或 Android 的任意一方注册事件监听器
- ✅ **双向事件发送**：从 Flutter 或 Android 的任意一方发送事件，两端的监听器都能接收到
- ✅ **简单易用的 API**：提供直观的接口，使跨平台事件通信变得简单
- ✅ **多引擎支持**：支持在多 Flutter 引擎环境下工作（目前部分支持）

## 安装

### 在 pubspec.yaml 中添加依赖:

```yaml
dependencies:
  unify_uni_bus: ^latest_version
```

注意：目前还在开发中，请通过 git 以来方式引入:

```yaml
dependencies:
  unify_uni_bus:
    git:
      url: https://github.com/didi/Unify.git
      ref: master
      path: packages/unify_uni_bus
```

然后运行：

```bash
flutter pub get
```

## 使用方法

### 在 Flutter 中使用

#### 1. 导入包

```dart
import 'package:unify_uni_bus/unify_uni_bus.dart';
```

#### 2. 获取 UniBus 实例

```dart
final _uniBus = UniBus.instance;
```

#### 3. 注册事件监听

```dart
// 监听指定事件
final subscription = _uniBus.on('event_name').listen((data) {
  print('收到事件: $data');
});

// 不再需要时取消监听
subscription.cancel();
```

#### 4. 发送事件

```dart
// 发送事件到 Flutter 和 Android 端
await _uniBus.fire('event_name', {
  'message': 'Hello from Flutter',
  'timestamp': DateTime.now().millisecondsSinceEpoch,
});
```

### 在 Android 中使用

#### 1. 获取 UniBus 实例

```java
// 获取单例实例
UniBus uniBus = UniBus.getInstance();
```

#### 2. 注册事件监听

```java
// 定义事件监听器
UniBus.EventListener listener = new UniBus.EventListener() {
    @Override
    public void onEvent(Map<String, Object> data) {
        // 处理收到的事件数据
        String message = (String) data.get("message");
        // TODO: 处理事件
    }
};

// 注册事件监听
uniBus.on("event_name", listener);

// 不再需要时移除监听
uniBus.off("event_name", listener);
```

#### 3. 发送事件

```java
// 创建事件数据
Map<String, Object> eventData = new HashMap<>();
eventData.put("message", "Hello from Android");
eventData.put("timestamp", System.currentTimeMillis());

// 发送事件到 Android 端和 Flutter 端
uniBus.fire("event_name", eventData);
```

## Special Thanks

This code is inspired by the dart-event-bus project (https://github.com/marcojakob/dart-event-bus), which is licensed under the MIT License.

We thank the authors of dart-event-bus for their work.

