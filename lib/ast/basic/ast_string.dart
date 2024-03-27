import 'package:unify/ast/base.dart';

class AstString extends AstType {
  AstString({bool maybeNull = false}) : super(maybeNull, []);

  @override
  String javaType({bool showGenerics = false}) => 'String';

  @override
  String javaNewInstance() => 'new String()';

  @override
  String dartType({bool showGenerics = false}) {
    var ret = 'String';

    if (maybeNull) {
      ret += '?';
    }

    return ret;
  }

  @override
  String ocType({bool showGenerics = false}) => 'NSString';

  @override
  String javaDefault() => '""';

  @override
  String dartDefault() => "''";

  @override
  String astType() => 'String';
}
