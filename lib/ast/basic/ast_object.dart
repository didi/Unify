import 'package:unify/ast/base.dart';
import 'package:unify/cli/options.dart';

class AstObject extends AstType {
  const AstObject({bool maybeNull = false}) : super(maybeNull, const []);

  @override
  String javaType({bool showGenerics = false}) => 'Object';

  @override
  String javaNewInstance() => 'new Object()';

  @override
  String dartType({bool showGenerics = false}) {
    var ret = 'Object';
    if (kEnableNullSafety) {
      if (maybeNull) {
        ret += '?';
      }
    }
    return ret;
  }

  @override
  String ocType({bool showGenerics = false}) => 'NSObject';

  @override
  String javaDefault() => 'null';

  @override
  String dartDefault() => 'Object()';

  @override
  String astType() => 'Object';
}
