import 'package:unify_flutter/ast/base.dart';
import 'package:unify_flutter/ast/basic/ast_variable.dart';
import 'package:unify_flutter/ast/basic/ast_void.dart';

class Method extends UniApiNode {
  Method({
    this.name = '',
    this.returnType = const AstVoid(),
    this.parameters = const [],
    this.ignoreError = false,
    this.isAsync = false,
    this.codeComments = const <String>[],
  });

  Method.copy(Method method)
      : name = method.name,
        returnType = method.returnType,
        parameters = method.parameters,
        ignoreError = method.ignoreError,
        codeComments = method.codeComments,
        isAsync = method.isAsync;

  String name;

  AstType returnType;

  List<Variable> parameters;

  bool ignoreError;

  bool isAsync;

  List<String> codeComments;
}
