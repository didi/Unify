import 'package:path/path.dart';
import 'package:unify_flutter/analyzer/analyzer_lib.dart';
import 'package:unify_flutter/ast/uniapi/ast_model.dart';
import 'package:unify_flutter/generator/callback_dispatcher.dart';
import 'package:unify_flutter/generator/common.dart';
import 'package:unify_flutter/utils/constants.dart';
import 'package:unify_flutter/utils/extension/ast_extension.dart';
import 'package:unify_flutter/ast/basic/ast_custom.dart';
import 'package:unify_flutter/ast/basic/ast_lambda.dart';
import 'package:unify_flutter/ast/basic/ast_map.dart';
import 'package:unify_flutter/ast/basic/ast_string.dart';
import 'package:unify_flutter/ast/basic/ast_variable.dart';
import 'package:unify_flutter/ast/basic/ast_void.dart';
import 'package:unify_flutter/ast/uniapi/ast_method.dart';
import 'package:unify_flutter/ast/uniapi/ast_module.dart';
import 'package:unify_flutter/cli/options.dart';
import 'package:unify_flutter/generator/widgets/base/block.dart';
import 'package:unify_flutter/generator/widgets/base/comment.dart';
import 'package:unify_flutter/generator/widgets/base/condition.dart';
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
import 'package:unify_flutter/generator/widgets/lang/oc/oc_reference.dart';
import 'package:unify_flutter/utils/extension/codeunit_extension.dart';
import 'package:unify_flutter/utils/extension/string_extension.dart';
import 'package:unify_flutter/utils/template_internal/dart/uni_callback_manager.dart';
import 'package:unify_flutter/utils/utils.dart';

// Fixme 用 Delegate 抽走
abstract class ModuleGenerator {
  static String javaCode(Module module, UniAPIOptions options) {
    registerCustomType('BinaryMessenger');

    List<CodeUnit> parseMethodParamUniCallbacks(Method method, int depth) {
      final ret = <CodeUnit>[];
      for (final param in method.parameters) {
        if (param.type.astType() == typeUniCallback) {
          ret.add(JavaClassUniCallback(
              method.name, param.name, param.type.generics[0],
              depth: depth, javaUniAPIPrefix: options.javaUniAPIPrefix));
        }
      }

      return ret;
    }

    return CodeTemplate(children: [
      CommentUniAPI(),
      EmptyLine(),
      JavaPackage(module.inputFile, options),
      EmptyLine(),
      JavaImport(fullClassName: 'java.util.List'),
      JavaImport(fullClassName: 'java.util.Map'),
      JavaImport(fullClassName: 'java.util.HashMap'),
      JavaImport(fullClassName: 'io.flutter.plugin.common.BinaryMessenger'),
      JavaImport(fullClassName: 'io.flutter.plugin.common.BasicMessageChannel'),
      JavaImport(
          fullClassName: 'io.flutter.plugin.common.StandardMessageCodec'),
      JavaCustomNestedImports(module.inputFile, options,
          methods: module.methods, excludeImports: [typeUniCallback]),
      if (hasUniCallback(module.methods)) ...[
        JavaImport(
            fullClassName:
                '${options.javaPackageName}.${options.objcUniAPIPrefix}$typeUniCallback'),
        JavaImport(
            fullClassName:
                '${options.javaPackageName}.${options.objcUniAPIPrefix}$typeUniCallbackDispose')
      ],
      EmptyLine(),
      Comment(
          comments: [uniNativeModuleDesc, ...module.codeComments],
          commentType: CommentType.commentBlock),
      JavaClass(
          className: module.name,
          isPublic: true,
          isInterface: true,
          parentClass: hasUniCallback(module.methods)
              ? '${options.objcUniAPIPrefix}$typeUniCallbackDispose'
              : null,
          injectedJavaCodes: (depth) => [
                if (module.methods.map((e) => e.isAsync).contains(true))
                  JavaClassAsyncResult(depth: depth),
                EmptyLine(),
                for (var method in module.methods)
                  ...parseMethodParamUniCallbacks(method, depth),
              ],
          methods: module.methods.map((method) {
            // 不能污染原来的 Method
            final methodCopy = Method.copy(method);
            final params = <Variable>[];
            for (final param in method.parameters) {
              if (param.type.astType() != typeUniCallback) {
                params.add(param);
              } else {
                registerCustomType(
                    JavaClassUniCallback.getName(method.name, param.name));
                params.add(Variable(
                    AstCustomType(
                        JavaClassUniCallback.getName(method.name, param.name)),
                    param.name));
              }
            }
            if (method.isAsync) {
              registerCustomType('Result');
              params.add(Variable(
                  AstCustomType('Result',
                      generics: [method.returnType.realType()]),
                  'result'));
            }
            methodCopy.parameters = params;

            if (methodCopy.isAsync) {
              methodCopy.returnType = const AstVoid();
            }
            return methodCopy;
          }).toList())
    ]).build();
  }

