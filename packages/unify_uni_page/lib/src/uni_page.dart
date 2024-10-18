import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:unify_uni_page/unify_uni_page.dart';

import 'constants.dart';

typedef CommonParamsCallback = Map<String, dynamic> Function();

class UniPage extends StatefulWidget {
  const UniPage(this.viewType,
      {Key? key,
      this.createParams,
      this.onCreateCommonParams,
      required this.controller})
      : super(key: key);

  final String viewType;
  final Map<String, dynamic>? createParams;
  final CommonParamsCallback? onCreateCommonParams;
  final UniPageController? controller;

  @override
  State<StatefulWidget> createState() => _UniPageState();
}

class _UniPageState extends State<UniPage> {
  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> finalCreateParams = {};
    finalCreateParams.addAll(widget.createParams ?? {});
    finalCreateParams.addAll(widget.onCreateCommonParams?.call() ?? {});
    if (Platform.isIOS) {
      return UiKitView(
        viewType: viewType,
        gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
          Factory<OneSequenceGestureRecognizer>(
            () => EagerGestureRecognizer(),
          ),
        },
        creationParams: finalCreateParams,
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: (viewId) {
          widget.controller?.init(context, viewType, viewId);
        },
      );
    }

    return PlatformViewLink(
        surfaceFactory: (context, controller) {
          return AndroidViewSurface(
              controller: controller as AndroidViewController,
              hitTestBehavior: PlatformViewHitTestBehavior.opaque,
              gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                Factory<OneSequenceGestureRecognizer>(
                  () => EagerGestureRecognizer(),
                ),
              });
        },
        onCreatePlatformView: (params) {
          widget.controller?.init(context, viewType, params.id);
          return PlatformViewsService.initSurfaceAndroidView(
              id: params.id,
              viewType: viewType,
              layoutDirection: TextDirection.ltr,
              creationParams: finalCreateParams,
              creationParamsCodec: const StandardMessageCodec(),
              onFocus: () {
                params.onFocusChanged(true);
              })
            ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
            ..create();
        },
        viewType: viewType);
  }

  @override
  void dispose() {
    if (Platform.isIOS) {
      _syncDisposeEvent();
    }
    super.dispose();
  }

  get viewType => widget.viewType;
  get viewId => widget.controller?.viewId;

  void _syncDisposeEvent() {
    String channelName = '${createChannelName(viewType, viewId)}.dispose';
    MethodChannel _disposeChannel = MethodChannel(channelName);
    _disposeChannel.invokeMethod<void>('dispose');
    print('jerry => call _syncDisposeEvent');
  }
}
