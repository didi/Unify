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
import 'package:unify/generator/widgets/lang/java/java_class.dart';
import 'package:unify/utils/file/input_file.dart';

void main() {
  // 嵌套依赖类型 A
  final dependModelAInputFile = InputFile();
  dependModelAInputFile.parts = ['dep', 'a'];
  dependModelAInputFile.name = 'A';
  final dependModelA = Model('A', dependModelAInputFile);

  // 嵌套依赖类型 B
  final dependModelBInputFile = InputFile();
  dependModelBInputFile.parts = ['dep', 'b'];
  dependModelBInputFile.name = 'B';
  final dependModelB = Model('B', dependModelBInputFile);

  final modelInputFile = InputFile();
  modelInputFile.parts = ['sub1', 'sub2', 'sub3'];
  modelInputFile.name = 'TestModel';

  final model = Model('TestModel', modelInputFile, fields: [
    Variable(AstInt(), 'count'),
    Variable(AstString(), 'name'),
    Variable(AstBool(), 'isVip'),
    Variable(AstCustomType('A'), 'a'),
    Variable(AstCustomType('B'), 'b')
  ]);

  final options = UniAPIOptions();
  options.javaPackageName = 'com.didi.uniapi';

  final analyzer = UniApiAnalyzer([modelInputFile]);
  analyzer.addCustomType(['A', 'B', 'TestModel']);
  UniApiAnalyzer.mockParseResults(models: [dependModelA, dependModelB, model]);

  test('test class Signature simple', () {
    expect(
        JavaClass(
          className: 'TestClass',
        ).classSignature().build(),
        'class TestClass {\n');
  });

  test('test class static Signature', () {
    expect(
        JavaClass(className: 'TestClass', isStatic: true)
            .classSignature()
            .build(),
        'static class TestClass {\n');
  });

  test('test class Signature simple with generics', () {
    expect(
        JavaClass(
          className: 'TestClass',
          generics: ['T', 'K'],
        ).classSignature().build(),
        'class TestClass<T, K> {\n');
  });

  test('test interface Signature simple', () {
    expect(
        JavaClass(
          className: 'TestClass',
          isInterface: true,
        ).classSignature().build(),
        'interface TestClass {\n');
  });

  test('test class Signature public', () {
    expect(
        JavaClass(className: 'TestClass', isPublic: true)
            .classSignature()
            .build(),
        'public class TestClass {\n');
  });

  test('test class Signature with parent', () {
    expect(
        JavaClass(
                className: 'TestClass',
                parentClass: 'UniAPITest',
                isPublic: true)
            .classSignature()
            .build(),
        'public class TestClass extends UniAPITest {\n');
  });
}
