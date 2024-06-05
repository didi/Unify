import 'dart:io';

import 'package:test/test.dart';
import 'package:unify_flutter/analyzer/analyzer_lib.dart';
import 'package:unify_flutter/cli/options.dart';
import 'package:unify_flutter/generator/model.dart';
import 'package:unify_flutter/utils/file/file.dart';

import '../inputfile/mock_input_file.dart';
import 'cases/case_simple_types.dart';

Future<void> main() async {
  final tempDir = createTempDir();
  final inputPath = '${Directory.current.path}/test/interface';
  final inputFiles = await parseInputFiles(inputPath, tempDir.path);
  UniApiAnalyzer(inputFiles).parseFile(inputPath);

  final options = UniAPIOptions();
  options.projectPath = mockProjectPath;
  options.javaPackageName = mockJavaPackageName;

  test('基本类型 Model 生成测试', () {
    final caseSimple = UniModelCaseSimpleTypes();
    // Android 输出测试
    final output = StringBuffer();
    output.write(ModelGenerator.javaCode(caseSimple.getModel(), options));
    expect(output.toString(), caseSimple.getAndroidOutput());
    // iOS Header 输出测试
    output.clear();
    output.write(ModelGenerator.ocHeader(caseSimple.getModel(), options));
    expect(output.toString(), caseSimple.getIOSHeaderOutput());
    // iOS Source 输出测试
    output.clear();
    output.write(ModelGenerator.ocSource(caseSimple.getModel(), options));
    expect(output.toString(), caseSimple.getIOSSourceOutput());
    // Flutter 输出测试
    output.clear();
    output.write(ModelGenerator.dartCode(caseSimple.getModel(), options));
    expect(output.toString(), caseSimple.getFlutterOutput());
  });
}
