import 'package:unify_flutter/analyzer/parse_results.dart';
import 'package:analyzer/dart/ast/ast.dart' as dart_ast;
import 'package:unify_flutter/analyzer/visitors/base_ast_visitor.dart';
import 'package:unify_flutter/analyzer/visitors/initializer_visitor.dart';
import 'package:unify_flutter/ast/base.dart';
import 'package:unify_flutter/ast/basic/ast_custom.dart';
import 'package:unify_flutter/ast/basic/ast_variable.dart';
import 'package:unify_flutter/ast/uniapi/ast_method.dart';
import 'package:unify_flutter/ast/uniapi/ast_model.dart';
import 'package:unify_flutter/ast/uniapi/ast_module.dart';
import 'package:unify_flutter/utils/constants.dart';
import 'package:unify_flutter/utils/extension/string_extension.dart';
import 'package:unify_flutter/utils/file/input_file.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/src/dart/ast/token.dart' as src_dart_token;
import 'package:unify_flutter/utils/log.dart';

class UniApiAstVisitor extends BaseAstVisitor {
  UniApiAstVisitor();

  final List<String> _allCustomTypes = <String>[];
  final List<Model> _models = <Model>[];
  final List<Module> _flutterModules = <Module>[];
  final List<Module> _nativeModules = <Module>[];

  String? source;
  InputFile? inputFile;

  Model? _currentModel;
  Module? _flutterModule;
  Module? _nativeModule;

  @override
  Object? visitClassDeclaration(dart_ast.ClassDeclaration node) {
    _storeCurrentModel();
    _storeFlutterModule();
    _storeNativeModule();
    final codeComments = _codeCommentsParser(node.documentationComment?.tokens);
    if (node.abstractKeyword != null) {
      if (isUniNativeModule(node.metadata)) {
        _nativeModule = Module(inputFile!,
            name: node.name.lexeme,
            methods: <Method>[],
            codeComments: codeComments);
      } else if (isUniFlutterModule(node.metadata)) {
        _flutterModule = Module(inputFile!,
            name: node.name.lexeme,
            methods: <Method>[],
            codeComments: codeComments);
      }
    } else if (isUniModel(node.metadata)) {
      _currentModel = Model(node.name.lexeme, inputFile!,
          fields: [], codeComments: codeComments);
    }

    node.visitChildren(this);
    return null;
  }

  @override
  Object? visitMethodDeclaration(dart_ast.MethodDeclaration node) {
    final name = node.name.lexeme;
    final ignoreError = isIgnoreError(node.metadata);

    final returnType = node.returnType!;

    final returnTypeIdentifier =
        getFirstChildOfType<src_dart_token.SimpleToken>(returnType)!;
    final isNullable = returnType.question != null;
    final returnTypeName = returnTypeIdentifier.lexeme;
    final isAsync = returnTypeName == typeFuture;

    final codeComments = _codeCommentsParser(node.documentationComment?.tokens);

    final genericsMaybeNull = <bool>[];
    typeGenericsArgumentsMaybeNull(
        (returnType as dart_ast.NamedType).typeArguments, genericsMaybeNull);
    final astType = stringToAstType(returnTypeName,
        generics: typeAnnotationsToTypeArguments(returnType.typeArguments),
        maybeNull: isNullable,
        genericsMaybeNull: genericsMaybeNull);

    final parameters = node.parameters!;
    final arguments =
        parameters.parameters.map(formalParameterToField).toList();

    // '@RequiredMessager()' 场景
    final mVariable = handleRequiredMessagerAnnotation(node);
    if (mVariable != null) {
      arguments.add(mVariable);
    }

    if (_nativeModule != null && astType is AstCustomType && isAsync == true) {
      astType.isNativeModule = true;
    }

    final method = Method(
        name: name,
        returnType: astType!,
        parameters: arguments,
        ignoreError: ignoreError,
        isAsync: isAsync,
        codeComments: codeComments);

    if (_flutterModule != null) {
      _flutterModule!.methods.add(method);
    } else if (_nativeModule != null) {
      _nativeModule!.methods.add(method);
    }

    node.visitChildren(this);
    return null;
  }

  @override
  Object? visitFieldDeclaration(dart_ast.FieldDeclaration node) {
    if (_currentModel != null) {
      final type = node.fields.type;
      if (!node.isStatic && type is dart_ast.NamedType) {
        final initializerVisitor = InitializerVisitor();
        node.visitChildren(initializerVisitor);
        if (initializerVisitor.initializer != null) {
          printf(
              'visitFieldDeclaration error! Initialization isn\'t supported for fields in UniAPI data classes ("$node"), just use nullable types with no initializer (example "int? x;").');
        } else {
          final typeArguments = type.typeArguments;
          // 类型 type.name.name
          // isNullable type.question != null
          // 属性名称 node.fields.variables[0].name.lexeme
          final fieldName = node.fields.variables[0].name.lexeme;
          final typeString = type.name2.lexeme;
          final isNullable = type.question != null;
          final codeComments =
              _codeCommentsParser(node.documentationComment?.tokens);

          final genericsMaybeNull = <bool>[];
          typeGenericsArgumentsMaybeNull(typeArguments, genericsMaybeNull);
          final astType = stringToAstType(typeString,
              generics: typeAnnotationsToTypeArguments(typeArguments),
              maybeNull: isNullable,
              genericsMaybeNull: genericsMaybeNull);

          if (astType != null) {
            final variable =
                Variable(astType, fieldName, codeComments: codeComments);
            _currentModel?.fields.add(variable);
          }
        }
      }
    }
    node.visitChildren(this);
    return null;
  }

