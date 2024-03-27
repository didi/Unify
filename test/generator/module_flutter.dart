import 'package:unify/analyzer/analyzer_lib.dart';
import 'package:unify/ast/basic/ast_custom.dart';
import 'package:unify/ast/basic/ast_int.dart';
import 'package:unify/ast/basic/ast_string.dart';
import 'package:unify/ast/basic/ast_variable.dart';
import 'package:unify/ast/uniapi/ast_method.dart';
import 'package:unify/ast/uniapi/ast_model.dart';
import 'package:unify/ast/uniapi/ast_module.dart';
import 'package:unify/cli/options.dart';
import 'package:unify/generator/module_flutter.dart';
import 'package:unify/utils/file/input_file.dart';
import 'package:unify/utils/log.dart';

void main() {
  // 嵌套依赖类型 A
  final inputFileA = InputFile();
  inputFileA.parts = ['dep', 'a'];
  inputFileA.path = 'src/a/a.dart';
  final dependModelA = Model('A', inputFileA);

  // 嵌套依赖类型 B
  final inputFileB = InputFile();
  inputFileB.parts = ['dep', 'b'];
  inputFileB.path = 'src/b/b.dart';
  final dependModelB = Model('B', inputFileB);

  final options = UniAPIOptions();
  options.javaPackageName = 'com.didi.uniapi';

  final inputFile = InputFile();
  inputFile.parts = ['sub1', 'sub2', 'sub3'];
  inputFile.path = 'src/test_model/test_module.dart';

  final module = Module(inputFile, name: 'TestModule', methods: [
    Method(name: 'methodA', isAsync: true, parameters: [
      Variable(AstCustomType('A'), 'a'),
      Variable(AstInt(), 'num')
    ]),
    Method(name: 'methodA2', isAsync: true, returnType: AstInt(), parameters: [
      Variable(AstCustomType('A'), 'a'),
      Variable(AstInt(), 'num')
    ]),
    Method(name: 'methodB', parameters: [
      Variable(AstCustomType('B'), 'b'),
      Variable(AstInt(), 'num')
    ]),
    Method(name: 'methodB2', returnType: AstString(), parameters: [
      Variable(AstCustomType('B'), 'b'),
      Variable(AstInt(), 'num')
    ]),
    Method(name: 'methodB3', returnType: AstInt(), parameters: [
      Variable(AstCustomType('B'), 'b'),
      Variable(AstInt(), 'num')
    ]), // 默认所有方法都是异步的 isAsync: true
    Method(
        name: 'methodC',
        parameters: [Variable(AstString(), 'c'), Variable(AstInt(), 'num')]),
  ]);

  final analyzer = UniApiAnalyzer([inputFile]);
  analyzer.addCustomType(['TestModule', 'A', 'B']);
  UniApiAnalyzer.mockParseResults(
      models: [dependModelA, dependModelB], flutterModules: [module]);

  log('============== generate flutter module ====================');
  log(FlutterModuleGenerator.javaCode(module, options));

  log('============== generate oc flutter module header ====================');
  log(FlutterModuleGenerator.ocHeader(module, options));

  log('============== generate oc flutter module Source ====================');
  log(FlutterModuleGenerator.ocSource(module, options));

  log('============== generate dart flutter module Source ====================');
  log(FlutterModuleGenerator.dartCode(module, options));
}
