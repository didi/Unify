import 'package:unify/ast/base.dart';
import 'package:unify/ast/basic/ast_object.dart';
import 'package:unify/generator/widgets/lang/oc/oc_reference.dart';

class AstList extends AstType {
  AstList(
      {List<AstType> generics = const [],
      bool maybeNull = false,
      List<bool> genericsMaybeNull = const <bool>[]})
      : super(maybeNull, genericsMaybeNull,
            generics: generics.isNotEmpty ? generics : [const AstObject()]);

  @override
  String javaType({bool showGenerics = false}) {
    if (generics.isEmpty) {
      return 'List';
    } else {
      return 'List<${generics.first.javaType(showGenerics: true)}>';
    }
  }

  @override
  String javaNewInstance() => 'new ArrayList<>()';

  @override
  String dartType({bool showGenerics = false}) {
    if (!showGenerics) {
      return 'List';
    }
    if (generics.isEmpty) {
      var ret = 'List';
      if (maybeNull) {
        ret += '?';
      }
      return ret;
    } else {
      var ret = 'List<${generics.first.dartType(showGenerics: true)}>';

      if (maybeNull) {
        ret += '?';
      }

      return ret;
    }
  }

  @override
  String ocType({bool showGenerics = false}) {
    if (generics.isEmpty || !showGenerics) {
      return 'NSArray';
    }
    return 'NSArray<${OCReference(generics.first).build()}>';
  }

  @override
  String javaDefault() => 'new ArrayList<>()';

  @override
  String dartDefault() => '[]';

  @override
  String astType() => 'List';
}
