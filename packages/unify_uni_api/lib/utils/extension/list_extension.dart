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

  void insertAtSecondLast(dynamic newElement) {
    if (length < 1) {
      throw ArgumentError(
          'List must have at least one element to insert at the second last position.');
    }
    insert(length - 1, newElement);
  }
}