  static String javaRegisterCode(Module module, UniAPIOptions options) {
    return CodeTemplate(children: [
      CommentUniAPI(),
      EmptyLine(),
      JavaPackage(module.inputFile, options),
      EmptyLine(),
      JavaImport(fullClassName: 'java.util.List'),
      JavaImport(fullClassName: 'java.util.ArrayList'),
      JavaImport(fullClassName: 'java.util.Map'),
      JavaImport(fullClassName: 'java.util.HashMap'),
      JavaImport(fullClassName: 'android.util.Log'),
      JavaImport(fullClassName: 'io.flutter.plugin.common.BasicMessageChannel'),
      JavaImport(fullClassName: 'io.flutter.plugin.common.BinaryMessenger'),
      JavaImport(
          fullClassName: 'io.flutter.plugin.common.StandardMessageCodec'),
      JavaImport(
          fullClassName:
              '${options.javaPackageName}.${options.javaUniAPIPrefix}$kUniAPI'),
      JavaImport(
          fullClassName:
              'static ${options.javaPackageName}.$projectName.UniModel.map'),
      if (hasUniCallback(module.methods)) ...[
        EmptyLine(),
        JavaImport(
            fullClassName:
                '${options.javaPackageName}.${CallbackDispatcherGenerator.className(options)}')
      ],
      JavaCustomNestedImports(module.inputFile, options,
          methods: module.methods, excludeImports: [typeUniCallback]),
      EmptyLine(),
      JavaClass(
          className: '${module.name}Register',
          isPublic: true,
          injectedJavaCodes: (depth) => [
                ...JavaCollectionCloneFunction()
                    .handlerJavaCollectionType(methods: module.methods),
                JavaFunction(
                    depth: depth,
                    functionName: 'setup',
                    isPublic: true,
                    params: [
                      Variable(
                          AstCustomType('BinaryMessenger'), 'binaryMessenger'),
                      Variable(AstCustomType(module.name), 'impl')
                    ],
                    isStatic: true,
                    body: (depth) => [
                      OneLine(
                              depth: depth + 1,
                              body: '${options.javaUniAPIPrefix}$kUniAPI.init(binaryMessenger);'),
                      ...module.methods
                        .where((method) => method.name != module.name)
                        .map((method) => ScopeBlock(
                            depth: depth + 1,
                            body: (depth) => [
                                  OneLine(
                                      depth: depth,
                                      body:
                                          'BasicMessageChannel<Object> channel ='),
                                  OneLine(
                                      depth: depth + 2,
                                      body:
                                          'new BasicMessageChannel<>(binaryMessenger, "${_getModuleRegisterChannelName(module, method)}", new StandardMessageCodec());'),
                                  IfBlock(
                                      OneLine(
                                          body: 'impl != null',
                                          hasNewline: false), (depth) {
                                    final ret = <CodeUnit>[];
                                    ret.add(OneLine(
                                        depth: depth,
                                        body:
                                            '${options.javaUniAPIPrefix}$kUniAPI.registerModule(impl);'));
                                    ret.add(OneLine(
                                        depth: depth,
                                        body:
                                            'channel.setMessageHandler((message, reply) -> {'));
                                    ret.add(OneLine(
                                        depth: depth + 1,
                                        body:
                                            'Map<String, Object> wrapped = new HashMap<>();'));
                                    ret.add(OneLine(
                                        depth: depth + 1, body: 'try {'));
                                    ret.add(OneLine(
                                        depth: depth + 2,
                                        body:
                                            'Map<String, Object> params = (Map<String, Object>) message;'));

                                    // 将 Channel 调用传过来的数据转换成方法调用参数
                                    // 常规参数解析
                                    for (final param in method.parameters) {
                                      if (param.type.astType() ==
                                          typeUniCallback) {
                                        ret.add(OneLine(
                                                  depth: depth + 2,
                                                  body:
                                                      'String callbackName = (String) params.get("${param.name}");'));
                                        // 这里第二个参数，取出的是对应 Callback 的唯一名称，这个从 Native 带到 Dart 再带回来
                                        final callbackClassName =
                                            '${module.name}.${JavaClassUniCallback.getName(method.name, param.name)}';
                                        ret.add(OneLine(
                                            depth: depth + 2,
                                            body:
                                                '$callbackClassName ${param.name} = new ${module.name}.${JavaClassUniCallback.getName(method.name, param.name)}(binaryMessenger, callbackName, impl);'));
                                        ret.add(OneLine(
                                                  depth: depth + 2,
                                                  body:
                                                      '${options.objcUniAPIPrefix}$typeCallbackDispatcher.registerCallback(callbackName, ${param.name});'));
                                      } else {
                                        final decoded = param.type
                                            .convertJavaJson2Obj(
                                                vname:
                                                    'params.get("${param.name}")');
                                        ret.add(OneLine(
                                            depth: depth + 2,
                                            body:
                                                '${param.type.javaType()} ${param.name} = params.containsKey("${param.name}") ? $decoded;'));
                                      }
                                    }

                                    // 生成实际方法调用
                                    var paramsList = method.parameters
                                        .map((e) => e.name)
                                        .toList()
                                        .join(', ');
                                    if (!method.isAsync) {
                                      final call = OneLine(
                                          depth: depth + 2,
                                          body:
                                              'impl.${method.name}($paramsList);');

                                      if (method.returnType is AstVoid) {
                                        ret.add(call);
                                      } else {
                                        ret.add(OneLine(
                                            depth: depth + 2,
                                            body:
                                                '${method.returnType.javaType()} output = ${OneLine(body: call.body).build().replaceAll('\n', '')}'));
                                      }
                                      final isCustomType = method.returnType
                                          .realType() is AstCustomType;

                                      // != null 表达式
                                      final neqNullExp = isCustomType
                                          ? 'output != null ? '
                                          : '';

                                      // null 表达式
                                      final nullExp =
                                          isCustomType ? ' : null' : '';
                                      ret.add(OneLine(
                                          depth: depth + 2,
                                          body:
                                              'wrapped.put("${Keys.result}", $neqNullExp${method.returnType.realType().convertJavaObj2Json('output')}$nullExp);'));
                                    } else {
                                      final retValue = method.returnType
                                          .realType()
                                          .convertJavaObj2Json('ret');
                                      paramsList +=
                                          '${paramsList.isNotEmpty ? ', ' : ''}(ret) -> {';

                                      ret.add(OneLine(
                                          depth: depth + 2,
                                          body:
                                              'impl.${method.name}($paramsList'));

                                      //构造 try{} catch{}
                                      ret.add(OneLine(
                                          depth: depth + 3, body: 'try {'));
                                      ret.add(OneLine(
                                          depth: depth + 4,
                                          body: 'if (ret == null) {'));
                                      ret.add(OneLine(
                                          depth: depth + 5,
                                          body:
                                          'wrapped.put("result", null);'));
                                      ret.add(OneLine(
                                          depth: depth + 4,
                                          body: '} else {'));
                                      ret.add(OneLine(
                                          depth: depth + 5,
                                          body:
                                              'wrapped.put("result", $retValue);'));
                                      ret.add(OneLine(
                                          depth: depth + 4,
                                          body: '}'));
                                      ret.add(OneLine(
                                          depth: depth + 4,
                                          body: 'reply.reply(wrapped);'));
                                      ret.addAll(_buildJavaCatchErrorTemplate(
                                          isAsync: method.isAsync,
                                          ignoreError: method.ignoreError,
                                          baseDepth: depth + 2));
                                    }

                                    ret.addAll(_buildJavaCatchErrorTemplate(
                                        isAsync: method.isAsync,
                                        ignoreError: method.ignoreError,
                                        baseDepth: depth));

                                    return ret;
                                  },
                                      elseContent: (depth) => [
                                            OneLine(
                                                depth: depth,
                                                body:
                                                    'channel.setMessageHandler((message, reply) -> {});')
                                          ],
                                      depth: depth)
                                ]))
                        .toList()]),
                EmptyLine(),
                JavaFunction(
                    depth: depth,
                    functionName: 'wrapError',
                    isPrivate: true,
                    isStatic: true,
                    params: [Variable(AstCustomType('Throwable'), 'exception')],
                    returnType: AstMap(keyType: AstString()),
                    body: (depth) => [
                          OneLine(
                              depth: depth + 1,
                              body:
                                  'Map<String, Object> errorMap = new HashMap<>();'),
                          OneLine(
                              depth: depth + 1,
                              body:
                                  'errorMap.put("message", exception.toString());'),
                          OneLine(
                              depth: depth + 1,
                              body:
                                  'errorMap.put("code", exception.getClass().getSimpleName());'),
                          OneLine(
                              depth: depth + 1,
                              body: 'errorMap.put("details", null);'),
                          OneLine(depth: depth + 1, body: 'return errorMap;'),
                        ])
              ])
    ]).build();
  }

