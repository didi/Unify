import 'package:unify/ast/basic/ast_variable.dart';
import 'package:unify/ast/uniapi/ast_method.dart';
import 'package:unify/ast/uniapi/ast_model.dart';
import 'package:unify/cli/options.dart';
import 'package:unify/generator/widgets/base/line.dart';
import 'package:unify/generator/widgets/code_unit.dart';
import 'package:unify/generator/widgets/code_unit_mixin.dart';
import 'package:unify/utils/file/input_file.dart';
import 'package:unify/utils/utils.dart';

/// 简单 import 依赖
class JavaImport extends CodeUnit {
  JavaImport({int depth = 0, this.fullClassName = ''}) : super(depth);

  String fullClassName;

  @override
  String build() {
    return OneLine(depth: depth, body: 'import $fullClassName;').build();
  }
}

/// 基于 Model 自动生成 import
class JavaModelImport extends JavaImport {
  JavaModelImport(Model model, UniAPIOptions options, int depth)
      : super(depth: depth) {
    /*
      fixed: When "path.split('/')" is empty, then "inputFile.javaPackagePostfix()" returns empty string. 
      In this case, the generated Java import path will be "xxx...xxx", triggering a syntax error.

      Example: If the specified import path happens to be the directory where the current file is located, this error is triggered.
    */
    fullClassName =
        '${options.javaPackageName}.${model.inputFile.javaPackagePostfix()}.${model.inputFile.pascalName}'
            .replaceAll('..', '.');
  }
}

/// 嵌套 Model 依赖
class JavaCustomNestedImports extends CodeUnit with CodeUnitMixin {
  JavaCustomNestedImports(this.inputFile, this.options,
      {this.fields = const [],
      this.methods = const [],
      this.excludeImports = const [],
      int depth = 0})
      : super(depth);

  final InputFile inputFile;
  final UniAPIOptions options;
  final List<Variable> fields;
  final List<Method> methods;

  Set<String> modelSet = {};

  // 特殊 import 过滤
  List<String> excludeImports;

  @override
  String build() {
    final types = collectCustomTypeNames(fields: fields, methods: methods);
    final userDefinedTypes = collectModels(types);

    return userDefinedTypes
        .map((userDefinedType) =>
            JavaModelImport(userDefinedType, options, depth).build())
        .join();
  }
}