  UniApiAstVisitor bind(InputFile inputFile, String source) {
    this.inputFile = inputFile;
    this.source = source;
    return this;
  }

  ParseResults results() {
    _storeCurrentModel();
    _storeFlutterModule();
    _storeNativeModule();

    return ParseResults(
        models: _models,
        flutterModules: _flutterModules,
        nativeModules: _nativeModules);
  }

  void extendCustomType(List<String> types) {
    _allCustomTypes.addAll(types.toSet().toList());
  }

  void mockParseResults(
      {List<Model>? models,
      List<Module>? flutterModules,
      List<Module>? nativeModules}) {
    if (models != null && models.isNotEmpty) {
      _models.addAll(models);
    }

    if (flutterModules != null && flutterModules.isNotEmpty) {
      _flutterModules.addAll(flutterModules);
    }

    if (nativeModules != null && nativeModules.isNotEmpty) {
      _nativeModules.addAll(nativeModules);
    }
  }

  void _storeCurrentModel() {
    if (_currentModel != null) {
      _models.add(_currentModel!);
      _currentModel = null;
    }
  }

  void _storeFlutterModule() {
    if (_flutterModule != null) {
      _flutterModules.add(_flutterModule!);
      _flutterModule = null;
    }
  }

  void _storeNativeModule() {
    if (_nativeModule != null) {
      _nativeModules.add(_nativeModule!);
      _nativeModule = null;
    }
  }

  List<String> _codeCommentsParser(List<Token>? comments) {
    const docCommentPrefix = '///';
    return comments
            ?.map((line) => line.length > docCommentPrefix.length
                ? line
                    .toString()
                    .substring(docCommentPrefix.length)
                    .replaceAll(RegExp(r'/\*|\*/'), '')
                : '')
            .toList() ??
        <String>[];
  }

  Variable formalParameterToField(dart_ast.FormalParameter parameter) {
    final namedType = getFirstChildOfType<dart_ast.NamedType>(parameter);
    if (namedType != null) {
      final parameterName = parameter.name!.lexeme;
      final isNullable = namedType.question != null;
      final typeString = namedType.name2.lexeme;
      final astType = stringToAstType(typeString,
          generics: typeAnnotationsToTypeArguments(namedType.typeArguments),
          maybeNull: isNullable);
      return Variable(astType!, parameterName);
    } else {
      throw Exception('formalParameterToField faild!');
    }
  }

  Variable? handleRequiredMessagerAnnotation(dart_ast.MethodDeclaration node) {
    /* 
      "UniFlutterModule" mode and interface with "RequiredMessenger" annotation.
      Additional 'binaryMessenger' parameter is required for interface parameters.
    */
    if (_flutterModule != null && isRequiredMessager(node.metadata)) {
      return Variable(
          AstCustomType(requiredMessagerAnnotation, fromRequiredMessager: true),
          Keys.binaryMessenger);
    }

    return null;
  }

  AstType? stringToAstType(String typeStr,
          {List<AstType> generics = const <AstType>[],
          bool maybeNull = false,
          List<bool> genericsMaybeNull = const <bool>[]}) =>
      typeStr.astType(
        generics: generics,
        maybeNull: maybeNull,
        isCustomType: _allCustomTypes.contains(typeStr),
        genericsMaybeNull: genericsMaybeNull,
      );

  T? getFirstChildOfType<T>(dart_ast.AstNode entity) {
    for (final child in entity.childEntities) {
      if (child is T) {
        return child as T;
      }
    }
    return null;
  }

  List<AstType> typeAnnotationsToTypeArguments(
      dart_ast.TypeArgumentList? typeArguments) {
    final result = <AstType>[];
    if (typeArguments != null) {
      for (final Object x in typeArguments.childEntities) {
        if (x is dart_ast.NamedType) {
          final typeString = x.name2.lexeme;
          final isNullable = x.question != null;
          final typeArgs = typeAnnotationsToTypeArguments(x.typeArguments);
          final astType = stringToAstType(typeString,
              generics: typeArgs, maybeNull: isNullable);
          if (astType != null) {
            result.add(astType);
          }
        }
      }
    }
    return result;
  }

  void typeGenericsArgumentsMaybeNull(
      dart_ast.TypeArgumentList? typeArguments, List<bool> outResult) {
    if (typeArguments != null) {
      for (final Object x in typeArguments.childEntities) {
        if (x is dart_ast.NamedType) {
          final isNullable = x.question != null;
          outResult.add(isNullable);
          typeGenericsArgumentsMaybeNull(x.typeArguments, outResult);
        }
      }
    }
  }
}
