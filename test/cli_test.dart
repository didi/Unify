import 'package:test/test.dart';
import 'package:unify/cli/commands/generate_api_command.dart';
import 'package:unify/utils/constants.dart';

/// cli args testing
void main() {
  test('args input', () {
    const inputPath = '/User/root/uni_api_test/interface';
    final options = <String>['--input', inputPath].toOptions();
    expect(options.projectPath, inputPath);
  });

  test('args java_out', () {
    const javaOutPath = '/User/root/uni_api_test/android';
    final options = <String>['--java_out', javaOutPath].toOptions();
    expect(options.javaOutputPath, javaOutPath);
  });

  test('args java_package', () {
    const javaPackage = 'com.didi.sailing.$projectName';
    final options = <String>['--java_package', javaPackage].toOptions();
    expect(options.javaPackageName, javaPackage);
  });

  test('args oc_out', () {
    const ocOutPath = '/User/root/uni_api_test/ios';
    final options = <String>['--oc_out', ocOutPath].toOptions();
    expect(options.objcOutput, ocOutPath);
  });

  test('args dart_out', () {
    const dartOutPath = '/User/root/uni_api_test/dart';
    final options = <String>['--dart_out', dartOutPath].toOptions();
    expect(options.dartOutput, dartOutPath);
  });

  test('args temp_dir', () {
    const tempDir = '/User/root/uni_api_test/temp';
    final options = <String>['--temp_dir', tempDir].toOptions();
    expect(options.tempDir, tempDir);
  });
}
