import 'package:unify_flutter/ast/base.dart';
import 'package:unify_flutter/cli/options.dart';

class AstDouble extends AstType {
  AstDouble({bool maybeNull = false}) : super(maybeNull, []);

  @override
  String javaType({bool showGenerics = false}) =>
      showGenerics ? 'Double' : 'double';

  @override
  String javaDefault() => '0.0';

  @override
  String javaNewInstance() => 'new Double()';

  @override
  String dartType({bool showGenerics = false}) {
    var ret = 'double';
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
  String dartDefault() => '0.0';

  @override
  String astType() => 'double';
}
