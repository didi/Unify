import 'package:unify_flutter/ast/base.dart';
import 'package:unify_flutter/utils/constants.dart';

class AstCustomType extends AstType {
  AstCustomType(
    this.type, {
    bool maybeNull = false,
    bool keepRaw = false,
    List<bool> genericsMaybeNull = const <bool>[],
    List<AstType> generics = const <AstType>[],
    this.isNativeModule,
  }) : super(maybeNull, genericsMaybeNull,
            keepRaw: keepRaw, generics: generics);

  String type;

  bool? isNativeModule;

  @override
  String javaType({bool showGenerics = false}) {
    if (generics.isNotEmpty) {
      return '$type<${generics.map((e) => e.javaType(showGenerics: true)).join(', ')}>';
    }
    return type;
  }

  @override
  String javaNewInstance() => 'new $type()';

  @override
  String dartType({bool showGenerics = false}) {
    if (!showGenerics) {
      return type;
    }

    final buffer = StringBuffer();
    buffer.write(type);
    if (generics.isNotEmpty) {
      buffer.write('<');
      for (var i = 0; i < generics.length; i++) {
        buffer.write(generics[i].dartType(showGenerics: showGenerics));
        if (i != generics.length - 1) {
          buffer.write(', ');
        }
      }

      if (maybeNull) {
        buffer.write('?');
      }
      buffer.write('>');
    } else {
      if (maybeNull) {
        buffer.write('?');
      }
    }
    return buffer.toString();
  }

  @override
  String ocType({bool showGenerics = false}) {
    if (!showGenerics) {
      return type;
    }
    final ret = StringBuffer();
    ret.write(type);
    if (generics.isNotEmpty) {
      ret.write('<');
      ret.write(generics.map((e) => e.ocType(showGenerics: true)).join(', '));
      ret.write('>');
    }
    return ret.toString();
  }

  @override
  String javaDefault() => 'new $type()';

  @override
  String dartDefault() => 'new $type()';

  @override
  String astType() => type;

  @override
  AstType realType() =>
      astType() == typeFuture && generics.isNotEmpty ? generics[0] : this;
}
