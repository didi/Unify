import 'package:analyzer/dart/analysis/analysis_context_collection.dart';

import 'package:path/path.dart' as path;

import 'package:analyzer/dart/analysis/analysis_context_collection.dart'
    show AnalysisContextCollection;
import 'package:analyzer/dart/analysis/results.dart' show ParsedUnitResult;
import 'package:analyzer/dart/ast/ast.dart' as dart_ast;
import 'package:analyzer/error/error.dart' show AnalysisError;
import 'package:unify_flutter/analyzer/analyzer_error.dart';
import 'package:unify_flutter/analyzer/parse_results.dart';
import 'package:unify_flutter/analyzer/visitors/custom_type_visitor.dart';
import 'package:unify_flutter/analyzer/visitors/uniapi_ast_visitor.dart';
import 'package:unify_flutter/ast/base.dart';
import 'package:unify_flutter/ast/uniapi/ast_model.dart';
import 'package:unify_flutter/ast/uniapi/ast_module.dart';
import 'package:unify_flutter/utils/constants.dart';
import 'package:unify_flutter/utils/file/input_file.dart';

class _UniApiAnalyzerCache {
  _UniApiAnalyzerCache();
  UniApiAnalyzer? analyzer;
}

final _uniApiAnalyzerCache = _UniApiAnalyzerCache();

class UniApiAnalyzer {
  UniApiAnalyzer(this._files) {
    _uniApiAnalyzerCache.analyzer = this;
    _uniAstVisitor = UniApiAstVisitor();
  }

  final List<InputFile> _files;
  final List<String> _customTypeCache = [];
  final _customTypeVisitor = CustomTypeVisitor();
  final _compilationErrors = <Error>[];
  final _unitMapTable = <dart_ast.CompilationUnit, InputFile>{};

  late UniApiAstVisitor _uniAstVisitor;

  int _calculateLineNumber(String contents, int offset) {
    var result = 1;
    for (var i = 0; i < offset; ++i) {
      if (contents[i] == '\n') {
        result += 1;
      }
    }
    return result;
  }

  InputFile _findInputFile(String path) =>
      _files.firstWhere((file) => file.absolutePath == path);

  void _collectUnit(ParsedUnitResult result, String path) {
    final unit = result.unit;
    unit.accept(_customTypeVisitor);
    _unitMapTable.addEntries([MapEntry(unit, _findInputFile(path))]);
  }

  void _collectError(List<AnalysisError> errors) {
    for (final error in errors) {
      _compilationErrors.add(Error(
          message: error.message,
          filename: error.source.fullName,
          lineNumber:
              _calculateLineNumber(error.source.contents.data, error.offset)));
    }
  }

  void parseFile(String inputPath) {
    final collection = AnalysisContextCollection(
        includedPaths: <String>[path.absolute(path.normalize(inputPath))]);

    for (final context in collection.contexts) {
      for (final path in context.contextRoot.analyzedFiles()) {
        final session = context.currentSession;
        final result = session.getParsedUnit(path) as ParsedUnitResult;
        if (result.errors.isEmpty) {
          _collectUnit(result, path);
        } else {
          _collectError(result.errors);
        }
      }
    }
    _customTypeCache.addAll(_customTypeVisitor.results() +
        [typeUniCallback, typeFlutterError, typeFuture]);
    _uniAstVisitor.extendCustomType(_customTypeCache);

    _unitMapTable.forEach((unit, inputFile) {
      _uniAstVisitor.bind(inputFile, unit.toSource());
      unit.accept(_uniAstVisitor);
    });
  }

  AstType? convertAstType(String typeStr,
          {List<AstType> generics = const <AstType>[],
          bool maybeNull = false,
          List<bool> genericsMaybeNull = const <bool>[]}) =>
      _uniAstVisitor.stringToAstType(typeStr,
          generics: generics,
          maybeNull: maybeNull,
          genericsMaybeNull: genericsMaybeNull);

  void addCustomType(List<String> types) {
    _uniAstVisitor.extendCustomType(types);
  }

  ParseResults results() => _uniAstVisitor.results();

  static List<Model>? allModels() =>
      _uniApiAnalyzerCache.analyzer?.results().models;

  static List<Module>? allFlutterModules() =>
      _uniApiAnalyzerCache.analyzer?.results().flutterModules;

  static List<Module>? allNativeModules() =>
      _uniApiAnalyzerCache.analyzer?.results().nativeModules;

  static void mockParseResults(
      {List<Model>? models,
      List<Module>? flutterModules,
      List<Module>? nativeModules}) {
    _uniApiAnalyzerCache.analyzer?._uniAstVisitor.mockParseResults(
        models: models,
        flutterModules: flutterModules,
        nativeModules: nativeModules);
  }
}

AstType? convertAstType(String typeStr,
        {List<AstType> generics = const <AstType>[],
        bool maybeNull = false,
        List<bool> genericsMaybeNull = const <bool>[]}) =>
    _uniApiAnalyzerCache.analyzer?.convertAstType(typeStr,
        generics: generics,
        maybeNull: maybeNull,
        genericsMaybeNull: genericsMaybeNull);

void registerCustomType(String type) {
  _uniApiAnalyzerCache.analyzer?.addCustomType([type]);
}