  // 生成 Java 语言 catch 部分的 body 代码模板
  static List<OneLine> _buildJavaCatchErrorTemplate(
      {bool isAsync = false, bool ignoreError = false, int baseDepth = 0}) {
    var ret = <OneLine>[];
    ret.add(OneLine(
        depth: baseDepth + 1,
        body: '} catch (Error | RuntimeException exception) {'));
    if (!ignoreError) {
      ret.add(OneLine(
          depth: baseDepth + 2,
          body: 'wrapped.put("${Keys.error}", wrapError(exception));'));
      if (isAsync) {
        ret.add(OneLine(depth: baseDepth + 2, body: 'reply.reply(wrapped);'));
      }
    } else {
      ret.add(OneLine(depth: baseDepth + 2, body: '//ignore errors'));
    }

    ret.add(OneLine(
        depth: baseDepth + 2,
        body: 'Log.d("flutter", "error: " + exception);'));

    if (isAsync) {
      ret.add(OneLine(depth: baseDepth + 1, body: '}'));
    } else {
      ret.add(OneLine(depth: baseDepth + 1, body: '} finally {'));

      ret.add(OneLine(depth: baseDepth + 2, body: 'reply.reply(wrapped);'));

      ret.add(OneLine(depth: baseDepth + 1, body: '}'));
    }
    ret.add(OneLine(depth: baseDepth, body: '});'));

    return ret;
  }

