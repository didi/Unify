import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:unify_uni_page/unify_uni_page.dart';

typedef CommonParamsCallback = Map<String, dynamic> Function();

class UniPage extends StatelessWidget {
  const UniPage(this.viewType,
      {Key? key,
      this.createParams,
      this.onCreateCommonParams,
      required this.controller,
      this.useHybridComposition = false})
      : super(key: key);

  final String viewType;
  final Map<String, dynamic>? createParams;
  final CommonParamsCallback? onCreateCommonParams;
  final UniPageController? controller;

  /// Whether to use Hybrid Composition (HC) on Android, instead of the default
  /// Texture Layer Hybrid Composition (TLHC).
  ///
  /// This option works only on Android, and will be ignored on iOS.
  /// If your UniPage contains a SurfaceView, HC mode will always be used,
  /// regardless of this option.
  ///
  /// Avoid setting this to true, since it may cause performance drawbacks.
  ///
  /// See also:
  /// https://github.com/flutter/flutter/blob/master/docs/platforms/android/Android-Platform-Views.md
  final bool useHybridComposition;

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> finalCreateParams = {};
    finalCreateParams.addAll(createParams ?? {});
    finalCreateParams.addAll(onCreateCommonParams?.call() ?? {});
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
          controller?.init(context, viewType, viewId);
          controller?.onPlatformViewCreatedListener?.call(viewId);
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
          controller?.init(context, viewType, params.id);
          if (useHybridComposition) {
            return PlatformViewsService.initExpensiveAndroidView(
                id: params.id,
                viewType: viewType,
                layoutDirection: TextDirection.ltr,
                creationParams: finalCreateParams,
                creationParamsCodec: const StandardMessageCodec(),
                onFocus: () {
                  params.onFocusChanged(true);
                })
              ..addOnPlatformViewCreatedListener((viewId) {
                params.onPlatformViewCreated(viewId);
                controller?.onPlatformViewCreatedListener?.call(viewId);
              })
              ..create();
          }
          return PlatformViewsService.initSurfaceAndroidView(
              id: params.id,
              viewType: viewType,
              layoutDirection: TextDirection.ltr,
              creationParams: finalCreateParams,
              creationParamsCodec: const StandardMessageCodec(),
              onFocus: () {
                params.onFocusChanged(true);
              })
            ..addOnPlatformViewCreatedListener((viewId) {
              params.onPlatformViewCreated(viewId);
              controller?.onPlatformViewCreatedListener?.call(viewId);
            })
            ..create();
        },
        viewType: viewType);
  }
}
