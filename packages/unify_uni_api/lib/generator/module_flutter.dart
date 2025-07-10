import 'package:unify_flutter/analyzer/analyzer_lib.dart';
import 'package:unify_flutter/generator/common.dart';
import 'package:unify_flutter/utils/constants.dart';
import 'package:unify_flutter/utils/extension/ast_extension.dart';
import 'package:unify_flutter/ast/basic/ast_custom.dart';
import 'package:unify_flutter/ast/basic/ast_variable.dart';
import 'package:unify_flutter/ast/basic/ast_void.dart';
import 'package:unify_flutter/ast/uniapi/ast_method.dart';
import 'package:unify_flutter/ast/uniapi/ast_module.dart';
import 'package:unify_flutter/cli/options.dart';
import 'package:unify_flutter/generator/widgets/base/block.dart';
import 'package:unify_flutter/generator/widgets/base/comment.dart';
import 'package:unify_flutter/generator/widgets/base/line.dart';
import 'package:unify_flutter/generator/widgets/code_template.dart';
import 'package:unify_flutter/generator/widgets/code_unit.dart';
import 'package:unify_flutter/generator/widgets/lang/dart/dart_class.dart';
import 'package:unify_flutter/generator/widgets/lang/dart/dart_function.dart';
import 'package:unify_flutter/generator/widgets/lang/dart/dart_import.dart';
import 'package:unify_flutter/generator/widgets/lang/java/java_class.dart';
import 'package:unify_flutter/generator/widgets/lang/java/java_function.dart';
import 'package:unify_flutter/generator/widgets/lang/java/java_import.dart';
import 'package:unify_flutter/generator/widgets/lang/java/java_package.dart';
import 'package:unify_flutter/generator/widgets/lang/oc/oc_class.dart';
import 'package:unify_flutter/generator/widgets/lang/oc/oc_forward_declaration.dart';
import 'package:unify_flutter/generator/widgets/lang/oc/oc_function.dart';
import 'package:unify_flutter/generator/widgets/lang/oc/oc_import.dart';
import 'package:unify_flutter/utils/extension/codeunit_extension.dart';
import 'package:unify_flutter/utils/extension/list_extension.dart';
import 'package:unify_flutter/utils/extension/method_extension.dart';

