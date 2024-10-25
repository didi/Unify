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
      required this.controller})
      : super(key: key);

  final String viewType;
  final Map<String, dynamic>? createParams;
  final CommonParamsCallback? onCreateCommonParams;
  final UniPageController? controller;

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
          if (controller?.onPlatformViewCreatedListener != null) {
            controller?.onPlatformViewCreatedListener!(viewId);
          }
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
          SurfaceAndroidViewController surfaceAndroidViewController =
              PlatformViewsService.initSurfaceAndroidView(
                  id: params.id,
                  viewType: viewType,
                  layoutDirection: TextDirection.ltr,
                  creationParams: finalCreateParams,
                  creationParamsCodec: const StandardMessageCodec(),
                  onFocus: () {
                    params.onFocusChanged(true);
                  });
          surfaceAndroidViewController
              .addOnPlatformViewCreatedListener(params.onPlatformViewCreated);
          if (controller?.onPlatformViewCreatedListener != null) {
            surfaceAndroidViewController.addOnPlatformViewCreatedListener(
                controller!.onPlatformViewCreatedListener!);
          }
          surfaceAndroidViewController.create();
          return surfaceAndroidViewController;
        },
        viewType: viewType);
  }
}
