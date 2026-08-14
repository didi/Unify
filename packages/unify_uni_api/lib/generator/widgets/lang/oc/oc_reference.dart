import 'package:unify_flutter/ast/base.dart';
import 'package:unify_flutter/ast/basic/ast_bool.dart';
import 'package:unify_flutter/ast/basic/ast_double.dart';
import 'package:unify_flutter/ast/basic/ast_int.dart';
import 'package:unify_flutter/generator/widgets/code_unit.dart';

/// 传入 AST 类型，由组件白名单决定是直接引用还是指针引用
class OCReference extends CodeUnit {
  OCReference(this.type,
      {int depth = 0, this.keepRaw = false, this.boxed = false})
      : super(depth);

  static const directReferenceMap = {
    'NSInteger',
    'Class',
    'int',
    'long',
    'double', // 非空 double 直接引用,不加 '*'
    'float',
    'BOOL', // 非空 bool 直接引用,不加 '*'
    'id',
    'void',
    'UniCompleted', // 这是一个 block
  };

  AstType type;

  bool keepRaw;

  /// 处于泛型实参位置(如 NSArray<...> / NSDictionary<...,...>)。
  /// OC 集合泛型必须是对象类型,非空标量需回退为 NSNumber*。
  bool boxed;

  @override
  String build() {
    if (keepRaw) {
      return type.ocType();
    }

    if (boxed) {
      final rt = type.realType();
      if (rt is AstInt || rt is AstDouble || rt is AstBool) {
        return 'NSNumber*';
      }
    }

    // 比较的时候用 ocTypeWithoutGeneric，输出的时候还是用 ocType
    final ocType = type.ocType(showGenerics: true);
    var ocTypeWithoutGeneric = ocType;

    // 脱去泛型
    if (ocType.contains('<')) {
      ocTypeWithoutGeneric = ocType.substring(0, ocType.indexOf('<'));
    }

    if (directReferenceMap.contains(ocTypeWithoutGeneric)) {
      return ocType;
    } else if (ocTypeWithoutGeneric.contains('^')) {
      // OC Block 类型引用
      return ocType;
    } else {
      return '$ocType*';
    }
  }
}
