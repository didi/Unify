import 'package:unify_flutter/generator/common.dart';

String dartUniCallbackManagerContent(String generate,
        {bool nullSafty = true, String channelSuffix = ''}) =>
    '''
import 'caches.dart';
import 'uni_callback.dart';
import 'package:flutter/services.dart';

class UniCallbackManager {
  static UniCallbackManager${nullSafty ? "?" : ""} _instance;
  static ${nullSafty ? "late" : ""} BasicMessageChannel _channel;
  static ${nullSafty ? "late" : ""} BasicMessageChannel _disposeChannel;

  static UniCallbackManager getInstance() {
    _instance ??= UniCallbackManager._internal();
    return _instance${nullSafty ? "!" : ""};
  }

  UniCallbackManager._internal() {
    _channel = BasicMessageChannel<Object${nullSafty ? "?" : ""}>(
        '$channelPrefix.UniCallbackManager.callback_channel$channelSuffix',
        StandardMessageCodec()
    );
    _channel.setMessageHandler((event) async {
      print('onEvent ' + event.toString());
      String callbackName = event['callbackName'];
      Object data = event['data'];
      List<UniCallback> callbacks = [];
      callbacks.addAll(uniCallbackCache.values);
      for (final callback in callbacks) {
$generate
        
        if (callback.getType() == int) {
          (callback as UniCallback<int>).onEvent(data as int, disposable);
          continue;
        }
        
        if (callback.getType() == String) {
          (callback as UniCallback<String>).onEvent(data as String, disposable);
          continue;
        }

        if (callback.getType().toString() == 'void') {
          callback.onEvent(data, disposable);
          continue;
        }

        if (callback.getType() == bool) {
          (callback as UniCallback<bool>).onEvent(data as bool, disposable);
          continue;
        }

        if (callback.getType() == List) {
          (callback as UniCallback<List>).onEvent(data as List, disposable);
          continue;
        }
        
        if (callback.getType() == Map) {
          (callback as UniCallback<Map>).onEvent(data as Map, disposable);
          continue;
        }        
      }
    });

    _disposeChannel = const BasicMessageChannel<Object?>(
        '$channelPrefix.UniCallbackManager.callback_channel.dispose$channelSuffix',
        StandardMessageCodec());
  }

  void syncDispose(Map<String, dynamic> params) {
    _disposeChannel.send(params);
  }
}
''';
