import 'package:unify_flutter/ast/base.dart';
import 'package:unify_flutter/ast/basic/ast_bool.dart';
import 'package:unify_flutter/ast/basic/ast_custom.dart';
import 'package:unify_flutter/ast/basic/ast_double.dart';
import 'package:unify_flutter/ast/basic/ast_int.dart';
import 'package:unify_flutter/ast/basic/ast_list.dart';
import 'package:unify_flutter/ast/basic/ast_map.dart';
import 'package:unify_flutter/ast/basic/ast_object.dart';
import 'package:unify_flutter/ast/basic/ast_string.dart';
import 'package:unify_flutter/ast/basic/ast_void.dart';

extension StringExtension on String {
  /// Convert string to 'AstType'
  AstType? astType(
      {List<AstType> generics = const <AstType>[],
      bool maybeNull = false,
      bool isCustomType = false,
      List<bool> genericsMaybeNull = const <bool>[]}) {
    if (AstInt().astType() == this) {
      return AstInt(maybeNull: maybeNull);
    }

    if (AstString().astType() == this) {
      return AstString(maybeNull: maybeNull);
    }

    if (AstBool().astType() == this) {
      return AstBool(maybeNull: maybeNull);
    }

    if (AstDouble().astType() == this) {
      return AstDouble(maybeNull: maybeNull);
    }

    if (AstList(generics: [const AstVoid()]).astType() == this) {
      if (generics.isEmpty) {
        return AstList(maybeNull: maybeNull);
      }
      return AstList(
          generics: [generics[0]],
          genericsMaybeNull: genericsMaybeNull,
          maybeNull: maybeNull);
    }

    if (AstMap(keyType: const AstVoid(), valueType: const AstVoid())
            .astType() ==
        this) {
      if (generics.isEmpty) {
        return AstMap(maybeNull: maybeNull);
      }
      return AstMap(
          keyType: generics[0],
          valueType: generics[1],
          genericsMaybeNull: genericsMaybeNull,
          maybeNull: maybeNull);
    }

    if (const AstVoid().astType() == this) {
      return const AstVoid();
    }

    if (const AstObject().astType() == this) {
      return AstObject(maybeNull: maybeNull);
    }

    if (isCustomType == true) {
      return AstCustomType(this,
          generics: generics,
          genericsMaybeNull: genericsMaybeNull,
          maybeNull: maybeNull);
    }

    throw Exception('AstType fromString: no matched type $this');
  }

  /// String initial uppercase
  String capitalize() =>
      length > 1 ? this[0].toUpperCase() + substring(1) : toUpperCase();

  /// Convert non empty strings to lowercase and append "dots" to the beginning of the string.
  /// For example, converting "Com" to ".com"
  String suffix() => isNotEmpty ? '.${toLowerCase()}' : '';
}
