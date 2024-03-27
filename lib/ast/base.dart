class Node {
  const Node();
}

abstract class AstType extends Node {
  const AstType(this.maybeNull, this.genericMaybeNull,
      {this.keepRaw = false, this.generics = const <AstType>[]});

  final List<AstType> generics;

  final bool maybeNull;
  final List<bool> genericMaybeNull;

  final bool keepRaw;

  String astType();

  String javaType({bool showGenerics = false});

  String dartType({bool showGenerics = false});

  String dartDefault();

  String ocType({bool showGenerics = false});

  String javaDefault();

  String javaNewInstance();

  AstType realType() => this;

  @override
  String toString() =>
      'AstType:"${astType()}" maybeNull:$maybeNull generics:"${generics.toString()}" ';
}

class UniApiNode extends Node {
  const UniApiNode();
}

mixin Serializable {
  String javaEncodedFuncName(bool isEnum) => isEnum ? '.ordinal()' : '.toMap()';
  String javaDecodedFuncName(bool isEnum, String template) =>
      isEnum ? '.values()[$template]' : '.fromMap($template)';
  String dartEncodedFuncName(bool isEnum) => isEnum ? '.index' : '.encode()';
  String dartDecodedFuncName(bool isEnum, String template) =>
      isEnum ? '.values[$template]' : '.decode($template)';
}
