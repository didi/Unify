import 'package:unify/utils/file/input_file.dart';

const mockProjectPath =
    '/Users/jerry/work/iOS/rider.ios.flutter/uni_api_test/interface/';
const mockJavaPackageName = 'com.uniapi';
const mockDartOutput = '/lib/';

/// 生成 mock input file
/// path: file 相对路径
InputFile mockInputFile(String path) {
  final absolutePath = '$mockProjectPath$path';
  return InputFile(path: path, absolutePath: absolutePath);
}
