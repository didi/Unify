import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';
import 'package:unify_flutter/analyzer/analyzer_lib.dart';
import 'package:unify_flutter/ast/basic/ast_custom.dart';
import 'package:unify_flutter/ast/basic/ast_variable.dart';
import 'package:unify_flutter/ast/uniapi/ast_model.dart';
import 'package:unify_flutter/cli/options.dart';
import 'package:unify_flutter/generator/widgets/lang/java/java_import.dart';
import 'package:unify_flutter/utils/file/input_file.dart';

void main() {
  final options = UniAPIOptions();
  options.javaPackageName = 'com.didi.uniapi';

  // 嵌套依赖类型 A
  final inputFileA = InputFile();
  inputFileA.parts = ['dep', 'a'];
  inputFileA.name = 'A';
  final dependModelA = Model('A', inputFileA);

  // 嵌套依赖类型 B
  final inputFileB = InputFile();
  inputFileB.parts = ['dep', 'b'];
  inputFileB.name = 'B';
  final dependModelB = Model('B', inputFileB);

  // 被测试 Model
  final inputFile = InputFile();
  inputFile.parts = ['test', 'model'];
  inputFile.name = 'TestModel';
  final testModel = Model('TestModel', inputFile, fields: [
    Variable(AstCustomType('A'), 'a'),
    Variable(AstCustomType('B'), 'b'),
  ]);

  final analyzer = UniApiAnalyzer([inputFile]);
  analyzer.addCustomType(['TestModel']);
  UniApiAnalyzer.mockParseResults(
      models: [dependModelA, dependModelB, testModel]);

  test('test JavaModelImport', () {
    expect(JavaModelImport(testModel, options, 0).build(),
        'import com.didi.uniapi.test.model.TestModel;\n');
  });

  test('test JavaModelNestedImports of Model', () {
    expect(
        JavaCustomNestedImports(testModel.inputFile, options,
                fields: testModel.fields)
            .build(),
        'import com.didi.uniapi.dep.a.A;\nimport com.didi.uniapi.dep.b.B;\n');
  });
}
