# Unify：Flutter混合开发架构体系

Flutter 作为跨端开发技术，能够通过一套 Dart 代码高效实现多平台应用。但对于复杂应用而言，仍需开发平台相关的原生代码，并实现与 Flutter 的交互，我们称之为混合开发。混合开发包含不同的方面：混合通信、UI 混合、混合状态管理、持久化。

Unify 提供了一套混合架构体系，为开发者提供混合开发的一站式解决方案。通过 Unify，能够显著提升了混合开发的效率，降低了维护成本。

Unify 架构体系由不同部分组成：

- **[UniAPI](https://github.com/didi/Unify/tree/master/packages/unify_uni_api)**：
  - UniAPI 旨在解决 Flutter 与原生模块之间的通信问题。
  - 它支持平台无关的模块抽象、灵活的实现注入、自动代码生成等特性，显著提升了混合开发的效率，降低了维护成本。
  - 基于 UniAPI，衍生出两种架构模式：
    - UniFoundation：适合于高效批量到处平台原生能力，形成一套能够在 Android、iOS、Flutter 三端统一调用的基建能力。
    - UniBusines：适合于对业务模块进行平台无关的业务抽象，能够在三端，以统一的方式实现模块调用、复杂实体透传。
- **[UniPage](https://github.com/didi/Unify/tree/master/packages/unify_uni_page)**：
  - UniPage 旨在解决 Flutter 与原生 UI 之间的混合嵌入问题。
  - UniPage 基于 PlatformView 引入 UniPage 页面生命周期，提供一种原生页面的嵌入方式。
  - 支持直接使用 Flutter 的 Navigator 调度，混合开发的复杂度与维护成本均可大幅降低。
- **[UniBus](https://github.com/didi/Unify/tree/master/packages/unify_uni_bus)**：
  - UniBus 是一个 Flutter 事件总线，特色在于彻底打通了 Flutter 与 Android 的双端壁垒，实现了真正的混合 EventBus 机制 
  - 在任意一端注册监听，都能接收来自两端的事件，一套代码打通全平台通信。
  - 让混合开发告别繁琐的平台通道代码。
- **[UniState](https://github.com/didi/Unify/tree/master/packages/unify_uni_state)**：
  - UniState 是一个状态管理框架，支持在双端读取、订阅状态事件
  - 彻底打通了 Flutter 与 Android 的双端状态
  - 从而保障了整个应用的状态一致性。

> 滴滴技术公众号对 Unify 生态中 UniAPI 的介绍：[《滴滴开源新项目Unify：聚焦Flutter与原生通信难题，助力跨端应用落地》](https://mp.weixin.qq.com/s/Di8czdY3KCqDAYrzEvePrg)

以上组件均以 Flutter 库形式提供，每一项均可单独使用，开发者可以根据自身需要进行选择。点击上述链接，即可进入对应文档。

## 应用落地

Unify 由**滴滴国际化外卖团队**自研，目前已在滴滴国际化外卖及国际化出行业务中广泛落地，并作为核心基础设施，可靠支撑公司 Flutter 大规模落地，帮助公司通过跨端技术有效提升了研发效率，降低移动端研发成本。

目前，滴滴采用 Unify 架构体系的应用包括：

- 滴滴国际化出行司机端
- 滴滴国际化外卖用户端
- 滴滴国际化外卖骑手端
- 滴滴国际化外卖商户端
- ……

其中，国际化外卖骑手端经过多年演进，已实现 95%+ 业务代码采用 Flutter 跨端实现，并通过基于 UniAPI 演进出的 UniFoundation、UniBusiness 架构模式，解决了复杂业务场景下的混合业务架构、通信问题。

## 微信社区交流群

![](doc/public/wx.png)

## 协议

<img alt="Apache-2.0 license" src="https://www.apache.org/img/ASF20thAnniversary.jpg" width="128">

Unify 基于 Apache-2.0 协议进行分发和使用，更多信息参见 [协议文件](LICENSE)。

## 成员

研发团队：

[maxiee](https://github.com/maxiee),
[zhugeafanti](https://github.com/zhugeafanti),
[piglet696](https://github.com/piglet696),
[zhaoxiaochun](https://github.com/zhaoxiaochun),
[ChengCheng-Hello](https://github.com/ChengCheng-Hello),
[windChaser618](https://github.com/windChaser618),
[bql88601485](https://github.com/bql88601485),
[newbiechen1024](https://github.com/newbiechen1024),
[xizhilang66](https://github.com/xizhilang66),
[UCPHszf](https://github.com/UCPHszf),
[QianfeiSir](https://github.com/QianfeiSir),
[jiawei1203](https://github.com/jiawei1203),
[Whanter](https://github.com/Whanter)

## Contribution

如果在使用、理解上有任何问题，欢迎提交 Issue 反馈、交流！

欢迎您的交流、贡献！

