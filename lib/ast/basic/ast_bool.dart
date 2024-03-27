import 'package:unify/ast/base.dart';
import 'package:unify/cli/options.dart';

class AstBool extends AstType {
  AstBool({bool maybeNull = false}) : super(maybeNull, []);

  @override
  String javaType({bool showGenerics = false}) =>
      showGenerics ? 'Boolean' : 'boolean';

  @override
  String javaNewInstance() => 'new Boolean()';

  @override
  String dartType({bool showGenerics = false}) {
    var ret = 'bool';
    if (kEnableNullSafety) {
      if (maybeNull) {
        ret += '?';
      }
    }
    return ret;
  }

  @override
  String ocType({bool showGenerics = false}) => 'NSNumber';

  @override
  String javaDefault() => 'false';

  @override
  String dartDefault() => 'false';

  @override
  String astType() => 'bool';
}
