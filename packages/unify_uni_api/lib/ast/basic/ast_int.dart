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
  // 非空 int 映射为标量 NSInteger,与声明类型对齐;
  // 可空 int? 回退为 NSNumber(标量无法表达 nil)。
  String ocType({bool showGenerics = false}) => maybeNull ? 'NSNumber' : 'NSInteger';

  @override
  String javaDefault() => '0';

  @override
  String dartDefault() => '0';

  @override
  String astType() => 'int';
}
