import 'package:unify_flutter/ast/basic/ast_variable.dart';
import 'package:unify_flutter/generator/widgets/base/line.dart';
import 'package:unify_flutter/generator/widgets/code_unit.dart';
import 'package:unify_flutter/generator/widgets/lang/oc/oc_reference.dart';

const Map<String, String> _propertyTypeMapper = <String, String>{
  'String': 'copy',
  'bool': 'strong',
  'int': 'strong',
  'double': 'strong',
  'Uint8List': 'strong',
  'Int32List': 'strong',
  'Int64List': 'strong',
  'Float64List': 'strong',
  'List': 'strong',
  'Map': 'strong',
  'id': 'weak',
};

class OCProperty extends CodeUnit {
  OCProperty(this.field, {int depth = 0}) : super(depth);

  Variable field;

  // 获取property持有类型
  String _propertyType() {
    String? type;
    type = _propertyTypeMapper[field.type.astType()];
    type ??= 'strong';
    return 'nonatomic, $type';
  }

  @override
  String build() {
    final sb = StringBuffer();

    sb.write('@property');
    sb.write('(');
    sb.write(_propertyType());
    sb.write(')');
    sb.write(' ');
    sb.write(OCReference(field.type).build());
    sb.write(' ');
    sb.write(field.name);
    sb.write(';');

    return OneLine(depth: depth, body: sb.toString()).build();
  }
}
