import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:unify_uni_page/unify_uni_page.dart';

class UniPage extends StatelessWidget {
  const UniPage(this.viewType,
      {Key? key, this.createParams, required this.controller})
      : super(key: key);

  final String viewType;
  final dynamic createParams;
  final UniPageController? controller;

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return UiKitView(
        viewType: viewType,
        gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
        creationParams: createParams,
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: (viewId) {
          controller?.init(context, viewType, viewId);
        },
      );
    }

    return PlatformViewLink(
        surfaceFactory: (context, controller) {
          return AndroidViewSurface(
              controller: controller as AndroidViewController,
              hitTestBehavior: PlatformViewHitTestBehavior.opaque,
              gestureRecognizers: const <Factory<
                  OneSequenceGestureRecognizer>>{});
        },
        onCreatePlatformView: (params) {
          controller?.init(context, viewType, params.id);
          return PlatformViewsService.initSurfaceAndroidView(
              id: params.id,
              viewType: viewType,
              layoutDirection: TextDirection.ltr,
              creationParams: createParams,
              creationParamsCodec: const StandardMessageCodec(),
              onFocus: () {
                params.onFocusChanged(true);
              })
            ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
            ..create();
        },
        viewType: viewType);
  }
}
