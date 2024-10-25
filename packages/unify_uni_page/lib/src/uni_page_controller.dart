import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:unify_uni_page/src/constants.dart';

typedef MethodCallHandler = Future<dynamic> Function(
    String methodName, Map<String, dynamic> prams);

typedef OnPlatformViewCreatedListener = void Function(int viewId);

class UniPageController {
  MethodCallHandler? _methodCallHandler;
  OnPlatformViewCreatedListener? onPlatformViewCreatedListener;

  BuildContext? buildContext;
  late String viewType;
  late int viewId;
  late MethodChannel channel;

  set methodCallHandler(MethodCallHandler handler) {
    _methodCallHandler = handler;
  }

  Future<dynamic> invoke(String methodName, Map<String, dynamic> params) async {
    assert(buildContext != null);
    print('UniPage: invoking native method $methodName');
    return await channel.invokeMethod(kChannelInvoke, {
      kChannelViewType: viewType,
      kChannelViewId: viewId,
      kChannelMethodName: methodName,
      kChannelParamsPrams: params
    });
  }

  void init(BuildContext buildContext, String viewType, int viewId) {
    this.buildContext = buildContext;
    this.viewType = viewType;
    this.viewId = viewId;
    initChannel();
  }

  void initChannel() {
    assert(buildContext != null);
    channel = MethodChannel(createChannelName(viewType, viewId));
    channel.setMethodCallHandler((call) async {
      Map<String, dynamic> arguments =
          Map<String, dynamic>.from(call.arguments);

      switch (call.method) {
        case kChannelRoutePushNamed:
          String path = call.arguments[kChannelParamsPath];
          Map<String, dynamic> params =
              Map<String, dynamic>.from(arguments[kChannelParamsPrams] ?? {});
          return Navigator.of(buildContext!).pushNamed(path, arguments: params);
        case kChannelRoutePop:
          Map<String, dynamic> params =
              Map<String, dynamic>.from(arguments[kChannelParamsPrams] ?? {});
          Navigator.of(buildContext!).pop(params);
          return true;
        case kChannelInvoke:
          assert(arguments.containsKey(kChannelMethodName));
          assert(arguments.containsKey(kChannelParamsPrams));
          String methodName = arguments[kChannelMethodName];
          Map<String, dynamic> params =
              Map.from(arguments[kChannelParamsPrams] ?? {});
          if (_methodCallHandler != null) {
            return await _methodCallHandler!(methodName, params);
          }
      }
      return false;
    });
  }

  void dispose() {
    assert(buildContext != null);
    buildContext = null;
    channel.setMethodCallHandler(null);
    _methodCallHandler = null;
  }
}
