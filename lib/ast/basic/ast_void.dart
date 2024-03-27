import 'package:unify/ast/base.dart';

class AstVoid extends AstType {
  const AstVoid({bool maybeNull = false}) : super(maybeNull, const []);

  @override
  String javaType({bool showGenerics = false}) =>
      showGenerics ? 'Void' : 'void';

  @override
  String javaNewInstance() => 'null';

  @override
  String dartType({bool showGenerics = false}) => 'void';

  @override
  String ocType({bool showGenerics = false}) => 'void';

  @override
  String javaDefault() => 'null';

  @override
  String dartDefault() => 'null';

  @override
  String astType() => 'void';
}
