import 'package:unify/analyzer/analyzer_lib.dart';
import 'package:unify/utils/constants.dart';
import 'package:unify/ast/base.dart';
import 'package:unify/ast/basic/ast_custom.dart';
import 'package:unify/ast/basic/ast_list.dart';
import 'package:unify/ast/basic/ast_map.dart';
import 'package:unify/ast/basic/ast_object.dart';
import 'package:unify/ast/basic/ast_string.dart';
import 'package:unify/ast/basic/ast_variable.dart';
import 'package:unify/ast/basic/ast_void.dart';
import 'package:unify/ast/uniapi/ast_method.dart';
import 'package:unify/generator/widgets/base/line.dart';
import 'package:unify/generator/widgets/code_unit.dart';
import 'package:unify/generator/widgets/lang/java/java_function.dart';
import 'package:unify/generator/widgets/lang/oc/oc_reference.dart';
import 'package:unify/utils/extension/codeunit_extension.dart';

class OCFunction extends CodeUnit {
  OCFunction(
      {this.functionName = '',
      this.params = const [],
      this.isInstanceMethod = false,
      this.isClassMethod = false,
      this.isDeclaration = false,
      this.isCFlavor = false,
      this.isExternal = false,
      this.isStatic = false,
      this.body,
      this.returnType = const AstVoid(),
      int depth = 0})
      : super(depth);

  // 方法名
  String functionName;

  // 入参
  List<Variable> params;

  // is Instance method
  bool isInstanceMethod;

  // isClassMethod;
  bool isClassMethod;

  // 是否是声明
  bool isDeclaration;

  // 是否是 C 语言风格
  bool isCFlavor;

  bool isExternal;

  bool isStatic;

  AstType returnType;

  FunctionBodyBuilder? body;

  String functionSignatureOC() {
    final sb = StringBuffer();

    if (isClassMethod) {
      sb.write('+' ' ');
    }
    if (isInstanceMethod) {
      sb.write('-' ' ');
    }

    sb.write('(${OCReference(returnType).build()})');
    sb.write(functionName);

    if (params.isNotEmpty) {
      sb.write(':');
      for (var i = 0; i < params.length; i++) {
        final param = params[i];
        if (i == 0) {
          sb.write(
              '(${OCReference(param.type, keepRaw: param.type.keepRaw).build()})${param.name}'); // NSInteger, Class, int, long, 抽一个组件 OCReference()
        } else {
          sb.write(
              '${param.name}:(${OCReference(param.type, keepRaw: param.type.keepRaw).build()})${param.name}');
        }
        if (i < params.length - 1) {
          sb.write(' ');
        }
      }
    }

    return sb.toString();
  }

  String functionSignatureC() {
    final sb = StringBuffer();

    if (isExternal) {
      sb.write('extern');
      sb.write(' ');
    }

    if (isStatic) {
      sb.write('static');
      sb.write(' ');
    }

    sb.write(OCReference(returnType).build());
    sb.write(' ');
    sb.write(functionName);
    sb.write('(');

    final paramList = params
        .map((param) => '${OCReference(param.type).build()} ${param.name}');
    sb.write(paramList.join(', '));
    sb.write(')');

    return sb.toString();
  }

  String functionSignature() {
    assert((isClassMethod && isInstanceMethod) == false);

    if (isCFlavor) {
      return functionSignatureC();
    } else {
      return functionSignatureOC();
    }
  }

  @override
  String build() {
    if (isDeclaration) {
      return OneLine(depth: depth, body: '${functionSignature()};').build();
    }

    return CodeUnit.join([
      LineExpand(OneLine(depth: depth, body: functionSignature()), ' {'),
      if (body != null) ...body!(depth),
      OneLine(depth: depth, body: '}')
    ]);
  }
}

class OCFunctionCallRealParam {
  OCFunctionCallRealParam(this.name, this.value);

  String value;
  String name;
}

class OCFunctionCall extends CodeUnit {
  OCFunctionCall(
      {this.instanceName = '',
      this.functionName = '',
      this.params = const [],
      this.ignoreError = false,
      int depth = 0})
      : super(depth);

  String instanceName;

  // 方法名
  String functionName;

  // 入参
  List<OCFunctionCallRealParam> params;

  bool ignoreError;

  @override
  String build() {
    final sb = StringBuffer();
    sb.write('[');
    sb.write(instanceName);
    sb.write(' ');
    sb.write(functionName);
    if (params.isNotEmpty) {
      sb.write(':');
      sb.write(params[0].value);
    }

    var signature =
        OneLine(depth: depth, body: sb.toString(), hasNewline: false);

    final ret = <CodeUnit>[];

    if (params.length > 1) {
      for (var i = 1; i < params.length; i++) {
        // 普通参数
        if (!params[i].value.contains('^')) {
          signature =
              LineExpand(signature, ' ${params[i].name}:${params[i].value}')
                ..hasNewline = false;
        } else {
          // Block 单独一行
          if (!signature.build().endsWith('\n')) {
            ret.add(EmptyLine());
          }
          ret.add(OneLine(
              depth: depth,
              body: '${params[i].name}:${params[i].value}',
              hasNewline: false));
        }
      }
    }
    ret.add(OneLine(depth: ignoreError == false ? depth : 0, body: '];'));

    ret.insert(0, signature);
    return CodeUnit.join(ret);
  }
}

