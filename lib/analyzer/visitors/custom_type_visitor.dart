import 'package:analyzer/dart/ast/ast.dart' as dart_ast;
import 'package:unify/analyzer/visitors/base_ast_visitor.dart';

class CustomTypeVisitor extends BaseAstVisitor {
  final List<String> _customTypes = <String>[];

  @override
  Object? visitClassDeclaration(dart_ast.ClassDeclaration node) {
    if (isUniNativeModule(node.metadata) ||
        isUniFlutterModule(node.metadata) ||
        isUniModel(node.metadata)) {
      _customTypes.add(node.name.name);
    }
    node.visitChildren(this);
    return null;
  }

  List<String> results() => _customTypes;
}
