import 'package:unify_flutter/cli/options.dart';
import 'package:unify_flutter/generator/widgets/base/line.dart';
import 'package:unify_flutter/generator/widgets/code_unit.dart';
import 'package:unify_flutter/utils/file/input_file.dart';

/// Java 包声明
class JavaPackage extends CodeUnit {
  JavaPackage(this.inputFile, this.options, {int depth = 0}) : super(depth);

  static const package = 'package';

  InputFile? inputFile;
  UniAPIOptions options;

  @override
  String build() {
    final parts = inputFile?.parts ?? [];
    if (parts.isEmpty) {
      return OneLine(depth: depth, body: '$package ${options.javaPackageName};')
          .build();
    } else {
      return OneLine(
              depth: depth,
              body:
                  '$package ${options.javaPackageName}.${inputFile?.javaPackagePostfix()};')
          .build();
    }
  }
}
