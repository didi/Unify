import 'package:unify_flutter/ast/base.dart';
import 'package:unify_flutter/ast/basic/ast_object.dart';
import 'package:unify_flutter/generator/widgets/lang/oc/oc_reference.dart';

class AstMap extends AstType {
  AstMap(
      {this.keyType = const AstObject(),
      this.valueType = const AstObject(),
      bool maybeNull = false,
      List<bool> genericsMaybeNull = const <bool>[]})
      : super(maybeNull, genericsMaybeNull, generics: [keyType, valueType]);

  final AstType keyType;
  final AstType valueType;

  @override
  String astType() => 'Map';

  @override
  String javaType({bool showGenerics = false}) =>
      'Map<${keyType.javaType(showGenerics: true)}, ${valueType.javaType(showGenerics: true)}>';

  @override
  String javaNewInstance() => 'new HashMap<>()';

  @override
  String dartType({bool showGenerics = false}) {
    if (!showGenerics) {
      return 'Map';
    }
    var ret =
        'Map<${keyType.dartType(showGenerics: true)}, ${valueType.dartType(showGenerics: true)}>';

    if (maybeNull) {
      ret += '?';
    }

    return ret;
  }

  @override
  String ocType({bool showGenerics = false}) {
    if (!showGenerics) {
      return 'NSDictionary';
    }
    return 'NSDictionary<${OCReference(keyType).build()}, ${OCReference(valueType).build()}>';
  }

  @override
  String javaDefault() => 'new HashMap<>()';

  @override
  String dartDefault() => '{}';
}
