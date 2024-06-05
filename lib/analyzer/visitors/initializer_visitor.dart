import 'package:analyzer/dart/ast/ast.dart' as dart_ast;
import 'package:unify_flutter/analyzer/visitors/base_ast_visitor.dart';

class InitializerVisitor extends BaseAstVisitor {
  dart_ast.Expression? initializer;
  @override
  Object? visitVariableDeclaration(dart_ast.VariableDeclaration node) {
    if (node.initializer != null) {
      initializer = node.initializer;
    }
    return null;
  }
}
