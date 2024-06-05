import 'package:unify_flutter/analyzer/analyzer_lib.dart';
import 'package:unify_flutter/generator/widgets/base/comment.dart';
import 'package:unify_flutter/generator/widgets/lang/java/java_constants.dart';
import 'package:unify_flutter/generator/widgets/lang/java/java_field.dart';
import 'package:unify_flutter/utils/constants.dart';
import 'package:unify_flutter/utils/extension/ast_extension.dart';
import 'package:unify_flutter/ast/base.dart';
import 'package:unify_flutter/ast/basic/ast_custom.dart';
import 'package:unify_flutter/ast/basic/ast_map.dart';
import 'package:unify_flutter/ast/basic/ast_string.dart';
import 'package:unify_flutter/ast/basic/ast_variable.dart';
import 'package:unify_flutter/ast/uniapi/ast_method.dart';
import 'package:unify_flutter/generator/common.dart';
import 'package:unify_flutter/generator/widgets/base/line.dart';
import 'package:unify_flutter/generator/widgets/code_unit.dart';
import 'package:unify_flutter/generator/widgets/lang/java/java_function.dart';

typedef InjectCodeUnit = List<CodeUnit> Function(int depth);

class JavaClass extends CodeUnit {
  JavaClass(
      {this.className = '',
      this.parentClass,
      this.generics = const [],
      this.publicFields = const [],
      this.privateFields = const [],
      this.fieldGettersAndSetters = const [],
      this.injectedJavaCodes,
      this.methods = const [],
      this.isPublic = false,
      this.isInterface = false,
      this.isStatic = false,
      this.hasToMap = false,
      this.hasFromMap = false,
      int depth = 0})
      : assert(className.isNotEmpty),
        super(depth);

  // 类名
  String className;
  // 是否有父类
  String? parentClass;
  // 类的范型
  List<String> generics;

  // 是否是公有类
  bool isPublic;

  // 是否是静态类
  bool isStatic;

  // 是否是接口
  bool isInterface;

  // 类私有属性列表
  List<Variable> privateFields;

  // 共有属性列表
  List<Variable> publicFields;

  // 有 Getter 和 Setter 的 Field 列表
  List<Variable> fieldGettersAndSetters;

  // 类接口方法
  List<Method> methods;

  // 外界注入的代码
  InjectCodeUnit? injectedJavaCodes;

  // Field 序列化 toMap
  bool hasToMap;
  // Field 序列化 fromMap;
  bool hasFromMap;

  OneLine classSignature() {
    final sb = StringBuffer();
    if (isPublic) {
      sb.write(keywordPublic + keywordSpace);
    }
    if (isStatic) {
      sb.write(keywordStatic + keywordSpace);
    }
    sb.write(isInterface ? keywordInterface : keywordClass);
    sb.write(keywordSpace);
    sb.write(className);
    if (generics.isNotEmpty) {
      sb.write('<${generics.join(', ')}>');
    }
    sb.write(keywordSpace);
    if (parentClass != null) {
      sb.write(keywordExtends + keywordSpace + parentClass! + keywordSpace);
    }
    sb.write(keywordBraceLeft);

    return OneLine(depth: depth, body: sb.toString());
  }

  List<CodeUnit> javaPrivateFields() {
    return privateFields
        .map((field) => JavaField(field, depth: depth + 1, isPrivate: true))
        .toList();
  }

  List<CodeUnit> javaPublicFields() {
    return publicFields
        .map((field) => JavaField(field, depth: depth + 1, isPublic: true))
        .toList();
  }

  List<CodeUnit> getterAndSetters() {
    final lines = <CodeUnit>[];
    for (final field in fieldGettersAndSetters) {
      lines.add(JavaFunctionGetter(field, depth: depth + 1));
      lines.add(EmptyLine());
      lines.add(JavaFunctionSetter(field, depth: depth + 1));
      lines.add(EmptyLine());
    }

    return lines;
  }

  JavaFunction toMapFunc() {
    return JavaFunction(
        functionName: 'toMap',
        returnType: AstMap(keyType: AstString()), // fixme 生成出来代码没有范性
        depth: depth + 1,
        isPublic: true,
        isOverride: true,
        body: (depth) => [
              OneLine(
                  depth: depth + 1,
                  body: Variable(AstMap(keyType: AstString()), 'result')
                      .javaDeclaration(newInstance: true)),
              ...privateFields.map((field) {
                return OneLine(
                    depth: depth + 1,
                    body:
                        '${(field.type.realType() is AstCustomType) ? 'if (${field.name} != null) ' : ''}result.put("${field.name}", ${field.type.realType().convertJavaObj2Json(field.name)});');
              }),
              OneLine(depth: depth + 1, body: 'return result;')
            ]);
  }

