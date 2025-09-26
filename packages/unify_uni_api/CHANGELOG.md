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