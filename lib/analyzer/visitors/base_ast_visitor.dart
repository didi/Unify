import 'package:analyzer/dart/ast/ast.dart' as dart_ast;
import 'package:analyzer/dart/ast/visitor.dart' as dart_ast_visitor;
import 'package:unify/utils/constants.dart';

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
}
