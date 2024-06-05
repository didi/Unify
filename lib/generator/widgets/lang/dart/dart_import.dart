import 'package:path/path.dart';
import 'package:unify_flutter/ast/basic/ast_variable.dart';
import 'package:unify_flutter/ast/uniapi/ast_method.dart';
import 'package:unify_flutter/ast/uniapi/ast_model.dart';
import 'package:unify_flutter/cli/options.dart';
import 'package:unify_flutter/generator/widgets/base/line.dart';
import 'package:unify_flutter/generator/widgets/code_unit.dart';
import 'package:unify_flutter/generator/widgets/code_unit_mixin.dart';
import 'package:unify_flutter/generator/widgets/lang/java/java_import.dart';
import 'package:unify_flutter/utils/file/input_file.dart';
import 'package:unify_flutter/utils/utils.dart';

class DartImport extends CodeUnit {
  DartImport({int depth = 0, this.fullClassName = ''}) : super(depth);

  String fullClassName;

  @override
  String build() =>
      OneLine(depth: depth, body: "import '$fullClassName';").build();
}

/// 基于 Model 自动生成 import
class DartModelImport extends JavaImport {
  DartModelImport(Model model, InputFile inputFile, int depth)
      : super(depth: depth) {
    fullClassName =
        "'${relative(model.inputFile.path, from: dirname(inputFile.path))}'";
  }
}

class DartCustomNestedImports extends CodeUnit with CodeUnitMixin {
  DartCustomNestedImports(this.inputFile, this.options,
      {this.fields = const [],
      this.methods = const [],
      this.excludeImports = const [],
      int depth = 0})
      : super(depth);

  final InputFile inputFile;
  final UniAPIOptions options;
  final List<Variable> fields;
  final List<Method> methods;

  // 特殊 import 过滤
  List<String> excludeImports;
  Set<String> modelSet = {};

  @override
  String build() {
    final types = collectCustomTypeNames(fields: fields, methods: methods);
    final userDefinedTypes = collectModels(types);

    return userDefinedTypes
        .map((userDefinedType) =>
            DartModelImport(userDefinedType, inputFile, depth).build())
        .join();
  }
}
