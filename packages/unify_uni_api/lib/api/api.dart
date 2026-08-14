class UniFlutterModule {
  const UniFlutterModule();
}

class UniNativeModule {
  const UniNativeModule();
}

class UniModel {
  const UniModel();
}

class IgnoreError {
  const IgnoreError();
}

/// In "UniFlutterModule" mode, the interface parameters
/// are by default added with "Binary Messenger".
///
/// Important: It can only be used in UniFlutterModule mode.
class RequiredMessager {
  const RequiredMessager();
}

/// Enlarge the platform channel buffer for the annotated method's channel.
///
/// Only effective in "UniFlutterModule" mode (native -> dart). By default the
/// Flutter channel buffer keeps only 1 message; when native sends before the
/// Dart handler is registered, earlier messages are dropped. Annotating a
/// method makes the generated native `setup` enlarge that channel's buffer to
/// [size] so early messages are queued instead of discarded.
///
/// [size] must be a positive integer literal. Methods without this annotation
/// keep the original behavior unchanged. It is ignored on `@RequiredMessager`
/// methods (their target messenger is decided per call, not at setup time).
class UniBufferSize {
  final int size;
  const UniBufferSize(this.size);
}
