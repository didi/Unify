import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';
import 'package:unify/analyzer/analyzer_lib.dart';
import 'package:unify/ast/basic/ast_bool.dart';
import 'package:unify/ast/basic/ast_custom.dart';
import 'package:unify/ast/basic/ast_int.dart';
import 'package:unify/ast/basic/ast_string.dart';
import 'package:unify/ast/basic/ast_variable.dart';
import 'package:unify/ast/uniapi/ast_model.dart';
import 'package:unify/cli/options.dart';
import 'package:unify/generator/widgets/lang/oc/oc_class.dart';
import 'package:unify/utils/file/input_file.dart';

void main() {
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

  final inputFile = InputFile();
  inputFile.parts = ['sub1', 'sub2', 'sub3'];
  inputFile.name = 'TestModel';
  final model = Model('TestModel', inputFile, fields: [
    Variable(AstInt(), 'count'),
    Variable(AstString(), 'name'),
    Variable(AstBool(), 'isVip'),
    Variable(AstCustomType('A'), 'a'),
    Variable(AstCustomType('B'), 'b')
  ]);

  final options = UniAPIOptions();
  options.javaPackageName = 'com.didi.uniapi';

  final analyzer = UniApiAnalyzer([inputFile]);
  analyzer.addCustomType(['A', 'B', 'TestModel']);
  UniApiAnalyzer.mockParseResults(models: [dependModelA, dependModelB, model]);

  test('test interface Signature simple', () {
    expect(
        OCClassDeclaration(
          className: 'TestClass',
          isInterface: true,
        ).classSignature().build(),
        '@interface TestClass\n');
  });

  test('test interface Signature Parent Class', () {
    expect(
        OCClassDeclaration(
                className: 'TestClass',
                isInterface: true,
                parentClass: 'NSObject')
            .classSignature()
            .build(),
        '@interface TestClass : NSObject\n');
  });

  test('test protocol Signature simple', () {
    expect(
        OCClassDeclaration(
          className: 'TestClass',
          isProtocol: true,
        ).classSignature().build(),
        '@protocol TestClass\n');
  });

  test('test protocol Signature simple Parent Class', () {
    expect(
        OCClassDeclaration(
                className: 'TestClass',
                isProtocol: true,
                parentClass: 'ParentProtocol')
            .classSignature()
            .build(),
        '@protocol TestClass : ParentProtocol\n');
  });
}
