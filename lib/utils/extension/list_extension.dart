import 'package:unify_flutter/utils/constants.dart';

extension ListExtensions on List {
  List getDuplicates() {
    final distinct = toSet().toList();
    for (final item in distinct) {
      remove(item);
    }
    return toSet().toList();
  }

  void removeBuildInType() {
    removeWhere((dynamic element) => element == typeUniCallback);
    removeWhere((dynamic element) => element == typeFlutterError);
    removeWhere((dynamic element) => element == typeFuture);
  }
}
