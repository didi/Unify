import 'package:unify_flutter/ast/base.dart';

class Variable extends Node {
  Variable(this.type, this.name, {this.codeComments = const <String>[]});

  static const String keywordSpace = ' ';

  AstType type;
  String name;
  List<String> codeComments;

  String javaDeclaration({bool newInstance = false}) {
    final sb = StringBuffer();
    sb.write(type.javaType() + keywordSpace);
    sb.write(name);

    if (newInstance) {
      sb.write('$keywordSpace=$keywordSpace${type.javaNewInstance()}');
    }

    sb.write(';');

    return sb.toString();
  }

  @override
  String toString() => 'name:"$name" AstType:"${type.toString()}" ';
}