  JavaFunction fromMapFunc() {
    return JavaFunction(
        depth: depth + 1,
        functionName: 'fromMap',
        returnType: AstCustomType(className),
        isPublic: true,
        isStatic: true,
        params: [Variable(AstMap(keyType: AstString()), 'map')],
        body: (depth) => [
              OneLine(
                  depth: depth + 1,
                  body: Variable(AstCustomType(className), 'result')
                      .javaDeclaration(newInstance: true)),
              ...privateFields.map((field) {
                return OneLine(
                    depth: depth + 1,
                    body:
                        'result.${field.name} = map.containsKey("${field.name}") && map.get("${field.name}") != null ? ${field.type.realType().convertJavaJson2Obj(vname: 'map.get("${field.name}")', showGenerics: true)};');
              }),
              OneLine(depth: depth + 1, body: 'return result;')
            ]);
  }

  List<CodeUnit> methodsInterfaces() {
    final result = <CodeUnit>[];
    for (final method in methods) {
      // 跳过构造方法
      if (method.name == className) {
        continue;
      }

      if (method.codeComments.isNotEmpty) {
        result.add(Comment(
            depth: depth + 1,
            comments: [...method.codeComments],
            commentType: CommentType.commentBlock));
      }

      result.add(JavaFunction(
          depth: depth + 1,
          functionName: method.name,
          returnType: method.returnType,
          params: method.parameters,
          isAbstract: true));
      result.add(EmptyLine());
    }

    return result;
  }

  @override
  String build() {
    // 只有接口才能生成方法
    if (methods.isNotEmpty) {
      assert(isInterface);
    }

    return CodeUnit.join([
      classSignature(),
      if (publicFields.isNotEmpty) ...javaPublicFields(),
      if (privateFields.isNotEmpty) ...javaPrivateFields(),
      if (privateFields.isNotEmpty || privateFields.isNotEmpty) EmptyLine(),
      if (fieldGettersAndSetters.isNotEmpty) ...getterAndSetters(),
      if (fieldGettersAndSetters.isNotEmpty)
        EmptyLine(), // 提供一个新的插入空行的美化方法，几个 List 以分组形式传入，在里面插 EmptyLine 再返回一个新扁平 List
      if (hasToMap) toMapFunc(),
      if (hasToMap) EmptyLine(),
      if (hasFromMap) fromMapFunc(),
      if (injectedJavaCodes != null) EmptyLine(),
      if (injectedJavaCodes != null) ...injectedJavaCodes!(depth + 1),
      if (methods.isNotEmpty) ...methodsInterfaces(),
      OneLine(depth: depth, body: '}')
    ]);
  }
}

class JavaClassAsyncResult extends JavaClass {
  JavaClassAsyncResult({int depth = 0})
      : super(depth: depth, className: 'Result', isInterface: true, generics: [
          'T'
        ], methods: [
          Method(
              name: 'success',
              parameters: [Variable(AstCustomType('T'), 'result')])
        ]) {
    // 注册范型
    registerCustomType('T');
  }
}

class JavaClassUniCallback extends JavaClass {
  JavaClassUniCallback(
      String methodName, String paramName, AstType paramGeneric,
      {int depth = 0, String channelSuffix = ''})
      : super(
            depth: depth,
            className: getName(methodName, paramName),
            privateFields: [
              Variable(AstCustomType('BinaryMessenger'), 'messenger'),
            ],
            publicFields: [
              Variable(AstString(), 'callbackName'),
            ],
            injectedJavaCodes: (depth) => [
                  JavaFunction(
                      functionName: getName(methodName, paramName),
                      depth: depth,
                      isConstruct: true,
                      isPublic: true,
                      body: (depth) => [
                            OneLine(
                                depth: depth + 1,
                                body: 'this.messenger = messenger;'),
                            OneLine(
                                depth: depth + 1,
                                body: 'this.callbackName = callbackName;')
                          ],
                      params: [
                        Variable(AstCustomType('BinaryMessenger'), 'messenger'),
                        Variable(AstString(), 'callbackName')
                      ]),
                  EmptyLine(),
                  JavaFunction(
                      depth: depth,
                      functionName: 'onEvent',
                      isPublic: true,
                      params: [Variable(paramGeneric, 'event')],
                      body: (depth) => [
                            OneLine(
                                depth: depth + 1,
                                body:
                                    'Map<String, Object> message = new HashMap<>();'),
                            OneLine(
                                depth: depth + 1,
                                body:
                                    'message.put("callbackName", callbackName);'),
                            OneLine(
                                depth: depth + 1,
                                body:
                                    'message.put("data", ${paramGeneric is AstCustomType ? 'event.toMap()' : 'event'});'),
                            OneLine(
                                depth: depth + 1,
                                body:
                                    'new BasicMessageChannel<>(messenger, "$channelPrefix.UniCallbackManager.callback_channel$channelSuffix", StandardMessageCodec.INSTANCE).send(message);'), // fixme 这里 channel 有问题
                          ])
                ]) {
    registerCustomType(typeUniCallback);
  }

  static String getName(String methodName, String paramName) {
    return 'On${upperFirst(methodName)}${upperFirst(paramName)}';
  }

  static String upperFirst(String name) {
    return name[0].toUpperCase() + name.substring(1);
  }
}
