import 'caches.dart';

class UniCallback<T> {
  String callbackName = '';
  final Function(T event, UniCallbackDisposable disposable) onEvent;
  UniCallbackDisposable? disposable;

  UniCallback(this.onEvent);
  
  Type getType() {
    return T;
  }

  void dispose() {
    if (disposable != null) {
      disposable!.dispose();
      disposable = null;
    } else {
      uniCallbackCache.remove(callbackName);
    }
  }
}

class UniCallbackDisposable {
  UniCallback? callback;
  
  UniCallbackDisposable(this.callback);
  
  void dispose() {
    if (callback != null) {
      uniCallbackCache.remove(callback!.callbackName);
      callback = null;
    }
  }
}
