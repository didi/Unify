import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:args/command_runner.dart';
import 'package:unify_flutter/cli/generate_script.dart';
import 'package:unify_flutter/cli/options.dart';
import 'package:unify_flutter/utils/constants.dart';
import 'package:unify_flutter/utils/file/file.dart';
import 'package:unify_flutter/utils/log.dart';
import 'package:path/path.dart' as path;
import 'package:unify_flutter/utils/template_internal/dart/caches.dart';
import 'package:unify_flutter/utils/template_internal/dart/uni_api.dart';
import 'package:unify_flutter/utils/template_internal/dart/uni_callback.dart';
import 'package:unify_flutter/utils/template_internal/dart/uni_model.dart';
import 'package:unify_flutter/utils/template_internal/java/uni_model.dart';

class GenerateApiCommand extends Command<int> {
  GenerateApiCommand()
      : _tempDir = createTempDir(),
        _receivePort = ReceivePort(),
        _completer = Completer<int>() {
    _addBaseOptions();
  }

  final Directory? _tempDir;
  final ReceivePort? _receivePort;
  final Completer<int>? _completer;

  @override
  String get name => 'api';

  @override
  String get usage => _generateUsage();

  @override
  Future<int> run() async {
    _copyPreCreatedFiles(readOptions());
    await _runWorkerIsolate(argResults!.arguments);

    final exitCode = await _completer?.future;
    return exitCode ?? 0;
  }

  void _addBaseOptions() {
    argParser
      ..addOption(inputOption,
          help:
              'Configure the directory path for custom templates [mandatory parameter]')
      ..addOption(javaOutOption,
          help:
              'Configure the output path of generated Java code [mandatory parameter]')
      ..addOption(javaPackageOption,
          help:
              'Configure package name information for generating Java code [mandatory parameter]')
      ..addOption(ocOutOption,
          help:
              'Configure the output path for generating Obj-C code [mandatory parameter]')
      ..addOption(uniapiPrefixOption,
          help:
              'Configure the prefix of the class name of the generated class UniAPI [optional parameter]')
      ..addOption(dartOutOption,
          help:
              'Configure the output path for generating Dart code [mandatory parameter]')
      ..addOption(tempDirOption, hide: true)
      ..addOption(dartNullSafetyOption,
          help:
              'Configure whether to enable null security for generating Dart code, default value is true, enable null security [Optional parameter]"');
  }

  UniAPIOptions readOptions() => UniAPIOptions.fromParser(argResults!);

  @override
  void printUsage() => printf(usage);

  String _generateUsage() {
    const usagePrefix = 'Usage: dart run unify api [arguments]\n\n';
    var buffer = StringBuffer();

    buffer.write(usagePrefix);
    buffer.write(argParser.usage);
    return buffer.toString();
  }

  @override
  String get description =>
      'Generating code for Android, iOS, and Flutter across all three platforms based on protocol templates.';

  Future<void> _runWorkerIsolate(List<String> args) async {
    assert(_tempDir != null);

    final exeFile = await _generateWorkerScriptFile();
    await Isolate.spawnUri(
        Uri.file(exeFile.path),
        [...args, '--$tempDirOption=${_tempDir!.path}'],
        _receivePort?.sendPort);

    _receivePort?.listen((dynamic message) {
      try {
        _completer?.complete(message as int);
      } on Exception catch (exception) {
        _completer?.completeError(exception);
      }
    });

    _tempDir!.deleteSync(recursive: true);
  }

  /// Copy some embedded files to the project directory
  void _copyPreCreatedFiles(UniAPIOptions options) {
    createAndWrite(
        path.join(options.javaOutputPath, projectName, dotJavaFileUniModel),
        javaUniModelContent(options.javaPackageName));
    createAndWrite(
        path.join(options.dartOutput, projectName, dotDartFileCaches),
        dartCachesContent);
    createAndWrite(
        path.join(options.dartOutput, projectName, dotDartFileUniCallback),
        dartUniCallbackContent(nullSafty: options.dartNullSafety));
    createAndWrite(path.join(options.dartOutput, projectName, dotDartFileModel),
        dartUniModelContent);
    createAndWrite(
        path.join(options.dartOutput, projectName, dotDartFileUniApi),
        dartUniApiContent(nullSafty: options.dartNullSafety));
  }

  /// Generate an executable file for worker isolate
  Future<File> _generateWorkerScriptFile() async {
    final projectPath = readOptions().projectPath;

    final inputFiles = await parseInputFiles(projectPath, _tempDir!.path);
    final code = generateWorkerIsolateScript(inputFiles);
    log('code', value: code);
    final tempFile = File(
        path.join(_tempDir!.path, '_${projectNameSnake}_temp_$dartSuffix'));
    tempFile.writeAsStringSync(code);

    return tempFile;
  }
}

extension GenCmdArgsExtensions on List<String> {
  UniAPIOptions toOptions() =>
      UniAPIOptions.fromParser(GenerateApiCommand().argParser.parse(this));
}
