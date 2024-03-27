import 'package:unify/analyzer/analyzer_lib.dart';
import 'package:unify/utils/constants.dart';
import 'package:unify/utils/extension/ast_extension.dart';
import 'package:unify/ast/basic/ast_custom.dart';
import 'package:unify/ast/basic/ast_list.dart';
import 'package:unify/ast/basic/ast_map.dart';
import 'package:unify/ast/basic/ast_object.dart';
import 'package:unify/ast/basic/ast_string.dart';
import 'package:unify/ast/basic/ast_variable.dart';
import 'package:unify/ast/uniapi/ast_method.dart';
import 'package:unify/ast/uniapi/ast_model.dart';
import 'package:unify/cli/options.dart';
import 'package:unify/generator/widgets/base/comment.dart';
import 'package:unify/generator/widgets/base/line.dart';
import 'package:unify/generator/widgets/code_template.dart';
import 'package:unify/generator/widgets/code_unit.dart';
import 'package:unify/generator/widgets/lang/dart/dart_class.dart';
import 'package:unify/generator/widgets/lang/dart/dart_function.dart';
import 'package:unify/generator/widgets/lang/dart/dart_import.dart';
import 'package:unify/generator/widgets/lang/java/java_class.dart';
import 'package:unify/generator/widgets/lang/java/java_function.dart';
import 'package:unify/generator/widgets/lang/java/java_import.dart';
import 'package:unify/generator/widgets/lang/java/java_package.dart';
import 'package:unify/generator/widgets/lang/oc/oc_class.dart';
import 'package:unify/generator/widgets/lang/oc/oc_function.dart';
import 'package:unify/generator/widgets/lang/oc/oc_import.dart';
import 'package:unify/generator/widgets/lang/oc/oc_reference.dart';
import 'package:unify/utils/extension/codeunit_extension.dart';
import 'package:unify/utils/utils.dart';

abstract class ModelGenerator {
  static String javaCode(Model model, UniAPIOptions options) {
    return CodeTemplate(children: [
      CommentUniAPI(),
      EmptyLine(),
      JavaPackage(model.inputFile, options),
      EmptyLine(),
      JavaImport(fullClassName: 'java.util.List'),
      JavaImport(fullClassName: 'java.util.Map'),
      JavaImport(fullClassName: 'java.util.HashMap'),
      JavaImport(fullClassName: 'java.util.ArrayList'),
      JavaImport(
          fullClassName:
              '${options.javaPackageName}.$projectName.$uniModelAnnotation'),
      JavaCustomNestedImports(model.inputFile, options, fields: model.fields),
      EmptyLine(),
      if (model.codeComments.isNotEmpty)
        Comment(
            comments: [...model.codeComments],
            commentType: CommentType.commentBlock),
      JavaClass(
          className: model.name,
          parentClass: uniModelAnnotation,
          isPublic: true,
          privateFields: model.fields,
          fieldGettersAndSetters: model.fields,
          hasFromMap: true,
          injectedJavaCodes: (depth) => [
                ...JavaCollectionCloneFunction()
                    .handlerJavaCollectionType(fields: model.fields),
              ],
          hasToMap: true)
    ]).build();
  }

  static String ocHeader(Model model, UniAPIOptions options) {
    return CodeTemplate(children: [
      CommentUniAPI(),
      EmptyLine(),
      OCImport(fullImportName: 'Foundation/Foundation.h'),
      OCCustomNestedImports(model.inputFile, options, fields: model.fields),
      EmptyLine(),
      OneLine(body: 'NS_ASSUME_NONNULL_BEGIN'),
      EmptyLine(),
      if (model.codeComments.isNotEmpty)
        Comment(
            comments: [...model.codeComments],
            commentType: CommentType.commentBlock),
      OCClassDeclaration(
          className: model.name,
          parentClass: 'NSObject', // use AST type fixme
          isInterface: true,
          properties: model.fields,
          classMethods: [
            Method(
                name: 'fromMap',
                returnType: AstCustomType(model.name),
                parameters: [Variable(AstMap(keyType: AstString()), 'dict')]),
            Method(
                name: 'modelList',
                returnType: AstList(generics: [AstCustomType(model.name)]),
                parameters: [
                  Variable(AstList(generics: [AstMap()]), 'list')
                ]),
            Method(
                name: 'dicList',
                returnType: AstList(generics: [AstMap()]),
                parameters: [
                  Variable(
                      AstList(generics: [AstCustomType(model.name)]), 'list')
                ])
          ],
          instanceMethods: [
            Method(name: 'toMap', returnType: AstMap(keyType: AstString()))
          ]),
      EmptyLine(),
      OneLine(body: 'NS_ASSUME_NONNULL_END'),
    ]).build();
  }

