import 'package:unify/ast/base.dart';
import 'package:unify/ast/basic/ast_custom.dart';
import 'package:unify/ast/basic/ast_list.dart';
import 'package:unify/ast/basic/ast_map.dart';
import 'package:unify/ast/basic/ast_variable.dart';
import 'package:unify/ast/basic/ast_void.dart';
import 'package:unify/ast/uniapi/ast_method.dart';
import 'package:unify/cli/options.dart';
import 'package:unify/utils/constants.dart';
import 'package:unify/utils/extension/ast_extension.dart';

String unpackArgAST(AstType type, String variableName,
    {bool maybeNull = false}) {
  final questionMark =
      kEnableNullSafety == false || maybeNull == true ? '?' : '';
  if (type is AstCustomType) {
    return '$variableName$questionMark.encode()';
  } else if (type is AstList) {
    if (type.generics.isNotEmpty) {
      return '$variableName$questionMark.map((e) => ${unpackArgAST(type.generics.first, 'e')}).toList()';
    }
  } else if (type is AstMap && type.generics.isNotEmpty) {
    return '$variableName as ${type.dartType(showGenerics: true)}';
  } else if (type is AstVoid) {
    return '';
  }
  return '$variableName as ${type.dartType()}';
}

String unpackField(Variable v) {
  if (v.type.containsCustomType() == true) {
    if (v.type is AstMap) {
      if (v.type.maybeNull) {
        return '${v.name} == null ? null : ${Keys.mapClone}(${v.name}!)';
      }
      return '${Keys.mapClone}(${v.name})';
    } else if (v.type is AstList) {
      if (v.type.maybeNull) {
        return '${v.name} == null ? null : ${Keys.listClone}(${v.name}!)';
      }
      return '${Keys.listClone}(${v.name})';
    }
  }

  return unpackArgAST(v.type, v.name, maybeNull: v.type.maybeNull);
}

List<AstCustomType> collectCustomTypeWithMethods(List<Method> methods) {
  final astTypes = <AstCustomType>[];
  for (final method in methods) {
    for (final element in method.parameters) {
      final l = element.type.realType().recursiveCustomType();
      if (l.isNotEmpty) {
        astTypes.addAll(l);
      }
    }

    final l = method.returnType.realType().recursiveCustomType();
    if (l.isNotEmpty) {
      astTypes.addAll(l);
    }
  }
  return astTypes;
}

List<AstCustomType> collectCustomTypeWithFields(List<Variable> fields) {
  final astTypes = <AstCustomType>[];
  for (final element in fields) {
    final l = element.type.realType().recursiveCustomType();
    if (l.isNotEmpty) {
      astTypes.addAll(l);
    }
  }
  return astTypes;
}

List<String> collectCustomTypeNames(
    {List<Method>? methods, List<Variable>? fields}) {
  final typeNames = <AstCustomType>[
    if (methods != null) ...collectCustomTypeWithMethods(methods),
    if (fields != null) ...collectCustomTypeWithFields(fields)
  ].map((e) => e.type).toSet().toList();

  return typeNames.toSet().toList();
}

/// Determine whether "UniCallback" is used in the module
/// Used to make decisions about whether to reference relevant header files
bool hasUniCallback(List<Method>? methods) =>
    collectCustomTypeNames(methods: methods)
        .where((element) => element == typeUniCallback)
        .toSet()
        .toList()
        .isNotEmpty;
