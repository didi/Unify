import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:unify_flutter/utils/constants.dart';
import 'package:unify_flutter/utils/file/input_file.dart';

Future<List<FileSystemEntity>> dirContents(Directory dir,
    {bool recursive = false}) async {
  final files = <FileSystemEntity>[];
  final completer = Completer<List<FileSystemEntity>>();
  final lister = dir.list(recursive: recursive);
  lister.listen((file) {
    if (!isDSStore(file.path)) files.add(file);
  }, onDone: () => completer.complete(files));
  return completer.future;
}

Directory createTempDir() {
  return Directory.systemTemp.createTempSync('$projectNameSnake.');
}

void createAndWrite(String path, String content) {
  final file = File(path);
  file.createSync(recursive: true);
  file.writeAsStringSync(content);
}

Future<List<FileSystemEntity>> getDirsUnderPath(String projectPath) async {
  var files = await dirContents(Directory(projectPath), recursive: true);
  files = files
      .where((file) => FileSystemEntity.isDirectorySync(file.path))
      .toList();
  return files;
}

/// This creates a relative path from `from` to `input`, the output being a
/// posix path on all platforms.
String posixRelative(String input, {String from = ''}) {
  final context = path.Context(style: path.Style.posix);
  final rawInputPath = input;
  final absInputPath = File(rawInputPath).absolute.path;
  // By going through URI's we can make sure paths can go between drives in
  // Windows.
  final inputUri = path.toUri(absInputPath);
  final posixAbsInputPath = context.fromUri(inputUri);
  final tempUri = path.toUri(from);
  final posixTempPath = context.fromUri(tempUri);
  return context.relative(posixAbsInputPath, from: posixTempPath);
}

/// Determine if it is a '.DS_Store' file
/// File collection exclusion '.DS_Store' file
/// fixed : IsolateSpawnException: Unable to spawn isolate: xxxx/.DS_Store: Error: The control character U+0000 can only be used in strings and comments.
bool isDSStore(String path) => path.contains('.DS_Store');

Future<List<InputFile>> parseInputFiles(
    String projectPath, String tempDir) async {
  var files = await dirContents(Directory(projectPath), recursive: true);
  files =
      files.where((file) => FileSystemEntity.isFileSync(file.path)).toList();
  return files.map((file) {
    return InputFile(
        path: posixRelative(file.path, from: projectPath),
        absolutePath: file.path,
        relativePath: posixRelative(file.path, from: tempDir));
  }).toList();
}