  static String _getModuleRegisterChannelName(Module module, Method method) =>
      '$channelPrefix.${module.name}.${method.name}';

  // 获取setUp函数的参数变量列表
  static List<Variable> getSetupFuncParams(String protocolName) => [
        Variable(
            AstCustomType('id',
                generics: [AstCustomType('FlutterBinaryMessenger')]),
            'binaryMessenger'),
        Variable(AstCustomType('id', generics: [AstCustomType(protocolName)]),
            'api') // fixme 缺少 _Nullable
      ];

  static String ocHeader(Module module, UniAPIOptions options) {
    registerCustomType(module.name);
    return CodeTemplate(children: [
      CommentUniAPI(),
      EmptyLine(),
      OCImport(fullImportName: 'Foundation/Foundation.h'),
      if (hasUniCallback(module.methods))
        OCImport(
            fullImportName:
                CallbackDispatcherGenerator.genOcHeaderFileName(options),
            importType: ocImportTypeLocal),
      EmptyLine(),
      OCForwardDeclaration(
          className: 'FlutterBinaryMessenger', isProtocol: true),
      OCForwardDeclaration(className: typeFlutterError, isClass: true),
      OCCustomNestedImports(module.inputFile, options,
          methods: module.methods,
          excludeImports: [typeUniCallback],
          isForwardDeclaration: true),
      EmptyLine(),
      OneLine(body: 'NS_ASSUME_NONNULL_BEGIN'),
      EmptyLine(),
      ...OCClassUniCallback.genPublicDeclarations(module.methods, options: options),
      Comment(
          comments: [uniNativeModuleDesc, ...module.codeComments],
          commentType: CommentType.commentBlock),
      OCClassDeclaration(
          className: module.name,
          isProtocol: true,
          parentClass: hasUniCallback(module.methods)
              ? CallbackDispatcherGenerator.disposeProtocolName(options)
              : '',
          instanceMethods: module.methods.map((method) {
            // 不能污染原来的 Method
            final methodCopy = Method.copy(method);
            final params = <Variable>[];
            // 处理 UniCallback
            for (final param in method.parameters) {
              if (param.type.astType() != typeUniCallback) {
                params.add(param);
              } else {
                // 改成 OC 形式
                registerCustomType(
                    OCClassUniCallback.getName(method.name, param.name));
                params.add(Variable(
                    AstCustomType(
                        OCClassUniCallback.getName(method.name, param.name)),
                    param.name));
              }
            }
            // 处理异步方法
            if (method.isAsync) {
              // 参数处理
              final blockType = AstLambda([
                Variable(method.returnType.realType(),
                    method.returnType.realType() is AstVoid ? '' : Keys.result)
              ], const AstVoid(), declaration: true);
              registerCustomType(blockType.astType());

              params.add(Variable(blockType, 'success'));

              // 处理异步 Ignore Error
              if (method.ignoreError == false) {
                final ignoreErrorBlock = AstLambda([
                  Variable(AstCustomType(typeFlutterError), Keys.error)
                ], const AstVoid(), declaration: true);
                registerCustomType(ignoreErrorBlock.astType());
                registerCustomType(typeFlutterError);

                params.add(Variable(ignoreErrorBlock, 'fail'));
              }

              // 处理 异步返回值
              methodCopy.returnType = const AstVoid();
            } else {
              // 处理同步 ignore error
              if (method.ignoreError == false) {
                params.add(Variable(
                    AstCustomType('FlutterError *_Nullable *_Nonnull',
                        keepRaw: true),
                    Keys.error));
              }
            }
            methodCopy.parameters = params;

            return methodCopy;
          }).toList()),
      EmptyLine(),
      OCFunction(
          functionName: '${module.name}Setup',
          isCFlavor: true,
          isDeclaration: true,
          isExternal: true,
          params: getSetupFuncParams(module.name)),
      EmptyLine(),
      OneLine(body: 'NS_ASSUME_NONNULL_END')
    ]).build();
  }