class OCPredefinedFuncModelList extends OCFunction {
  OCPredefinedFuncModelList()
      : super(
          functionName: 'modelList',
          isClassMethod: true,
          returnType: AstList(),
          params: [
            Variable(AstList(generics: [AstMap()]), 'list'),
          ],
          body: (depth) => [
            OneLine(
                depth: depth + 1,
                body: 'if ((NSNull *)list == [NSNull null]) return nil;'),
            OneLine(
                depth: depth + 1,
                body: 'NSMutableArray *models = NSMutableArray.new;'),
            OneLine(
                depth: depth + 1, body: 'for (NSDictionary *item in list) {'),
            OneLine(
                depth: depth + 2,
                body: 'id obj = [[self class] fromMap:item];'),
            OneLine(depth: depth + 2, body: '[models addObject:obj];'),
            OneLine(depth: depth + 1, body: '}'),
            OneLine(depth: depth + 1, body: 'if (models.count==0) return nil;'),
            OneLine(depth: depth + 1, body: 'return models;')
          ],
        ) {
    registerCustomType('Class');
  }
}

class OCPredefinedFuncDictList extends OCFunction {
  OCPredefinedFuncDictList()
      : super(
            functionName: 'dicList',
            isClassMethod: true,
            returnType: AstList(),
            params: [
              Variable(AstList(), 'list'),
            ],
            body: (depth) => [
                  OneLine(
                      depth: depth + 1,
                      body: 'if ((NSNull *)list == [NSNull null]) return nil;'),
                  OneLine(
                      depth: depth + 1,
                      body: 'NSMutableArray *dicList = NSMutableArray.new;'),
                  OneLine(depth: depth + 1, body: 'for (id item in list) {'),
                  OneLine(
                      depth: depth + 2,
                      body: 'NSDictionary *dic = [item toMap];'),
                  OneLine(depth: depth + 2, body: '[dicList addObject:dic];'),
                  OneLine(depth: depth + 1, body: '}'),
                  OneLine(depth: depth + 1, body: 'return dicList;'),
                ]);
}

class OCPredefinedFuncWrapNil extends OCFunction {
  OCPredefinedFuncWrapNil()
      : super(
            functionName: 'wrapNil',
            isClassMethod: true,
            returnType: AstCustomType('id'),
            params: [Variable(AstCustomType('id'), 'value')],
            body: (depth) => [
                  OneLine(
                      depth: depth + 1,
                      body:
                          'return (value == nil) || ((NSNull *)value == [NSNull null]) || [value isEqual:@"<null>"]? nil : value;')
                ]);
}

class OCPredefinedFuncWrapResult extends OCFunction {
  OCPredefinedFuncWrapResult()
      : super(
            functionName: 'wrapResult',
            isCFlavor: true,
            isStatic: true,
            returnType:
                AstMap(keyType: AstString(), valueType: AstCustomType('id')),
            params: [
              Variable(const AstObject(), 'result'),
              Variable(AstCustomType(typeFlutterError), 'error')
            ],
            body: (depth) {
              final ret = <CodeUnit>[
                OneLine(
                    depth: depth + 1,
                    body:
                        'NSDictionary *errorDict = (NSDictionary *)[NSNull null];'),
                OneLine(depth: depth + 1, body: 'if (error) {'),
                OneLine(depth: depth + 2, body: 'errorDict = @{'),
                OneLine(
                    depth: depth + 3,
                    body:
                        '@"${Keys.errorCode}": (error.code ? error.code : [NSNull null]),'),
                OneLine(
                    depth: depth + 3,
                    body:
                        '@"${Keys.errorMessage}": (error.message ? error.message : [NSNull null]),'),
                OneLine(
                    depth: depth + 3,
                    body:
                        '@"${Keys.errorDetails}": (error.details ? error.details : [NSNull null]),'),
                OneLine(depth: depth + 3, body: '};'),
                OneLine(depth: depth + 1, body: '}'),
                OneLine(depth: depth + 1, body: 'return @{'),
                OneLine(
                    depth: depth + 2,
                    body:
                        '@"${Keys.result}": (result ? result : [NSNull null]),'),
                OneLine(depth: depth + 2, body: '@"${Keys.error}": errorDict,'),
                OneLine(depth: depth + 2, body: '};'),
              ];
              return ret;
            });
}

class OCCollectionCloneFunction extends CodeUnit {
  OCCollectionCloneFunction(
      {this.fields = const [], this.methods = const [], int depth = 0})
      : super(depth);

  final List<Variable> fields;
  final List<Method> methods;

  Set<String> modelSet = {};

  List<OneLine> genCollectionFunction() {
    return handlerOCCollectionType(fields: fields, methods: methods);
  }

  @override
  String build() {
    // TODO: implement build
    throw UnimplementedError();
  }
}