abstract class FlutterModuleGenerator {
  static String javaCode(Module module, UniAPIOptions options) {
    // 注册范型
    registerCustomType('T');
    registerCustomType('BinaryMessenger');

    return CodeTemplate(children: [
      CommentUniAPI(),
      EmptyLine(),
      JavaPackage(module.inputFile, options),
      EmptyLine(),
      JavaImport(fullClassName: 'java.util.List'),
      JavaImport(fullClassName: 'java.util.ArrayList'),
      JavaImport(fullClassName: 'java.util.Map'),
      JavaImport(fullClassName: 'java.util.HashMap'),
      JavaImport(fullClassName: 'io.flutter.plugin.common.BinaryMessenger'),
      JavaImport(fullClassName: 'io.flutter.plugin.common.BasicMessageChannel'),
      JavaImport(
          fullClassName: 'io.flutter.plugin.common.StandardMessageCodec'),
      JavaImport(
          fullClassName:
              '${options.javaPackageName}.${options.javaUniAPIPrefix}$kUniAPI'),
      JavaCustomNestedImports(module.inputFile, options,
          methods: module.methods),
      EmptyLine(),
      Comment(
          comments: [uniFlutterModuleDesc, ...module.codeComments],
          commentType: CommentType.commentBlock),
      JavaClass(
          className: module.name,
          isPublic: true,
          privateFields: [
            Variable(AstCustomType('BinaryMessenger'), 'messenger'),
          ],
          injectedJavaCodes: (depth) => [
                ...JavaCollectionCloneFunction()
                    .handlerJavaCollectionType(methods: module.methods),
                JavaFunction(
                    depth: depth,
                    isPublic: true,
                    functionName: 'setup',
                    params: [
                      Variable(AstCustomType('BinaryMessenger'), 'messenger')
                    ],
                    body: (depth) => [
                          OneLine(
                              depth: depth + 1,
                              body: 'this.messenger = messenger;'),
                          OneLine(
                              depth: depth + 1,
                              body:
                                  '${options.javaUniAPIPrefix}$kUniAPI.registerModule(this);')
                        ]),
                EmptyLine(),
                JavaClass(
                    depth: depth,
                    className: 'Result',
                    isInterface: true,
                    isPublic: true,
                    generics: [
                      'T'
                    ],
                    methods: [
                      Method(
                          name: 'result',
                          parameters: [Variable(AstCustomType('T'), 'result')])
                    ]),
                EmptyLine(),
                // 生成所有接口方法
                ...module.methods
                    .where((method) => method.name != module.name)
                    .map((method) {
                  // 参数处理
                  final argSignatures = <Variable>[];
                  argSignatures.addAll(method.parameters);
                  final resultType = method.returnType.realType();
                  if (resultType is! AstVoid) {
                    registerCustomType('Result');
                    Variable cbVar = Variable(
                        AstCustomType('Result', generics: [resultType]),
                        'callback');
                    if (!method.hasMessagerAnno) {
                      argSignatures.add(cbVar);
                    } else {
                      argSignatures.insertAtSecondLast(cbVar);
                    }
                  }
                  argSignatures.last.type
                      .reassignAstCustomType(typeBinaryMessengerInAndroid);

                  return JavaFunction(
                      depth: depth,
                      isPublic: true,
                      functionName: method.name,
                      params: argSignatures,
                      body: (depth) => [
                            OneLine(
                                depth: depth + 1,
                                body: 'BasicMessageChannel<Object> channel ='),
                            OneLine(
                                depth: depth + 2,
                                body:
                                    'new BasicMessageChannel<>(${!method.hasMessagerAnno ? 'messenger' : Keys.binaryMessenger}, "${makeChannelName(module, method)}", new StandardMessageCodec());'),
                            OneLine(
                                depth: depth + 1,
                                body:
                                    'Map<String, Object> parameters = new HashMap<>();'),
                            ...argSignatures.where((arg) {
                              return arg.type.astType() != 'Result' &&
                                  !arg.type.hasMessagerAnno();
                            }).map((arg) {
                              return OneLine(
                                  depth: depth + 1,
                                  body:
                                      'parameters.put("${arg.name}", ${arg.type.realType().convertJavaObj2Json(arg.name)});');
                            }),
                            if (resultType is AstVoid)
                              OneLine(
                                  depth: depth + 1,
                                  body: 'channel.send(parameters);'),
                            if (resultType is! AstVoid) ...[
                              OneLine(
                                  depth: depth + 1,
                                  body: 'channel.send(parameters, reply -> '),
                              ScopeBlock(
                                  depth: depth + 2,
                                  body: (depth) {
                                    return [
                                      OneLine(
                                          depth: depth,
                                          body: 'if (callback != null)'),
                                      ScopeBlock(
                                          depth: depth,
                                          body: (depth) {
                                            return [
                                              OneLine(
                                                  depth: depth,
                                                  body:
                                                      'callback.result(${method.returnType.realType().convertJavaJson2Obj(vname: 'reply', hasDefaultValue: false, showGenerics: true)});')
                                            ];
                                          })
                                    ];
                                  }),
                              OneLine(depth: depth + 1, body: ');')
                            ]
                          ]);
                })
              ])
    ]).build();
  }

  static String ocHeader(Module module, UniAPIOptions options) {
    registerCustomType('id');
    registerCustomType('UniCompleted');

    return CodeTemplate(children: [
      CommentUniAPI(),
      EmptyLine(),
      OCImport(fullImportName: 'Foundation/Foundation.h'),
      EmptyLine(),
      OneLine(body: 'NS_ASSUME_NONNULL_BEGIN'),
      OCForwardDeclaration(
          className: 'FlutterBinaryMessenger', isProtocol: true),
      OCCustomNestedImports(module.inputFile, options,
          methods: module.methods, isForwardDeclaration: true),
      OneLine(
          body: 'typedef void (^UniCompleted)(id result); // 这里result可能是nil'),
      EmptyLine(),
      Comment(comments: [
        uniFlutterModuleDesc,
        'Before using the code generated based on the "UniFlutterModule" template, you need to call the setup method to initialize it.',
        ...module.codeComments
      ]),
      OCClassDeclaration(
          className: module.name,
          parentClass: 'NSObject',
          isInterface: true,
          classMethods: [
            Method(name: 'setup', parameters: [
              Variable(
                  AstCustomType('id',
                      generics: [AstCustomType('FlutterBinaryMessenger')]),
                  'binaryMessenger')
            ]),
            ...module.methods.map(_transformFlutterModuleMethod)
          ]),
      EmptyLine(),
      OneLine(body: 'NS_ASSUME_NONNULL_END'),
    ]).build();
  }

