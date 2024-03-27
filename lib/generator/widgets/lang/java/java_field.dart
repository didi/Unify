import 'package:unify/ast/basic/ast_variable.dart';
import 'package:unify/generator/widgets/base/line.dart';
import 'package:unify/generator/widgets/code_unit.dart';
import 'package:unify/generator/widgets/lang/java/java_constants.dart';

class JavaField extends CodeUnit {
  JavaField(this.field,
      {this.isPublic = false, this.isPrivate = false, int depth = 0})
      : super(depth);

  Variable field;
  bool isPublic;
  bool isPrivate;

  @override
  String build() {
    assert((isPublic && isPrivate) == false);

    final sb = StringBuffer();

    if (isPublic) {
      sb.write(keywordPublic + keywordSpace);
    }
    if (isPrivate) {
      sb.write(keywordPrivate + keywordSpace);
    }

    sb.write(field.type.javaType() + keywordSpace); //fixme
    sb.write('${field.name};'); // fixme
    if (field.codeComments.isNotEmpty) {
      sb.write('$keywordSpace//${field.codeComments.join(',')}');
    }

    return OneLine(depth: depth, body: sb.toString()).build();
  }
}