  static String ocSource(Module module, UniAPIOptions options) {
    return CodeTemplate(children: [
      CommentUniAPI(),
      EmptyLine(),
      OCImport(
          fullImportName: '${module.inputFile.pascalName}.h',
          importType: ocImportTypeLocal),
      OCImport(fullImportName: 'Flutter/Flutter.h'),
      EmptyLine(),
      OCCustomNestedImports(module.inputFile, options,
          excludeImports: [typeUniCallback], methods: module.methods),
      EmptyLine(),
      ...OCClassUniCallback.genImplementationDeclarations(module.methods),
      EmptyLine(),
      ...OCClassUniCallback.genImplementationImplementation(module.methods,
          options: options),
      EmptyLine(),
      ...OCCollectionCloneFunction(methods: module.methods)
          .genCollectionFunction(),
      OCPredefinedFuncWrapResult(),
      EmptyLine(),
      OCFunction(
          functionName: '${module.name}Setup',
          isCFlavor: true,
          params: getSetupFuncParams(module.name),
          body: (depth) {
            final ret = <CodeUnit>[];

            for (final method in module.methods) {
              if (method.name == module.name) {
                continue;
              }

              ret.add(ScopeBlock(
                  depth: depth + 1,
                  body: (depth) {
                    final blockRet = <CodeUnit>[];
                    blockRet.add(OneLine(
                        depth: depth,
                        body: 'FlutterBasicMessageChannel *channel ='));
                    blockRet.add(OneLine(
                        depth: depth + 1, body: '[FlutterBasicMessageChannel'));
                    blockRet.add(OneLine(
                        depth: depth + 2,
                        body:
                            'messageChannelWithName:@"${makeChannelName(module, method)}"'));
                    blockRet.add(OneLine(
                        depth: depth + 2,
                        body: 'binaryMessenger:binaryMessenger];'));
                    blockRet.add(OneLine(depth: depth, body: 'if (api) {'));
                    blockRet.add(OneLine(
                        depth: depth + 1,
                        body:
                            '[channel setMessageHandler:^(id _Nullable message, FlutterReply reply) {'));
                    for (final param in method.parameters) {
                      final type = param.type.realType();
                      final name = param.name;

                      if (param.type.astType() == typeUniCallback) {
                        blockRet.add(OneLine(
                            depth: depth + 2,
                            body:
                                'NSString *${name}Name = [message objectForKey:@"$name"];'));
                        final className =
                            OCClassUniCallback.getName(method.name, name);
                        blockRet.add(OneLine(
                            depth: depth + 2,
                            body: '$className *$name = $className.new;'));
                        blockRet.add(OneLine(
                            depth: depth + 2,
                            body: '$name.callbackName = ${name}Name;'));
                        blockRet.add(OneLine(
                            depth: depth + 2,
                            body: '$name.binaryMessenger = binaryMessenger;'));
                        blockRet.add(OneLine(
                            depth: depth + 2,
                            body:
                                '[${CallbackDispatcherGenerator.className(options)} registe:${name}Name callback:$name];'));
                      } else if (type != const AstVoid()) {
                        final decoded = type.convertOcJson2Obj(
                            vname: '[message objectForKey:@"$name"]');
                        blockRet.add(OneLine(
                            depth: depth + 2,
                            body:
                                '${OCReference(type).build()} $name = $decoded;'));
                      }
                    }

                    if (method.isAsync == true) {
                      final result = method.returnType.realType() is AstVoid
                          ? ''
                          : 'result';
                      final paramList = <OCFunctionCallRealParam>[];
                      paramList.addAll(method.parameters.map((param) =>
                          OCFunctionCallRealParam(param.name, param.name)));
                      paramList.add(OCFunctionCallRealParam(
                          'success',
                          AstLambda(
                              [Variable(method.returnType.realType(), result)],
                              const AstVoid(),
                              depth: depth + 2,
                              injectedOCCodes: (depth) => [
                                    OneLine(
                                        depth: depth,
                                        body:
                                            'reply(wrapResult(${method.returnType.realType().convertOcObj2Json('result')},nil));')
                                  ]).ocType()));
                      if (method.ignoreError == false) {
                        paramList.add(OCFunctionCallRealParam(
                            'fail',
                            AstLambda([
                              Variable(AstCustomType(typeFlutterError), 'error')
                            ], const AstVoid(),
                                depth: depth + 2,
                                injectedOCCodes: (depth) => [
                                      OneLine(
                                          depth: depth,
                                          body: 'reply(wrapResult(nil,error));')
                                    ]).ocType()));
                      }
                      blockRet.add(OCFunctionCall(
                          depth: depth + 2,
                          instanceName: 'api',
                          functionName: method.name,
                          params: paramList));
                    } else {
                      blockRet.add(OneLine(
                          depth: depth + 2, body: 'FlutterError *error;'));

                      final paramList = <OCFunctionCallRealParam>[];
                      paramList.addAll(method.parameters.map((param) =>
                          OCFunctionCallRealParam(param.name, param.name)));
                      if (method.ignoreError == false) {
                        paramList
                            .add(OCFunctionCallRealParam('error', '&error'));
                      }
                      if (method.returnType is! AstVoid) {
                        blockRet.add(OneLine(
                            depth: depth + 2,
                            hasNewline: false,
                            body:
                                '${OCReference(method.returnType).build()} output = '));
                      }
                      blockRet.add(OCFunctionCall(
                          depth: (method.returnType is AstVoid) == true
                              ? depth + 2
                              : 0,
                          instanceName: 'api',
                          functionName: method.name,
                          ignoreError: true,
                          params: paramList));
                      blockRet.add(OneLine(
                          depth: depth + 2,
                          body:
                              'reply(wrapResult(${method.returnType.convertOcObj2Json('output')}, error));'));
                    }

                    blockRet.add(OneLine(depth: depth + 1, body: '}];'));
                    blockRet.add(OneLine(depth: depth, body: '} else {'));
                    blockRet.add(OneLine(
                        depth: depth + 1,
                        body: '[channel setMessageHandler:nil];'));
                    blockRet.add(OneLine(depth: depth, body: '}'));

                    return blockRet;
                  }));
            }

            return ret;
          })
    ]).build();
  }

