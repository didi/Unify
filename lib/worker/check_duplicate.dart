import 'dart:io';

import 'package:unify/analyzer/parse_results.dart';
import 'package:unify/utils/extension/list_extension.dart';
import 'package:unify/utils/log.dart';

void checkDuplicateSymbol(ParseResults results) {
  final uniModelASTs = results.models;
  final uniNativeModuleASTs = results.nativeModules;
  final uniFlutterModuleAst = results.flutterModules;

  final allClsName = [
    ...uniModelASTs.map((e) => e.name).toList(),
    ...uniNativeModuleASTs.map((e) => e.name).toList(),
    ...uniFlutterModuleAst.map((e) => e.name).toList()
  ];

  final duplicates = allClsName.getDuplicates();
  if (duplicates.isNotEmpty) {
    for (final clsName in duplicates) {
      printf('Class name \'$clsName\' in the following file:"');
      final dupPaths = <String>[
        ...uniModelASTs.map((e) => e.name == clsName ? e.inputFile.path : ''),
        ...uniNativeModuleASTs
            .map((e) => e.name == clsName ? e.inputFile.path : ''),
        ...uniFlutterModuleAst
            .map((e) => e.name == clsName ? e.inputFile.path : '')
      ];

      for (final e in dupPaths) {
        if (e.isNotEmpty) {
          printf(' $e');
        }
      }
    }
    printf(
        '" is duplicated, to avoid integration compilation errors in iOS, make sure the class name is unique!');
    exit(-1);
  }
}
