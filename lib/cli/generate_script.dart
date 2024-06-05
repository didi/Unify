import 'package:unify_flutter/ast/basic/ast_custom.dart';
import 'package:unify_flutter/ast/basic/ast_list.dart';
import 'package:unify_flutter/ast/basic/ast_string.dart';
import 'package:unify_flutter/ast/basic/ast_variable.dart';
import 'package:unify_flutter/generator/widgets/base/line.dart';
import 'package:unify_flutter/generator/widgets/code_template.dart';
import 'package:unify_flutter/generator/widgets/code_unit.dart';
import 'package:unify_flutter/generator/widgets/lang/dart/dart_function.dart';
import 'package:unify_flutter/generator/widgets/lang/dart/dart_import.dart';
import 'package:unify_flutter/utils/file/input_file.dart';

String generateWorkerIsolateScript(List<InputFile> inputFiles) =>
    CodeTemplate(children: [
      ...inputFiles
          .map((file) => DartImport(fullClassName: file.relativePath))
          .toList(),
      DartImport(fullClassName: 'dart:io'),
      DartImport(fullClassName: 'dart:isolate'),
      DartImport(fullClassName: 'package:unify/worker/worker.dart'),
      EmptyLine(),
      DartFunction(
        functionName: 'main',
        isAsync: true,
        params: [
          Variable(AstList(generics: [AstString()]), 'args'),
          Variable(AstCustomType('SendPort'), 'sendPort')
        ],
        body: (depth) {
          final funcEncode = <CodeUnit>[];
          funcEncode.add(OneLine(
              depth: depth + 1,
              body: 'sendPort.send(await isolateRun(args));'));
          return funcEncode;
        },
      )
    ]).build();
