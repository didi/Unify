import 'package:unify_flutter/ast/base.dart';
import 'package:unify_flutter/cli/options.dart';

class AstInt extends AstType {
  AstInt({bool maybeNull = false}) : super(maybeNull, []);

  @override
  String javaType({bool showGenerics = false}) =>
      showGenerics ? 'Long' : 'long';

  @override
  String javaNewInstance() => 'new Integer()';

  @override
  String dartType({bool showGenerics = false}) {
    var ret = 'int';
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
  String javaDefault() => '0';

  @override
  String dartDefault() => '0';

  @override
  String astType() => 'int';
}
