import 'package:unify_flutter/generator/widgets/base/line.dart';
import 'package:unify_flutter/generator/widgets/code_unit.dart';

class OCForwardDeclaration extends CodeUnit {
  OCForwardDeclaration(
      {this.className = '',
      this.isProtocol = false,
      this.isClass = false,
      int depth = 0})
      : super(depth);

  String className;
  bool isProtocol;
  bool isClass;

  @override
  String build() {
    assert(isProtocol || isClass);
    assert(!(isProtocol && isClass));

    final sb = StringBuffer();
    if (isProtocol) {
      sb.write('@protocol');
    }
    if (isClass) {
      sb.write('@class');
    }
    sb.write(' ');
    sb.write(className);
    sb.write(';');

    return OneLine(depth: depth, body: sb.toString()).build();
  }
}
