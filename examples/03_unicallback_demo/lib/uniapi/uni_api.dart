class UniApi {
  static Function(String moduleName, String channel, String error)? _errorTrackCallback = (String moduleName, String channel, String error) {
    print(error);
  };

  static void setErrorTrackCallback(Function(String moduleName, String channel, String error)? newCallback) {
    if (newCallback == null) {
      return;
    }
    _errorTrackCallback = newCallback;
  }

  static void trackError(String moduleName, String channel, String error) {
    _errorTrackCallback?.call(moduleName, channel, error);
  }
}
