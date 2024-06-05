import 'package:test/test.dart';
import 'package:unify_flutter/cli/options.dart';
import 'package:unify_flutter/generator/module_native.dart';

import '../inputfile/mock_input_file.dart';
import 'cases/case_simple_native_module.dart';

void main() {
  final options = UniAPIOptions();
  options.projectPath = mockProjectPath;
  options.javaPackageName = mockJavaPackageName;
  options.dartOutput = mockDartOutput;

  test('Dart uniNativeModule', () {
    final caseSimpleModule = UniNativeModuleSimpleModule();
    final output = StringBuffer();
    // Flutter 输出
    output
        .write(ModuleGenerator.dartCode(caseSimpleModule.getModule(), options));
    expect(output.toString(), caseSimpleModule.getFlutterOutput());
  });
}
