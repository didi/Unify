import 'package:unify_flutter/ast/base.dart';
import 'package:unify_flutter/ast/basic/ast_variable.dart';
import 'package:unify_flutter/ast/basic/ast_void.dart';
import 'package:unify_flutter/generator/widgets/base/line.dart';
import 'package:unify_flutter/generator/widgets/code_unit.dart';
import 'package:unify_flutter/generator/widgets/lang/java/java_function.dart';

class DartFunction extends CodeUnit {
  DartFunction({
    this.functionName = '',
    this.params = const [],
    int depth = 0,
    this.isStatic = false,
    this.isAbstract = false,
    this.isConstructor = false,
    this.isAsync = false,
    this.body,
    this.returnType = const AstVoid(),
  }) : super(depth);

  // 方法名
  String functionName;

  // 入参
  List<Variable> params;

  // 函数内容
  FunctionBodyBuilder? body;

  // 是否是静态方法
  bool isStatic;

  bool isAbstract;

  // 是否是构造方法
  bool isConstructor;

  // 是否是异步方法
  bool isAsync;

  AstType returnType;

  String functionSignature() {
    final sb = StringBuffer();

    if (!isConstructor) {
      if (isStatic) {
        sb.write('static');
        sb.write(' ');
      }
      sb.write(returnType.dartType(showGenerics: true));
      sb.write(' ');
    }

    sb.write(functionName);
    sb.write('(');
    sb.write(params
        .map((e) => '${e.type.dartType(showGenerics: true)} ${e.name}')
        .join(', '));
    sb.write(')');

    return sb.toString();
  }

  @override
  String build() {
    if (isAbstract) {
      return OneLine(depth: depth, body: '${functionSignature()};').build();
    }
    var fullSignature = functionSignature();
    if (isAsync) {
      fullSignature += ' ';
      fullSignature += 'async';
      fullSignature += ' ';
    }
    return CodeUnit.join([
      OneLine(depth: depth, body: '$fullSignature {'),
      if (body != null) ...body!(depth),
      OneLine(depth: depth, body: '}')
    ]);
  }
}

class DartConstructor extends DartFunction {
  DartConstructor(String className, List<Variable> params, {int depth = 0})
      : super(
            functionName: className,
            isConstructor: true,
            depth: depth,
            params: params,
            body: (depth) {
              final ret = <CodeUnit>[];
              for (final param in params) {
                ret.add(OneLine(
                    depth: depth + 1,
                    body: 'this.${param.name} = ${param.name};'));
              }
              return ret;
            });
}
