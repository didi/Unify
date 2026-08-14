import 'package:analyzer/dart/ast/ast.dart' as dart_ast;
import 'package:analyzer/dart/ast/visitor.dart' as dart_ast_visitor;
import 'package:unify_flutter/utils/constants.dart';

class BaseAstVisitor extends dart_ast_visitor.RecursiveAstVisitor<Object?> {
  dart_ast.Annotation? _findMetadata(
      dart_ast.NodeList<dart_ast.Annotation> metadata, String query) {
    final annotations = metadata.where((element) => element.name.name == query);
    return annotations.isEmpty ? null : annotations.first;
  }

  bool hasMetadata(
          dart_ast.NodeList<dart_ast.Annotation> metadata, String query) =>
      _findMetadata(metadata, query) != null;

  bool isUniNativeModule(dart_ast.NodeList<dart_ast.Annotation> metadata) =>
      hasMetadata(metadata, uniNativeModuleAnnotation);

  bool isUniFlutterModule(dart_ast.NodeList<dart_ast.Annotation> metadata) =>
      hasMetadata(metadata, uniFlutterModuleAnnotation);

  bool isUniModel(dart_ast.NodeList<dart_ast.Annotation> metadata) =>
      hasMetadata(metadata, uniModelAnnotation);

  bool isIgnoreError(dart_ast.NodeList<dart_ast.Annotation> metadata) =>
      hasMetadata(metadata, ignoreErrorAnnotation);

  bool isRequiredMessager(dart_ast.NodeList<dart_ast.Annotation> metadata) =>
      hasMetadata(metadata, requiredMessagerAnnotation);

  bool hasUniBufferSize(dart_ast.NodeList<dart_ast.Annotation> metadata) =>
      hasMetadata(metadata, uniBufferSizeAnnotation);

  /// The integer argument of `@UniBufferSize(n)`.
  ///
  /// Returns the parsed value only when it is a plain positive integer literal;
  /// otherwise returns `null` (missing annotation, missing/invalid argument, or
  /// a non-positive value), so callers can warn and skip.
  int? uniBufferSize(dart_ast.NodeList<dart_ast.Annotation> metadata) {
    final anno = _findMetadata(metadata, uniBufferSizeAnnotation);
    final args = anno?.arguments?.arguments;
    if (args == null || args.isEmpty) return null;
    final first = args.first;
    if (first is! dart_ast.IntegerLiteral) return null;
    final value = first.value;
    if (value == null || value <= 0) return null;
    return value;
  }
}
