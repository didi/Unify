import 'package:unify/utils/constants.dart';
import 'package:unify/utils/extension/string_extension.dart';

class InputFile {
  InputFile(
      {this.path = '',
      this.absolutePath = '',
      this.relativePath = '',
      this.name = '',
      this.parts = const []}) {
    parts = path.split('/');
    parts.removeLast();

    name = path.split('/')[parts.length].replaceAll(dartSuffix, '');
  }

  String path;
  final String absolutePath;
  final String relativePath;
  String name;
  List<String> parts;

  bool sameParts(InputFile? inputFile) {
    if (inputFile == null) {
      return false;
    }

    if (parts.length != inputFile.parts.length) {
      return false;
    }

    for (var i = 0; i < parts.length; i++) {
      if (parts[i] != inputFile.parts[i]) {
        return false;
      }
    }

    return true;
  }

  String javaPath() {
    final ret = <String>[];
    ret.addAll(parts);
    ret.add(pascalName + javaSuffix);
    return ret.join('/');
  }

  String objcHeaderPath() {
    final ret = <String>[];
    ret.addAll(parts);
    ret.add('$pascalName.h');
    return ret.join('/');
  }

  String objcSourcePath() {
    final ret = <String>[];
    ret.addAll(parts);
    ret.add('$pascalName.m');
    return ret.join('/');
  }

  String javaNativeRegisterPath() {
    final ret = <String>[];
    ret.addAll(parts);
    ret.add('$pascalName$kRegister$javaSuffix');
    return ret.join('/');
  }

  String javaPackagePostfix() {
    return parts.join('.');
  }

  String get pascalName => _pascalName();

  /// 将下划线风格转驼峰
  String _pascalName() {
    final exp = RegExp('(?<=[a-z])(_[a-z])');
    final result = name
        .capitalize()
        .replaceAllMapped(exp, (m) => m.group(0)!.substring(1).capitalize());
    return result;
  }

  @override
  String toString() {
    return '[path=$path][absolutePath=$absolutePath][relativePath=$relativePath]';
  }
}
