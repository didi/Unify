import 'package:unify_flutter/ast/basic/ast_variable.dart';
import 'package:unify_flutter/generator/widgets/base/line.dart';
import 'package:unify_flutter/generator/widgets/code_unit.dart';

class DartField extends CodeUnit {
  DartField(this.field, {int depth = 0}) : super(depth);

  Variable field;

  @override
  String build() {
    final sb = StringBuffer();
    sb.write(field.type.dartType(showGenerics: true));
    sb.write(' ');
    sb.write(field.name);
    sb.write(';');
    if (field.codeComments.isNotEmpty) {
      sb.write('${CodeUnit.space}///${field.codeComments.join(',')}');
    }
    return OneLine(depth: depth, body: sb.toString()).build();
  }
}
