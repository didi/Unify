## 3.0.6

* feat: 在 UniFlutterModule 模式(native -> dart),新增 API 修饰注解 `@UniBufferSize(n)`,用于为指定方法对应的 platform channel 扩大消息缓冲区(默认容量为 1)。可解决原生在 Dart 侧 handler 注册前连续发消息时,早到消息被丢弃的问题。生成的原生 `setup` 会在建立 channel 时调用 `resizeChannelBuffer`(iOS)/`resizeChannelBuffer`(Android)。未标注的方法保持原有逻辑不变;`n` 必须为正整数字面量,非法值将告警并忽略;与 `@RequiredMessager` 同时标注时忽略并告警(目标 messenger 由每次调用决定)。
* fix: [iOS] UniAPI 生成的 OC 接口，基础类型(int/double/bool)统一装箱为 NSNumber*，与 Dart 声明类型不一致；改为映射为原生标量(NSInteger/double/BOOL)使参数与返回值类型对齐声明，可空类型及集合泛型实参位置仍回退 NSNumber*。同步修复 UniNativeModule / UniFlutterModule / UniCallback 三条通道中标量装箱/拆箱的胶水代码。
* fix: [iOS] 承接上条标量映射改动,修复 UniFlutterModule 回调路径的 ARC 报错:`UniCompleted` 回调形参为 `id`,而非空标量返回值被拆箱成 `NSInteger`/`BOOL`/`double` 后直接传入,触发 "Implicit conversion ... to 'id' is disallowed with ARC"。改为在目标为 `id` 时不拆箱,沿用 channel 传来的 NSNumber。

## 3.0.5

* fix: Flutter 与原生侧 UNICallback 的 key 名称不一致导致，UNICallback析构事件获取名称时 null，引发异常
* fix: [Andriod] UniAPI 生成 UniNativeModule 类型接口，给 Flutter 回数据时，业务实现时传入 null 的自定义类型对象，比如：PayResultModel 型参数，此时会触发 Java 侧 try-catch，并将异常同步至 Flutter 可能对业务实现逻辑造成影响。

## 3.0.4

* 支持 UniCallback dispose 事件的跨平台双向同步
* 泛型嵌套场景，代码生成逻辑优化：减少冗余代码生成

## 3.0.3

* feat: 在 UniFlutterModule 模式，新增 API 修饰注解`@RequiredMessager()`, 使得 UniAPI 生成的接口支持多引擎并行调用
* chore: sdk 最低支持版本提升到 '3.0.0'

## 3.0.2

* 移除 pedantic，改由 lints 进行替代
* 升级适配 analyzer 7.4.6

## 3.0.1

* fix：包改名后，CLI 未及时同步更新，引发运行报错问题；
* update： 包改名后，同步更新文档对应的包名。

## 3.0.0

* First Release.