  static String ocSource(Model model, UniAPIOptions options) {
    return CodeTemplate(children: [
      CommentUniAPI(),
      EmptyLine(),
      OCImport(
          fullImportName: '${model.inputFile.pascalName}.h',
          importType: ocImportTypeLocal),
      EmptyLine(),
      OCClassDeclaration(
          className: model.name, hasExtension: true, isInterface: true),
      EmptyLine(),
      ...OCCollectionCloneFunction(fields: model.fields)
          .genCollectionFunction(),
      OCClassImplementation(
          className: model.name,
          injectOCCodeUnit: (depth) {
            final ret = <CodeUnit>[];
            ret.add(OCPredefinedFuncModelList());
            ret.add(EmptyLine());
            ret.add(OCPredefinedFuncDictList());
            ret.add(EmptyLine());
            ret.add(OCPredefinedFuncWrapNil());
            ret.add(EmptyLine());
            ret.add(OCFunction(
                functionName: 'fromMap',
                isClassMethod: true,
                returnType: AstCustomType(model.name),
                params: [Variable(AstMap(keyType: AstString()), 'dict')],
                body: (depth) {
                  final ret = <CodeUnit>[
                    OneLine(
                        depth: depth + 1,
                        body:
                            'if ((NSNull *)dict == [NSNull null]) return nil;'),
                    OneLine(
                        depth: depth + 1,
                        body:
                            '${OCReference(AstCustomType(model.name)).build()} result = [[${AstCustomType(model.name).ocType()} alloc] init];'),
                    ...model.fields.map((field) {
                      return OneLine(
                          depth: depth + 1,
                          body:
                              'result.${field.name} = [self wrapNil:${field.type.realType().convertOcJson2Obj(vname: 'dict[@"${field.name}"]')}];');
                    }),
                    OneLine(depth: depth + 1, body: 'return result;'),
                  ];
                  return ret;
                }));
            ret.add(EmptyLine());
            ret.add(OCFunction(
                functionName: 'toMap',
                isInstanceMethod: true,
                returnType: AstMap(keyType: AstString()),
                body: (depth) {
                  final ret = <CodeUnit>[];
                  ret.add(OneLine(
                      depth: depth + 1,
                      body:
                          'return [NSDictionary dictionaryWithObjectsAndKeys:'));

                  ret.addAll(model.fields.map((field) => OneLine(
                      depth: depth + 2,
                      body:
                          '(self.${field.name} ? ${field.type.convertOcObj2Json('self.${field.name}')} : [NSNull null]), @"${field.name}",')));
                  ret.add(OneLine(depth: depth + 2, body: 'nil];'));
                  return ret;
                }));
            return ret;
          })
    ]).build();
  }

  static String dartCode(Model model, UniAPIOptions options) {
    return CodeTemplate(children: [
      CommentUniAPI(),
      EmptyLine(),
      DartCustomNestedImports(model.inputFile, options, fields: model.fields),
      EmptyLine(),
      if (model.codeComments.isNotEmpty)
        Comment(
            comments: [...model.codeComments],
            commentType: CommentType.commentTripleBackSlash),
      DartClass(
          className: model.name,
          fields: model.fields,
          injectedJavaCodes: (depth) {
            final ret = <CodeUnit>[];

            ret.add(DartFunction(
                depth: depth + 1,
                functionName: 'encode',
                returnType: const AstObject(),
                body: (depth) {
                  final funcEncode = <CodeUnit>[];
                  funcEncode.add(OneLine(
                      depth: depth + 1,
                      body:
                          'final Map<String, dynamic> ret = <String, dynamic>{};'));
                  for (final field in model.fields) {
                    funcEncode.add(OneLine(
                        depth: depth + 1,
                        body: "ret['${field.name}'] = ",
                        hasNewline: false));

                    funcEncode.add(OneLine(body: '${unpackField(field)};'));
                  }
                  funcEncode
                      .add(OneLine(depth: depth + 1, body: 'return ret;'));

                  return funcEncode;
                }));

            ret.add(EmptyLine());

            ret.add(DartFunction(
                depth: depth + 1,
                functionName: 'decode',
                isStatic: true,
                returnType: convertAstType(model.name)!,
                params: [Variable(const AstObject(), 'message')],
                body: (depth) {
                  final funcDecode = <CodeUnit>[];
                  if (!kEnableNullSafety) {
                    funcDecode.add(OneLine(
                        depth: depth + 1,
                        body: 'if (message == null) return null;'));
                  }
                  funcDecode.add(OneLine(
                      depth: depth + 1,
                      body:
                          'final Map<dynamic, dynamic> rawMap = message as Map<dynamic, dynamic>;'));
                  funcDecode.add(OneLine(
                      depth: depth + 1,
                      body:
                          'final Map<String, dynamic> map = Map.from(rawMap);'));
                  funcDecode.add(OneLine(
                      depth: depth + 1, body: 'return ${model.name}()'));
                  for (var index = 0; index < model.fields.length; index++) {
                    final field = model.fields[index];
                    funcDecode.add(OneLine(
                        depth: depth + 2,
                        body: '..${field.name} = ',
                        hasNewline: false));

                    funcDecode
                        .add(OneLine(body: "map['${field.name}'] == null"));
                    final nullValueJudgingConditions =
                        field.type.realType() is AstCustomType &&
                            (kEnableNullSafety == false ||
                                field.type.realType().maybeNull == true);
                    funcDecode.add(OneLine(
                        depth: depth + 3,
                        body:
                            '? ${nullValueJudgingConditions == true ? null : field.type.realType().dartDefault()}'));
                    funcDecode.add(OneLine(
                        depth: depth + 3,
                        body:
                            ': ${field.type.realType().convertDartJson2Obj(vname: "map['${field.name}']")}'));
                  }
                  funcDecode.add(OneLine(depth: depth + 2, body: ';'));
                  return funcDecode;
                }));

            return ret;
          })
    ]).build();
  }
}
