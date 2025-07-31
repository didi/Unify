import 'package:unify_flutter/analyzer/analyzer_lib.dart';
import 'package:unify_flutter/ast/base.dart';
import 'package:unify_flutter/ast/basic/ast_custom.dart';
import 'package:unify_flutter/ast/basic/ast_string.dart';
import 'package:unify_flutter/ast/basic/ast_variable.dart';
import 'package:unify_flutter/ast/basic/ast_void.dart';
import 'package:unify_flutter/ast/uniapi/ast_method.dart';
import 'package:unify_flutter/cli/options.dart';
import 'package:unify_flutter/generator/common.dart';
import 'package:unify_flutter/generator/widgets/base/comment.dart';
import 'package:unify_flutter/generator/widgets/base/condition.dart';
import 'package:unify_flutter/generator/widgets/base/line.dart';
import 'package:unify_flutter/generator/widgets/code_unit.dart';
import 'package:unify_flutter/generator/widgets/lang/java/java_class.dart';
import 'package:unify_flutter/generator/widgets/lang/oc/oc_function.dart';
import 'package:unify_flutter/generator/widgets/lang/oc/oc_property.dart';
import 'package:unify_flutter/utils/constants.dart';
import 'package:unify_flutter/utils/extension/string_extension.dart';

class OCClassDeclaration extends CodeUnit {
  OCClassDeclaration(
      {this.className = '',
      this.parentClass = '',
      this.properties = const [],
      this.isInterface = false,
      this.isProtocol = false,
      this.hasExtension = false,
      this.extensionName = '',
      this.instanceMethods = const [],
      this.classMethods = const [],
      int depth = 0})
      : super(depth);

  static const String keywordSpace = ' ';

  String className;
  String parentClass;
  bool isInterface;
  bool isProtocol;

  // 是否有类扩展
  bool hasExtension;
  // 类扩展名称
  String extensionName;

  // Variable
  List<Variable> properties;
  List<Method> instanceMethods;
  List<Method> classMethods;

  OneLine classSignature() {
    final sb = StringBuffer();

    if (isInterface) {
      sb.write('@interface');
    }
    if (isProtocol) {
      sb.write('@protocol');
    }
    sb.write(keywordSpace);
    sb.write(className);
    if (hasExtension) {
      sb.write(keywordSpace);
      sb.write('(');
      sb.write(extensionName);
      sb.write(')');
    }
    if (parentClass.isNotEmpty) {
      if (isProtocol) {
        sb.write('<');
        sb.write(parentClass);
        sb.write('>');
      } else {
        sb.write(' : ');
        sb.write(parentClass);
      }
    }

    return OneLine(depth: depth, body: sb.toString());
  }

  List<CodeUnit> classMethodInterfaces() {
    final result = <CodeUnit>[];
    for (final method in classMethods) {
      if (method.name == className) {
        continue;
      }

      result.add(OCFunction(
          isDeclaration: true,
          depth: depth,
          functionName: method.name,
          isClassMethod: true,
          returnType: method.returnType,
          params: method.parameters));
    }

    return result;
  }

  List<CodeUnit> ocFields() {
    return properties
        .map((e) => LineExpand(OCProperty(e),
            " //${e.codeComments.join(',')} Origin dart type is '${e.type.astType()}'"))
        .toList();
  }

  List<CodeUnit> instanceMethodInterfaces() {
    final result = <CodeUnit>[];

    for (final method in instanceMethods) {
      if (method.name == className) {
        continue;
      }

      if (method.codeComments.isNotEmpty) {
        result.add(Comment(
            comments: [...method.codeComments],
            commentType: CommentType.commentBlock));
      }

      result.add(OCFunction(
          isDeclaration: true,
          depth: depth,
          functionName: method.name,
          isInstanceMethod: true,
          returnType: method.returnType,
          params: method.parameters));
    }

    return result;
  }

  @override
  String build() {
    assert(isProtocol || isInterface);
    assert(!(isProtocol && isInterface));
    return CodeUnit.join([
      classSignature(),
      EmptyLine(),
      ...ocFields(),
      EmptyLine(),
      if (classMethods.isNotEmpty) ...[...classMethodInterfaces(), EmptyLine()],
      if (instanceMethods.isNotEmpty) ...[
        ...instanceMethodInterfaces(),
        EmptyLine()
      ],
      OneLine(depth: depth, body: '@end')
    ]);
  }
}

class OCClassImplementation extends CodeUnit {
  OCClassImplementation(
      {this.injectOCCodeUnit, this.className = '', int depth = 0})
      : super(depth);

  String className;
  InjectCodeUnit? injectOCCodeUnit;

  OneLine classSignature() {
    final sb = StringBuffer();

    sb.write('@implementation');
    sb.write(' ');
    sb.write(className);

    return OneLine(depth: depth, body: sb.toString());
  }

  @override
  String build() {
    return CodeUnit.join([
      classSignature(),
      EmptyLine(),
      if (injectOCCodeUnit != null) ...injectOCCodeUnit!(depth),
      EmptyLine(),
      OneLine(body: '@end')
    ]);
  }
}

class OCClassUniCallback {
  OCClassUniCallback(this.methodName, this.paramName,
      {this.paramGeneric = const AstVoid(),
      this.depth = 0,
      this.objcUniAPIPrefix = ''});

