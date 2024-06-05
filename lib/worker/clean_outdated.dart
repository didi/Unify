import 'dart:io';

import 'package:unify_flutter/analyzer/parse_results.dart';
import 'package:unify_flutter/cli/options.dart';
import 'package:unify_flutter/generator/common.dart';
import 'package:unify_flutter/utils/constants.dart';
import 'package:unify_flutter/utils/file/file.dart';
import 'package:unify_flutter/utils/file/input_file.dart';
import 'package:unify_flutter/utils/log.dart';

final _whiteList = [kUniAPI, typeUniCallbackManager];
final _blackList = [
  '.DS_Store',
  'Model',
  typeUniCallback,
  typeUniCallbackManager,
  '$builtInFileNameModel$javaSuffix'
];

bool _isInFileList(InputFile file, List<InputFile?> fileList) {
  for (final white in _whiteList) {
    if (file.name.contains(white)) {
      return true;
    }
  }

  var fileNameFixed = file.path.split('.')[0].toLowerCase();
  // Determine if it is a Java * Register file, and if so, do not process it
  if (fileNameFixed.length > kRegister.length &&
      fileNameFixed.substring(fileNameFixed.length - kRegister.length) ==
          kRegister) {
    fileNameFixed = fileNameFixed.replaceFirst(
        kRegister, '', fileNameFixed.length - kRegister.length);
  }

  for (final interfaceFile in fileList) {
    if (interfaceFile == null) {
      continue;
    }
    final interfaceFileName = interfaceFile.path.split('.')[0].toLowerCase();
    if (fileNameFixed == interfaceFileName) {
      return true;
    }
  }

  return false;
}

List<InputFile> _findOutdatedFiles(
    List<InputFile> projectFiles, ParseResults results,
    {UniAPIOptions? options}) {
  final ret = <InputFile>[];
  final uniNativeModules = results.nativeModules;
  final uniFlutterModules = results.flutterModules;
  final uniModels = results.models;

  final iosUniAPIFile = '${options?.objcUniAPIPrefix ?? ''}$kUniAPI';
  final androidUniAPIFile = '${options?.javaUniAPIPrefix ?? ''}$kUniAPI';

  for (final file in projectFiles) {
    if (_blackList.contains(file.name)) {
      ret.add(file);
      continue;
    }

    if (file.name.contains(kUniAPI) &&
        (!file.name.contains(iosUniAPIFile) ||
            !file.name.contains(androidUniAPIFile))) {
      ret.add(file);
    }

    final content = File(file.absolutePath).readAsStringSync();
    if (content.contains(generatedCodeWarning)) {
      if (!_isInFileList(
              file, uniNativeModules.map((e) => e.inputFile).toList()) &&
          !_isInFileList(
              file, uniFlutterModules.map((e) => e.inputFile).toList()) &&
          !_isInFileList(file, uniModels.map((e) => e.inputFile).toList())) {
        ret.add(file);
      }
    }
  }

  return ret;
}

void _showOutdatedFileInfo(String platform, List<InputFile> outdatedFiles) {
  if (outdatedFiles.isNotEmpty) {
    printf('$platform:');
    for (final e in outdatedFiles) {
      printf('\t${e.absolutePath}');
    }
  }
}

// Delete the empty directory
Future<void> _cleanDir(String inputPath) async {
  if (inputPath.isEmpty) {
    return;
  }

  final dirs = await getDirsUnderPath(inputPath);
  for (final dir in dirs) {
    final d = Directory(dir.path);
    if (d.listSync().isEmpty) {
      d.deleteSync();
    }
  }
}

// Clean up outdated interface files
Future<void> cleanOutdatedUniApiFiles(
    UniAPIOptions options, String tempDirPath, ParseResults results) async {
  final androidPath = options.javaOutputPath;
  final flutterPath = options.dartOutput;
  final iosPath = options.objcOutput;

  final androidOutdatedFiles = <InputFile>[];
  final flutterOutdatedFiles = <InputFile>[];
  final iosOutdatedFiles = <InputFile>[];

  if (androidPath.isNotEmpty) {
    final androidFiles = await parseInputFiles(androidPath, tempDirPath);
    androidOutdatedFiles.addAll(_findOutdatedFiles(androidFiles, results));
  }

  if (flutterPath.isNotEmpty) {
    final flutterFiles = await parseInputFiles(flutterPath, tempDirPath);
    flutterOutdatedFiles.addAll(_findOutdatedFiles(flutterFiles, results));
  }

  if (iosPath.isNotEmpty) {
    final iosFiles = await parseInputFiles(iosPath, tempDirPath);
    iosOutdatedFiles
        .addAll(_findOutdatedFiles(iosFiles, results, options: options));
  }

  final outdatedFiles = [
    ...flutterOutdatedFiles,
    ...androidOutdatedFiles,
    ...iosOutdatedFiles
  ];

  if (outdatedFiles.isEmpty) {
    return;
  }

  printf('发现过时的接口生成代码：');
  _showOutdatedFileInfo('Flutter', flutterOutdatedFiles);
  _showOutdatedFileInfo('Android', androidOutdatedFiles);
  _showOutdatedFileInfo('iOS', iosOutdatedFiles);

  printf('\n 是否删除？(Y/N)');
  final answer = stdin.readLineSync();

  if (answer != 'Y' && answer != 'y') {
    return;
  }

  for (final file in outdatedFiles) {
    printf('delete ${file.absolutePath}');
    File(file.absolutePath).deleteSync();
  }

  // After deleting the outdated interface, delete the empty directory again
  await _cleanDir(androidPath);
  await _cleanDir(iosPath);
  await _cleanDir(flutterPath);
}