  static String productPath(String outPath, String inputFilePath) {
    String newPath;
    if (outPath.endsWith('/') == false &&
        inputFilePath.startsWith('/') == false) {
      newPath = '$outPath/$inputFilePath';
    } else if (outPath.endsWith('/') == true &&
        inputFilePath.startsWith('/') == true) {
      newPath = (outPath + inputFilePath).replaceAll('//', '/');
    } else {
      newPath = outPath + inputFilePath;
    }
    return newPath;
  }

  static String dartCode(Module module, UniAPIOptions options) {
    final moduleHasCallback = hasUniCallback(module.methods);
    return CodeTemplate(children: [
      CommentUniAPI(),
      EmptyLine(),
      DartImport(fullClassName: 'dart:async'),
      DartImport(fullClassName: 'package:flutter/services.dart'),
      if (moduleHasCallback) ...[
        DartImport(
            fullClassName: relative(
                '${options.dartOutput}/$projectName/$dotDartFileUniCallback',
                from: dirname(
                    productPath(options.dartOutput, module.inputFile.path)))),
        DartImport(
            fullClassName: relative(
                '${options.dartOutput}/$projectName/$dotDartFileUniCallbackManager',
                from: dirname(
                    productPath(options.dartOutput, module.inputFile.path)))),
        DartImport(
            fullClassName: relative(
                '${options.dartOutput}/$projectName/$dotDartFileCaches',
                from: dirname(
                    productPath(options.dartOutput, module.inputFile.path)))),
      ],
      DartImport(fullClassName: 'package:flutter/foundation.dart'),
      DartImport(
          fullClassName: relative(
              '${options.dartOutput}/$projectName/$dotDartFileprojectNameSnake',
              from: dirname(
                  productPath(options.dartOutput, module.inputFile.path)))),
      EmptyLine(),
      DartCustomNestedImports(module.inputFile, options,
          methods: module.methods, excludeImports: [typeUniCallback]),
      EmptyLine(),
      Comment(
          comments: [uniNativeModuleDesc, ...module.codeComments],
          commentType: CommentType.commentTripleBackSlash),
      DartClass(
          className: module.name,
          methods: module.methods,
          injectedJavaCodes: (depth) {
            String generateCallbackName(
                    Module module, Method method, Variable param) =>
                '${module.name}_${method.name}_${param.name}';

            String channelName(Module module, Method method) =>
                '$channelPrefix.${module.name}.${method.name}';

            final ret = <CodeUnit>[];
            for (final method in module.methods) {
              if (method.name == module.name) {
                continue;
              }

              // 生成 UniNativeModule 接口方法
              ret.add(DartFunction(
                  depth: depth + 1,
                  functionName: method.name,
                  params: method.parameters,
                  isAsync: true,
                  isStatic: true,
                  returnType: AstCustomType(typeFuture, generics: [
                    method.returnType.realType()
                  ], genericsMaybeNull: [
                    method.returnType.realType() is! AstVoid
                  ]),
                  body: (depth) {
                    final funcBody = <CodeUnit>[];
                    final callbackParams = method.parameters
                        .where(
                            (param) => param.type.astType() == typeUniCallback)
                        .toList();
                    String? callbackName;
                    String? callbackInstance;

                    if (callbackParams.isNotEmpty) {
                      final callback = callbackParams.first;
                      callbackName =
                          generateCallbackName(module, method, callback);
                      callbackInstance =
                          '${callbackName}_\${${callback.name}.hashCode}';
                      funcBody.add(OneLine(
                          depth: depth + 1,
                          body:
                              "${callback.name}.callbackName = '$callbackInstance';"));
                      funcBody.add(OneLine(
                          depth: depth + 1,
                          body:
                              "uniCallbackCache['$callbackInstance'] = ${callback.name};"));
                    }

                    if (method.parameters.isNotEmpty) {
                      funcBody.add(OneLine(
                          depth: depth + 1,
                          body: 'final Map<String, dynamic> encoded = {};'));
                    }
                    for (final param in method.parameters) {
                      if (param.type.astType() == typeUniCallback) {
                        assert(callbackName != null);
                        assert(callbackInstance != null);
                        funcBody.add(OneLine(
                            depth: depth + 1,
                            body:
                                'encoded["${param.name}"] = \'$callbackInstance\';'));
                      } else {
                        final isNullable = param.type.maybeNull;
                        funcBody.add(OneLine(
                            depth: depth + 1,
                            body:
                                '${isNullable ? 'if (${param.name} != null) ' : ''}encoded["${param.name}"] = ${param.type.convertDartObj2Json(param.name)};'));
                      }
                    }

                    funcBody.add(OneLine(
                        depth: depth + 1,
                        body: kEnableNullSafety
                            ? 'const BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?> ('
                            : 'const BasicMessageChannel<Object> channel = BasicMessageChannel<Object> ('));
                    funcBody.add(OneLine(
                        depth: depth + 2,
                        body:
                            "'${channelName(module, method)}', StandardMessageCodec());"));
                    if (callbackParams.isNotEmpty) {
                      funcBody.add(OneLine(
                          depth: depth + 1,
                          body: 'UniCallbackManager.getInstance();'));
                    }
                    funcBody.add(OneLine(
                        depth: depth + 1,
                        body: kEnableNullSafety
                            ? 'final Map<Object?, Object?>? replyMap ='
                            : 'final Map<Object, Object> replyMap ='));
                    if (method.parameters.isEmpty) {
                      funcBody.add(OneLine(
                          depth: depth + 2,
                          body: kEnableNullSafety
                              ? 'await channel.send(null) as Map<Object?, Object?>?;'
                              : 'await channel.send(null) as Map<Object, Object>;'));
                    } else {
                      funcBody.add(OneLine(
                          depth: depth + 2,
                          body: kEnableNullSafety
                              ? 'await channel.send(encoded) as Map<Object?, Object?>?;'
                              : 'await channel.send(encoded) as Map<Object, Object>;'));
                    }

                    String connectChannelError() =>
                        'Unable to establish connection on channel : "${channelName(module, method)}" .';
                    String trackErrorExpression(String msg) =>
                        "UniApi.trackError('${module.name}', '${channelName(module, method)}', '$msg');";
                    String ifErrorExpression(String msg) =>
                        "if (error.containsKey('$msg')) errorMsg += '[ \${error['$msg']?.toString() ?? ''} ]';";

                    funcBody.add(OneLine(
                        depth: depth + 1, body: 'if (replyMap == null) {'));
                    funcBody.add(OneLine(
                        depth: depth + 2,
                        body: trackErrorExpression(connectChannelError())));
                    funcBody.add(OneLine(
                        depth: depth + 2, body: 'if (!kReleaseMode) {'));
                    funcBody.add(OneLine(
                        depth: depth + 3, body: 'throw PlatformException('));
                    funcBody.add(OneLine(
                        depth: depth + 4, body: "code: 'channel-error',"));
                    funcBody.add(OneLine(
                        depth: depth + 4,
                        body: "message: '${connectChannelError()}',"));
                    funcBody
                        .add(OneLine(depth: depth + 4, body: 'details: null,'));
                    funcBody.add(OneLine(depth: depth + 3, body: ');'));
                    funcBody.add(OneLine(depth: depth + 2, body: '}'));
                    funcBody.add(OneLine(
                        depth: depth + 1,
                        body: "} else if (replyMap['error'] != null) {"));
                    funcBody.add(OneLine(
                        depth: depth + 2,
                        body: kEnableNullSafety
                            ? "final Map<Object?, Object?> error = (replyMap['${Keys.error}']  as Map<Object?, Object?>);"
                            : "final Map<Object, Object> error = (replyMap['${Keys.error}']  as Map<Object, Object>);"));
                    funcBody.add(OneLine(
                        depth: depth + 2, body: "String errorMsg = '';"));
                    funcBody.add(OneLine(
                        depth: depth + 2,
                        body: ifErrorExpression(Keys.errorCode)));
                    funcBody.add(OneLine(
                        depth: depth + 2,
                        body: ifErrorExpression(Keys.errorMessage)));
                    funcBody.add(OneLine(
                        depth: depth + 2,
                        body: ifErrorExpression(Keys.errorDetails)));
                    funcBody.add(OneLine(
                        depth: depth + 2,
                        body: trackErrorExpression(
                            '${method.name}: \$errorMsg);')));
                    funcBody.add(OneLine(
                        depth: depth + 2, body: 'if (!kReleaseMode) {'));
                    funcBody.add(OneLine(
                        depth: depth + 3, body: 'throw PlatformException('));
                    funcBody.add(OneLine(
                        depth: depth + 4,
                        body: "code: error['${Keys.errorCode}'] as String,"));
                    funcBody.add(OneLine(
                        depth: depth + 4,
                        body:
                            "message: error['${Keys.errorMessage}'] as String,"));
                    funcBody.add(OneLine(
                        depth: depth + 4,
                        body: "details: error['${Keys.errorDetails}'],"));
                    funcBody.add(OneLine(depth: depth + 3, body: ');'));
                    funcBody.add(OneLine(depth: depth + 2, body: '}'));
                    funcBody.add(OneLine(depth: depth + 1, body: '} else {'));

                    var ternaryOperatorExpr =
                        method.returnType.realType().maybeNull == true
                            ? '$replyPlaceholder == null ? null : '
                            : '';
                    funcBody.add(OneLine(
                        depth: depth + 2,
                        body:
                            '${method.returnType.realType() is AstVoid ? '' : 'return $ternaryOperatorExpr'}${method.returnType.realType().convertDartJson2Obj()};'));

                    funcBody.add(OneLine(depth: depth + 1, body: '}'));
                    if (method.returnType is! AstVoid) {
                      funcBody.add(OneLine(
                          depth: depth + 1,
                          body:
                              "throw Exception('方法 \"${method.name}\" : 返回类型错误!');"));
                    }
                    return funcBody;
                  }));
              ret.add(EmptyLine());
            }

            return ret;
          })
    ]).build();
  }