  String methodName;
  String paramName;
  String objcUniAPIPrefix;
  AstType paramGeneric;
  int depth;

  /// 生成 UniCallback 在头文件中的类声明
  OCClassDeclaration getPublicDeclaration() {
    return OCClassDeclaration(
        depth: depth,
        className: getName(methodName, paramName),
        parentClass: 'NSObject',
        isInterface: true,
        properties: [
          Variable(AstString(), Keys.callbackName),
          Variable(
              AstCustomType('id', generics: [
                AstCustomType('$objcUniAPIPrefix$typeUniCallbackDispose')
              ]),
              Keys.delegate)
        ],
        instanceMethods: [
          Method(
              name: 'onEvent',
              parameters: paramGeneric.realType() is AstVoid
                  ? const []
                  : [Variable(paramGeneric, 'callback')])
        ]);
  }

  /// 传入模块方法列表，生成头文件类声明列表
  static List<CodeUnit> genPublicDeclarations(List<Method> methods,
      {int depth = 0, UniAPIOptions? options}) {
    return _parseMethodGenCodes(
        methods, (uniCallback) => uniCallback.getPublicDeclaration(),
        options: options);
  }

  /// 生成 UniCallback 在实现文件中的私有类声明
  OCClassDeclaration getImplementationDeclaration() {
    registerCustomType('id');
    return OCClassDeclaration(
        depth: depth,
        className: getName(methodName, paramName),
        hasExtension: true,
        isInterface: true,
        properties: [
          Variable(
              AstCustomType('id',
                  generics: [AstCustomType(TypeBinaryMessengerInIOS)]),
              Keys.binaryMessenger)
        ]);
  }

  static List<CodeUnit> genImplementationDeclarations(List<Method> methods,
      {int depth = 0}) {
    return _parseMethodGenCodes(
        methods, (uniCallback) => uniCallback.getImplementationDeclaration());
  }

  /// 生成 UniCallback 在实现文件中的类实现
  OCClassImplementation getImplementationImplementation() {
    return OCClassImplementation(
        className: getName(methodName, paramName),
        injectOCCodeUnit: (depth) {
          return [
            OCFunction(
                functionName: 'onEvent',
                isInstanceMethod: true,
                params: paramGeneric.realType() is AstVoid
                    ? const []
                    : [Variable(paramGeneric, paramName)],
                body: (depth) {
                  final ret = <CodeUnit>[];
                  ret.add(Comment(depth: depth + 1, comments: ['参数判空检查']));
                  ret.add(IfBlock(
                      OneLine(body: '$paramName == NULL', hasNewline: false),
                      (d) => [OneLine(depth: d, body: 'return;')],
                      depth: depth + 1));
                  ret.add(OneLine(
                      depth: depth + 1,
                      body: 'FlutterBasicMessageChannel *channel ='));
                  ret.add(OneLine(
                      depth: depth + 2, body: '[FlutterBasicMessageChannel'));
                  ret.add(OneLine(
                      depth: depth + 3,
                      body:
                          'messageChannelWithName:@"$channelPrefix.UniCallbackManager.callback_channel${objcUniAPIPrefix.suffix()}"')); // fixme
                  ret.add(OneLine(
                      depth: depth + 3,
                      body: 'binaryMessenger:self.binaryMessenger];'));

                  if (paramGeneric.realType() is AstCustomType) {
                    ret.add(OneLine(
                        depth: depth + 1,
                        body:
                            'NSDictionary *msg = @{@"callbackName":self.callbackName,@"data":$paramName.toMap};'));
                  } else {
                    ret.add(OneLine(
                        depth: depth + 1,
                        body:
                            'NSDictionary *msg = @{@"callbackName":self.callbackName,@"data":$paramName};'));
                  }
                  ret.add(Comment(depth: depth + 1, comments: ['发送消息']));
                  ret.add(OneLine(
                      depth: depth + 1, body: '[channel sendMessage:msg];'));
                  return ret;
                })
          ];
        });
  }

  static List<CodeUnit> genImplementationImplementation(List<Method> methods,
      {int depth = 0, UniAPIOptions? options}) {
    return _parseMethodGenCodes(
        methods, (uniCallback) => uniCallback.getImplementationImplementation(),
        options: options);
  }

  static List<CodeUnit> _parseMethodGenCodes(List<Method> methods,
      CodeUnit Function(OCClassUniCallback uniCallback) mapper,
      {UniAPIOptions? options}) {
    final ret = <CodeUnit>[];
    for (final method in methods) {
      for (final param in method.parameters) {
        if (param.type.ocType() == typeUniCallback) {
          ret.add(mapper(OCClassUniCallback(method.name, param.name,
              paramGeneric: param.type.generics[0],
              objcUniAPIPrefix: options?.objcUniAPIPrefix ?? '')));
          ret.add(EmptyLine());
        }
      }
    }
    return ret;
  }

  static String getName(String methodName, String paramName) {
    return 'On${upperFirst(methodName)}${upperFirst(paramName)}';
  }

  static String upperFirst(String name) {
    return name[0].toUpperCase() + name.substring(1);
  }
}
