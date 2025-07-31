import 'package:unify_flutter/ast/basic/ast_variable.dart';
import 'package:unify_flutter/ast/uniapi/ast_method.dart';
import 'package:unify_flutter/generator/widgets/base/line.dart';
import 'package:unify_flutter/generator/widgets/code_unit.dart';
import 'package:unify_flutter/generator/widgets/code_unit_mixin.dart';
import 'package:unify_flutter/generator/widgets/lang/dart/dart_field.dart';
import 'package:unify_flutter/generator/widgets/lang/dart/dart_function.dart';
import 'package:unify_flutter/generator/widgets/lang/java/java_class.dart';
import 'package:unify_flutter/utils/extension/codeunit_extension.dart';

class DartClass extends CodeUnit with CodeUnitMixin {
  DartClass({
    int depth = 0,
    this.className = '',
    this.parentClass,
    this.injectedJavaCodes,
    this.isAbstract = false,
    this.fields = const [],
    this.methods = const [],
    this.hasConstructor = false,
    this.isUniModelMode = false
  }) : super(depth);

  // 类名
  String className;

  // 是否有父类
  String? parentClass;

  bool isAbstract;

  // 类属性列表
  List<Variable> fields;

  // 方法列表
  List<Method> methods;

  // 是否生成构造方法
  bool hasConstructor;

  // 外界注入的代码
  InjectCodeUnit? injectedJavaCodes;

  // 是否是 UniModel 模式
  bool isUniModelMode;

  List<CodeUnit> dartFields() {
    return fields.map((field) => DartField(field, depth: depth + 1)).toList();
  }

  OneLine classSignature() {
    final sb = StringBuffer();
    if (isAbstract) {
      sb.write('abstract');
      sb.write(' ');
    }
    sb.write('class');
    sb.write(' ');
    sb.write(className);
    sb.write(' ');
    sb.write('{');

    return OneLine(depth: depth, body: sb.toString());
  }

  @override
  String build() {
    return CodeUnit.join([
      classSignature(),
      if (isUniModelMode)
        ...cloneDartCollectionType(
            methods: methods, fields: fields, depth: depth),
      if (hasConstructor) DartConstructor(className, fields, depth: depth + 1),
      if (hasConstructor) EmptyLine(),
      ...dartFields(),
      if (injectedJavaCodes != null) EmptyLine(),
      if (injectedJavaCodes != null) ...injectedJavaCodes!(depth),
      OneLine(depth: depth, body: '}')
    ]);
  }
}
