import 'dart:io';
import 'package:unify_flutter/analyzer/analyzer_lib.dart';
import 'package:unify_flutter/ast/basic/ast_bool.dart';
import 'package:unify_flutter/ast/basic/ast_custom.dart';
import 'package:unify_flutter/ast/basic/ast_int.dart';
import 'package:unify_flutter/ast/basic/ast_list.dart';
import 'package:unify_flutter/ast/basic/ast_string.dart';
import 'package:unify_flutter/ast/basic/ast_variable.dart';
import 'package:unify_flutter/ast/uniapi/ast_model.dart';
import 'package:unify_flutter/cli/options.dart';
import 'package:unify_flutter/generator/model.dart';
import 'package:unify_flutter/utils/file/input_file.dart';
import 'package:unify_flutter/utils/file/file.dart';
import 'package:unify_flutter/utils/log.dart';

Future<void> main() async {
  final tempDir = createTempDir();
  final inputPath =
      '${Directory.current.path}/test/interface'; // 注意：这里直接打开uni_api工程，执行此单测
  final inputFiles = await parseInputFiles(inputPath, tempDir.path);
  final analyzer = UniApiAnalyzer(inputFiles);
  analyzer.addCustomType(['TestModel']);

  // 嵌套依赖类型 A
  final inputFileA = InputFile();
  inputFileA.parts = ['dep', 'a'];
  inputFileA.path = 'src/a/a.dart';
  inputFileA.name = 'A';
  final dependModelA = Model('A', inputFileA);

  // 嵌套依赖类型 B
  final inputFileB = InputFile();
  inputFileB.parts = ['dep', 'b'];
  inputFileB.path = 'src/b/b.dart';
  inputFileB.name = 'B';
  final dependModelB = Model('B', inputFileB);

  final inputFile = InputFile();
  inputFile.parts = ['sub1', 'sub2', 'sub3'];
  inputFile.path = 'src/test_model/test_model.dart';
  final model = Model('TestModel', inputFile, fields: [
    Variable(AstInt(), 'count'),
    Variable(AstString(), 'name'),
    Variable(AstBool(), 'isVip'),
    Variable(AstCustomType('A'), 'a'),
    Variable(AstCustomType('B'), 'b'),
    Variable(AstList(generics: [AstString()]), 'fieldList')
  ]);

  final options = UniAPIOptions();
  options.javaPackageName = 'com.didi.uniapi';

  UniApiAnalyzer.mockParseResults(models: [dependModelA, dependModelB, model]);

  log('========Generated Java Model==================');
  log(ModelGenerator.javaCode(model, options));

  log('========Generated OC Model Header==================');
  log(ModelGenerator.ocHeader(model, options));

  log('========Generated OC Model Source==================');
  log(ModelGenerator.ocSource(model, options));

  log('========Generated Dart Model==================');
  log(ModelGenerator.dartCode(model, options));
}