  static String dartCallbackManagerCode(UniAPIOptions options,
      {List<Model>? models}) {
    final imports = <CodeUnit>[];
    models?.forEach((model) {
      imports.add(DartImport(
          fullClassName: relative(
              productPath(options.dartOutput, model.inputFile.path),
              from: dirname(
                  '${options.dartOutput}/$projectName/$dotDartFileUniCallbackManager'))));
    });

    const generateDepth = 3;
    final generateList = <CodeUnit>[];
    generateList.add(OneLine(
        depth: generateDepth,
        body: 'if (callback.callbackName != callbackName) continue;'));
    generateList.add(OneLine(
        depth: generateDepth,
        body:
            'UniCallbackDisposable disposable = UniCallbackDisposable(callback);'));
    models?.forEach((model) {
      generateList.add(OneLine(
          depth: generateDepth,
          body: 'if (callback.getType() == ${model.name}) {'));
      generateList.add(OneLine(
          depth: generateDepth + 1,
          body:
              '(callback as UniCallback<${model.name}>).onEvent(${model.name}${model.dartDecodedFuncName(model.isEnum, 'data')}, disposable);'));
      generateList.add(OneLine(depth: generateDepth + 1, body: 'continue;'));
      generateList.add(OneLine(depth: generateDepth, body: '}'));
    });
    final generateListStr = CodeUnit.join(generateList);

    return CodeTemplate(children: [
      CommentUniAPI(),
      EmptyLine(),
      ...imports,
      EmptyLine(),
      OneLine(
          body: dartUniCallbackManagerContent(generateListStr,
              nullSafty: options.dartNullSafety,
              channelSuffix: options.objcUniAPIPrefix.suffix()))
    ]).build();
  }
}
