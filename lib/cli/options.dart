import 'package:args/args.dart';

const inputOption = 'input';
const javaOutOption = 'java_out';
const javaPackageOption = 'java_package';
const uniapiPrefixOption = 'uniapi_prefix';
const ocOutOption = 'oc_out';
const tempDirOption = 'temp_dir';
const dartOutOption = 'dart_out';
const dartNullSafetyOption = 'dart_null_safety';
const version = 'version';

bool kEnableNullSafety = true;

class UniAPIOptions {
  UniAPIOptions();

  factory UniAPIOptions.fromParser(ArgResults results) {
    final ret = UniAPIOptions();
    ret.projectPath = getParams(results, inputOption);

    ret.javaOutputPath = getParams(results, javaOutOption);
    ret.javaPackageName = getParams(results, javaPackageOption);
    ret.javaUniAPIPrefix = getParams(results, uniapiPrefixOption);

    ret.objcOutput = getParams(results, ocOutOption);
    ret.objcUniAPIPrefix = getParams(results, uniapiPrefixOption);

    ret.tempDir = getParams(results, tempDirOption);
    ret.dartOutput = getParams(results, dartOutOption);

    kEnableNullSafety = getParams(results, dartNullSafetyOption) != 'false';
    ret.dartNullSafety = kEnableNullSafety;
    return ret;
  }

  // Path of the interface declaration project
  String projectPath = '';

  // Path for java outputting inside the Android project
  String javaOutputPath = '';

  String javaPackageName = '';

  String javaUniAPIPrefix = '';

  // Path for dart outputting inside the Flutter project
  String dartOutput = '';

  // Path for Objective-C outputting inside the iOS project
  String objcOutput = '';
  String objcUniAPIPrefix = '';

  String tempDir = '';

  bool dartNullSafety = true;

  static String getParams(ArgResults results, String key) {
    try {
      final dynamic ret = results[key];
      if (ret == null) {
        return '';
      } else {
        return ret.toString();
      }
    } on Exception {
      return '';
    }
  }
}