  static String ocSource(Module module, UniAPIOptions options) {
    return CodeTemplate(children: [
      CommentUniAPI(),
      EmptyLine(),
      OCImport(
          fullImportName: '${module.name}.h', importType: ocImportTypeLocal),
      OCImport(fullImportName: 'Flutter/Flutter.h'),
      EmptyLine(),
      OCCustomNestedImports(module.inputFile, options, methods: module.methods),
      EmptyLine(),
      ...OCCollectionCloneFunction(methods: module.methods)
          .genCollectionFunction(),
      OCClassDeclaration(
          className: module.name,
          isInterface: true,
          hasExtension: true,
          properties: [
            Variable(
              AstCustomType('id',
                  generics: [AstCustomType('FlutterBinaryMessenger')]),
              'binaryMessenger',
            )
          ]),
      EmptyLine(),
      OCClassImplementation(
          className: module.name,
          injectOCCodeUnit: (depth) {
            final ret = <CodeUnit>[];

            // instance 方法
            ret.add(OneLine(depth: depth, body: '+ (instancetype)instance {'));
            ret.add(OneLine(
                depth: depth + 1,
                body: 'static ${module.name} *_instance = nil;'));
            ret.add(OneLine(
                depth: depth + 1, body: 'static dispatch_once_t onceToken;'));
            ret.add(OneLine(
                depth: depth + 1, body: 'dispatch_once(&onceToken, ^{'));
            ret.add(OneLine(
                depth: depth + 2,
                body: '_instance = [[${module.name} alloc] init];'));
            ret.add(OneLine(depth: depth + 1, body: '});'));
            ret.add(OneLine(depth: depth + 1, body: 'return _instance;'));
            ret.add(OneLine(depth: depth, body: '}'));
            ret.add(EmptyLine());

            // setup 方法
            ret.add(OneLine(
                depth: depth,
                body:
                    '+ (void)setup:(id<FlutterBinaryMessenger>)binaryMessenger {'));
            ret.add(OneLine(
                depth: depth + 1,
                body: '[[self instance] setBinaryMessenger:binaryMessenger];'));
            ret.add(OneLine(depth: depth, body: '}'));

            // 对每个模块方法进行封装
            for (final method in module.methods) {
              if (method.name == module.name) {
                continue;
              }

              // 在 FlutterModule 中，在生成的方法中，需要对方法签名进行修改
              final methodFixed = _transformFlutterModuleMethod(method);

              ret.add(OCFunction(
                  depth: depth,
                  functionName: methodFixed.name,
                  params: methodFixed.parameters,
                  isClassMethod: true,
                  body: (depth) {
                    final funcBody = <CodeUnit>[];

                    funcBody.add(OneLine(
                        depth: depth + 1,
                        body: 'FlutterBasicMessageChannel *channel ='));
                    funcBody.add(OneLine(
                        depth: depth + 2, body: '[FlutterBasicMessageChannel'));
                    funcBody.add(OneLine(
                        depth: depth + 3,
                        body:
                            'messageChannelWithName:@"${makeChannelName(module, methodFixed)}"'));
                    funcBody.add(OneLine(
                        depth: depth + 3,
                        body:
                            'binaryMessenger:${!methodFixed.hasMessagerAnno ? "[[self instance] binaryMessenger]" : Keys.binaryMessenger}];'));
                    funcBody.add(EmptyLine());

                    funcBody.add(OneLine(depth: depth + 1, body: '// 数据处理'));
                    funcBody.add(OneLine(
                        depth: depth + 1,
                        body:
                            'NSDictionary *msg = [NSDictionary dictionaryWithObjectsAndKeys:'));

                    // 参数传递使用原方法（不带 block 的）
                    funcBody.addAll(method.parameters.where((arg) {
                      return !arg.type.hasMessagerAnno(); // 排除 @RequiredMessager() 场景
                    }).map((arg) {
                      return OneLine(
                          depth: depth + 2,
                          body:
                              '[self wrapNil:${arg.type.convertOcObj2Json(arg.name)}], @"${arg.name}",');
                    }));

                    funcBody.add(OneLine(depth: depth + 2, body: 'nil];'));
                    funcBody.add(EmptyLine());

                    funcBody.add(OneLine(depth: depth + 1, body: '// 发送消息'));
                    // 判断返回类型也使用原方法，决定了时候有 block 调用
                    if (method.returnType is AstVoid) {
                      funcBody.add(OneLine(
                          depth: depth + 1,
                          body: '[channel sendMessage:msg];'));
                    } else {
                      funcBody.add(OneLine(
                          depth: depth + 1,
                          body:
                              '[channel sendMessage:msg reply:^(id  _Nullable reply) {'));
                      funcBody.add(OneLine(
                          depth: depth + 2,
                          body:
                              'if (reply && result) result(${method.returnType.realType().convertOcJson2Obj(vname: 'reply')});'));
                      funcBody.add(OneLine(depth: depth + 1, body: '}];'));
                    }

                    return funcBody;
                  }));
              ret.add(EmptyLine());
            }

            // wrapNil 空值保护函数
            ret.add(OneLine(depth: depth, body: '+ (id)wrapNil:(id)value {'));
            ret.add(OneLine(
                depth: depth + 1,
                body: 'return value == nil ? [NSNull null] : value;'));
            ret.add(OneLine(depth: depth, body: '}'));

            return ret;
          })
    ]).build();
  }

