import 'package:unify_flutter/ast/base.dart';
import 'package:unify_flutter/generator/widgets/code_unit.dart';

/// 传入 AST 类型，由组件白名单决定是直接引用还是指针引用
class OCReference extends CodeUnit {
  OCReference(this.type, {int depth = 0, this.keepRaw = false}) : super(depth);

  static const directReferenceMap = {
    'NSInteger',
    'Class',
    'int',
    'long',
    'id',
    'void',
    'UniCompleted', // 这是一个 block
  };

  AstType type;

  bool keepRaw;

  @override
  String build() {
    if (keepRaw) {
      return type.ocType();
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
