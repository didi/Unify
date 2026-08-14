import 'package:unify_flutter/ast/base.dart';
import 'package:unify_flutter/cli/options.dart';

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
  // 非空 bool 映射为标量 BOOL;可空 bool? 回退为 NSNumber。
  String ocType({bool showGenerics = false}) => maybeNull ? 'NSNumber' : 'BOOL';

  @override
  String javaDefault() => 'false';

  @override
  String dartDefault() => 'false';

  @override
  String astType() => 'bool';
}