  static String dartCode(Module module, UniAPIOptions options) {
    return CodeTemplate(children: [
      CommentUniAPI(),
      EmptyLine(),
      DartImport(fullClassName: 'package:flutter/services.dart'),
      EmptyLine(),
      DartCustomNestedImports(module.inputFile, options,
          methods: module.methods),
      EmptyLine(),
      Comment(
          comments: [uniFlutterModuleDesc, ...module.codeComments],
          commentType: CommentType.commentTripleBackSlash),
      DartClass(
          className: module.name,
          isAbstract: true,
          methods: module.methods,
          injectedJavaCodes: (depth) {
            final ret = <CodeUnit>[];

            for (final method in module.methods) {
              if (method.name == module.name) {
                continue;
              }

              ret.add(DartFunction(
                depth: depth + 1,
                functionName: method.name,
                isAbstract: true,
                params: method.realDartMethodParams,
                returnType: method.returnType,
              ));
              ret.add(EmptyLine());
            }

            ret.add(DartFunction(
                depth: depth + 1,
                functionName: 'setup',
                isStatic: true,
                params: [Variable(AstCustomType(module.name), 'impl')],
                body: (depth) {
                  final funcBody = <CodeUnit>[];
                  for (final method in module.methods) {
                    funcBody.add(OneLine(depth: depth + 1, body: '{'));
                    funcBody.add(OneLine(
                        depth: depth + 2,
                        body: kEnableNullSafety
                            ? "const BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>('${makeChannelName(module, method)}', StandardMessageCodec());"
                            : "const BasicMessageChannel<Object> channel = BasicMessageChannel<Object>('${makeChannelName(module, method)}', StandardMessageCodec());"));

                    funcBody.add(OneLine(
                        depth: depth + 2,
                        body: kEnableNullSafety
                            ? 'channel.setMessageHandler((Object? message) async {'
                            : 'channel.setMessageHandler((Object message) async {'));
                    funcBody.add(OneLine(
                        depth: depth + 3,
                        body: 'if (message == null) return null;'));
                    funcBody.add(OneLine(
                        depth: depth + 3,
                        body: kEnableNullSafety
                            ? 'Map<Object?, Object?> wrapped = message as Map<Object?, Object?>;'
                            : 'Map<Object, Object> wrapped = message as Map<Object, Object>;'));
                    final methodArgs = <String>[];
                    for (final param in method.realDartMethodParams) {
                      methodArgs.add(
                          '${param.type.realType().convertDartJson2Obj(vname: "wrapped['${param.name}']")}');
                    }
                    final call =
                        '${method.isAsync ? 'await ' : ''}impl.${method.name}(${methodArgs.join(', ')})';
                    if (method.returnType.realType() is AstVoid) {
                      funcBody.add(OneLine(depth: depth + 3, body: '$call;'));
                    } else {
                      funcBody.add(OneLine(
                          depth: depth + 3, body: 'var implResult = $call;'));
                      if (method.returnType.maybeNull) {
                        funcBody.add(OneLine(
                            depth: depth + 3,
                            body: 'if (implResult == null ) return null;'));
                      }
                      funcBody.add(OneLine(
                          depth: depth + 3,
                          body:
                              'return ${method.returnType.realType().convertDartObj2Json('implResult')};'));
                    }
                    funcBody.add(OneLine(depth: depth + 2, body: '});'));
                    funcBody.add(OneLine(depth: depth + 1, body: '}'));
                  }

                  return funcBody;
                }));

            return ret;
          })
    ]).build();
  }

  /// 在 FlutterModule 中，在生成的方法中，需要对方法签名进行修改
  /// 如果接口中方法有返回值，需要改成无返回值方法，并在参数中添加一个
  /// UniCompleted Block 用于结果异步返回
  static Method _transformFlutterModuleMethod(Method method) {
    final methodCopy = Method.copy(method);
    if (methodCopy.hasMessagerAnno) {
      methodCopy.lastArgument?.type = AstCustomType.copy(
        methodCopy.lastArgument?.type as AstCustomType,
        generics: [AstCustomType(TypeBinaryMessengerInIOS)],
      )..type = 'id';
    }

    if (method.returnType is AstVoid) {
      return methodCopy;
    }

    final parameters = [...methodCopy.parameters];
    parameters.add(Variable(AstCustomType('UniCompleted'), 'result'));

    methodCopy.parameters = parameters;
    methodCopy.returnType = const AstVoid();

    return methodCopy;
  }
}
