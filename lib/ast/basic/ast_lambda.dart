import 'package:unify/ast/base.dart';
import 'package:unify/ast/basic/ast_variable.dart';
import 'package:unify/generator/widgets/base/line.dart';
import 'package:unify/generator/widgets/code_unit.dart';
import 'package:unify/generator/widgets/lang/java/java_class.dart';
import 'package:unify/generator/widgets/lang/oc/oc_reference.dart';

class AstLambda extends AstType {
  AstLambda(this.params, this.returnType,
      {this.injectedOCCodes,
      this.declaration = false,
      this.depth = 0,
      bool maybeNull = false})
      : super(maybeNull, []);

  List<Variable> params;
  AstType returnType;
  bool declaration;

  int depth;
  InjectCodeUnit? injectedOCCodes; // OC 代码注入

  @override
  String dartType({bool showGenerics = false}) {
    // TODO: implement dartType
    throw UnimplementedError();
  }

  @override
  String javaDefault() {
    // TODO: implement javaDefault
    throw UnimplementedError();
  }

  @override
  String javaNewInstance() {
    // TODO: implement javaNewInstance
    throw UnimplementedError();
  }

  @override
  String javaType({bool showGenerics = false}) {
    // TODO: implement javaType
    throw UnimplementedError();
  }

  // fixme 这里 AST 打破规则了，编程代码组件了
  @override
  String ocType({bool showGenerics = false}) {
    final paramList = <String>[];
    for (final param in params) {
      paramList.add('${OCReference(param.type).build()} ${param.name}');
    }

    final ret = <CodeUnit>[];

    if (declaration) {
      ret.add(OneLine(
          body: '${returnType.realType().ocType()}(^)(${paramList.join(', ')})',
          hasNewline: false));
    } else {
      ret.add(OneLine(body: '^(${paramList.join(', ')})', hasNewline: false));
      if (injectedOCCodes != null) {
        ret.add(OneLine(body: ' {'));
        ret.addAll(injectedOCCodes!(depth + 1));
        ret.add(OneLine(depth: depth, body: '}'));
      }
    }
    return CodeUnit.join(ret);
  }

  @override
  String dartDefault() {
    // TODO: implement dartDefault
    throw UnimplementedError();
  }

  @override
  String astType() => 'lambda';
}
