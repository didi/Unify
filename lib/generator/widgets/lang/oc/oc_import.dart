import 'package:unify/ast/basic/ast_variable.dart';
import 'package:unify/ast/uniapi/ast_method.dart';
import 'package:unify/cli/options.dart';
import 'package:unify/generator/widgets/base/line.dart';
import 'package:unify/generator/widgets/code_unit.dart';
import 'package:unify/generator/widgets/code_unit_mixin.dart';
import 'package:unify/generator/widgets/lang/oc/oc_forward_declaration.dart';
import 'package:unify/utils/file/input_file.dart';
import 'package:unify/utils/utils.dart';

const ocImportTypeLocal = 1;
const ocImportTypeGlobal = 2;
const ocImportTypeAtClass = 3;

class OCImport extends CodeUnit {
  OCImport(
      {int depth = 0,
      this.fullImportName = '',
      this.importType = ocImportTypeGlobal})
      : super(depth);

  String fullImportName;
  int importType;

  @override
  String build() {
    if (importType == ocImportTypeGlobal) {
      return OneLine(depth: depth, body: '#import <$fullImportName>').build();
    } else if (importType == ocImportTypeAtClass) {
      return OneLine(depth: depth, body: '@class $fullImportName;').build();
    } else {
      return OneLine(depth: depth, body: '#import "$fullImportName"').build();
    }
  }
}

class OCCustomNestedImports extends CodeUnit with CodeUnitMixin {
  OCCustomNestedImports(this.inputFile, this.options,
      {this.fields = const [],
      this.methods = const [],
      this.excludeImports = const [],
      this.isForwardDeclaration = false,
      int depth = 0})
      : super(depth);

  final InputFile inputFile;
  final UniAPIOptions options;
  final List<Variable> fields;
  final List<Method> methods;
  // 特殊 import 过滤
  final List<String> excludeImports;
  bool isForwardDeclaration;

  Set<String> modelSet = {};

  @override
  String build() {
    final types = collectCustomTypeNames(fields: fields, methods: methods);
    final userDefinedTypes = collectModels(types);

    if (isForwardDeclaration) {
      return userDefinedTypes
          .map((userDefinedType) => OCForwardDeclaration(
                  className: userDefinedType.name, isClass: true, depth: depth)
              .build())
          .join();
    }

    return userDefinedTypes
        .map((userDefinedType) => OCImport(
                fullImportName: '${userDefinedType.inputFile.pascalName}.h',
                depth: depth,
                importType: ocImportTypeLocal)
            .build())
        .join();
  }
}
