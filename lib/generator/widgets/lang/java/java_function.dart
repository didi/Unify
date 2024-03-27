import 'package:unify/ast/base.dart';
import 'package:unify/ast/basic/ast_variable.dart';
import 'package:unify/ast/basic/ast_void.dart';
import 'package:unify/ast/uniapi/ast_method.dart';
import 'package:unify/generator/widgets/base/line.dart';
import 'package:unify/generator/widgets/code_unit.dart';
import 'package:unify/generator/widgets/lang/java/java_constants.dart';
import 'package:unify/utils/extension/codeunit_extension.dart';

typedef FunctionBodyBuilder = List<CodeUnit> Function(int depth);

class JavaFunction extends CodeUnit {
  JavaFunction(
      {this.functionName = '',
      this.body,
      this.params = const [],
      this.returnType = const AstVoid(),
      int depth = 0,
      this.isAbstract = false,
      this.isOverride = false,
      this.isPublic = false,
      this.isPrivate = false,
      this.isStatic = false,
      this.isConstruct = false,
      this.oneLine = false})
      : assert(functionName.isNotEmpty),
        super(depth);

  // 方法名
  String functionName;

  // 入参
  List<Variable> params;

  // 函数内容
  FunctionBodyBuilder? body;

  // 是否是抽象方法
  bool isAbstract;

  // 是否是公有方法
  bool isPublic;
  // 是否是私有方法
  bool isPrivate;
  // 是否是静态方法
  bool isStatic;
  bool isOverride;
  bool isConstruct;
  // wrap function into one line
  bool oneLine;

  AstType returnType;

  String functionSignature() {
    assert((isPublic && isPrivate) == false);

    final sb = StringBuffer();

    if (isPublic) {
      sb.write(keywordPublic + keywordSpace);
    }
    if (isPrivate) {
      sb.write(keywordPrivate + keywordSpace);
    }
    if (isStatic) {
      sb.write(keywordStatic + keywordSpace);
    }

    if (!isConstruct) {
      sb.write(returnType.javaType() + keywordSpace);
    }

    sb.write(functionName);
    sb.write(keywordParenthesesLeft);
    sb.write(params.map((e) => '${e.type.javaType()} ${e.name}').join(', '));
    sb.write(keywordParenthesesRight);

    return sb.toString();
  }

  @override
  String build() {
    assert(body != null || isAbstract);

    if (isAbstract) {
      return OneLine(depth: depth, body: '${functionSignature()};').build();
    }

    if (oneLine) {
      final lines = <OneLine>[];

      if (isOverride) {
        lines.add(OneLine(depth: depth, body: '@Override'));
      }

      final sb = StringBuffer();
      sb.write(functionSignature());
      sb.write(keywordSpace);
      sb.write(keywordBraceLeft);
      sb.write(keywordSpace);
      sb.write(CodeUnit.join(body!(depth))
          .replaceAll('    ', '')
          .replaceAll('\n', ''));
      sb.write(keywordSpace + keywordBraceRight);

      lines.add(OneLine(depth: depth, body: sb.toString()));

      return CodeUnit.join(lines);
    }

    return CodeUnit.join([
      if (isOverride) OneLine(depth: depth, body: '@Override'),
      OneLine(
          depth: depth,
          body: functionSignature() + keywordSpace + keywordBraceLeft),
      ...body!(depth),
      OneLine(depth: depth, body: keywordBraceRight)
    ]);
  }
}

class JavaFunctionGetter extends JavaFunction {
  JavaFunctionGetter(Variable field, {int depth = 0})
      : super(
            functionName:
                'get${field.name[0].toUpperCase()}${field.name.substring(1)}',
            body: (depth) =>
                [OneLine(depth: depth + 1, body: 'return ${field.name};')],
            returnType: field.type,
            isPublic: true,
            isStatic: false,
            oneLine: true,
            depth: depth);
}

class JavaFunctionSetter extends JavaFunction {
  JavaFunctionSetter(Variable field, {int depth = 0})
      : super(
            functionName:
                'set${field.name[0].toUpperCase()}${field.name.substring(1)}',
            params: [field],
            body: (depth) => [
                  OneLine(
                      depth: depth + 1,
                      body: 'this.${field.name} = ${field.name};')
                ],
            returnType: const AstVoid(),
            isPublic: true,
            isStatic: false,
            oneLine: true,
            depth: depth);
}

class JavaCollectionCloneFunction extends CodeUnit {
  JavaCollectionCloneFunction(
      {this.fields = const [], this.methods = const [], int depth = 0})
      : super(depth);

  final List<Variable> fields;
  final List<Method> methods;

  Set<String> modelSet = {};

  List<OneLine> genCollectionFunction() {
    return handlerJavaCollectionType(fields: fields, methods: methods);
  }

  @override
  String build() {
    // TODO: implement build
    throw UnimplementedError();
  }
}
