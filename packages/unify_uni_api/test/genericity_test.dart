import 'dart:io';

import 'package:test/test.dart';
import 'package:unify_flutter/analyzer/analyzer_lib.dart';
import 'package:unify_flutter/cli/options.dart';
import 'package:unify_flutter/generator/model.dart';
import 'package:unify_flutter/generator/module_flutter.dart';
import 'package:unify_flutter/generator/module_native.dart';
import 'package:unify_flutter/generator/widgets/code_unit.dart';
import 'package:unify_flutter/generator/widgets/lang/dart/dart_class.dart';
import 'package:unify_flutter/generator/widgets/lang/dart/dart_import.dart';
import 'package:unify_flutter/generator/widgets/lang/java/java_class.dart';
import 'package:unify_flutter/generator/widgets/lang/java/java_import.dart';
import 'package:unify_flutter/generator/widgets/lang/oc/oc_class.dart';
import 'package:unify_flutter/generator/widgets/lang/oc/oc_import.dart';
import 'package:unify_flutter/utils/constants.dart';
import 'package:unify_flutter/utils/file/file.dart';
import 'package:unify_flutter/utils/log.dart';

/// input path parse & ast parse testing
Future<void> main() async {
  final tempDir = createTempDir();
  final inputPath = '${Directory.current.path}/test/interface/genericity';
  final inputFiles = await parseInputFiles(inputPath, tempDir.path);

  final analyzer = UniApiAnalyzer(inputFiles)..parseFile(inputPath);

  final options = UniAPIOptions();
  options.javaPackageName = 'com.didi.uniapi';

  test('input path parse', () {
    expect(4, inputFiles.length);
  });

  test('test import:测试泛型深层含有自定义的类型', () {
    final model = analyzer
        .results()
        .models
        .where((element) => element.name == 'GenericityModel')
        .first;
    expect(
        '#import "GenericityData.h"\n',
        OCCustomNestedImports(model.inputFile, options, fields: model.fields)
            .build());

    expect(
        'import com.didi.$projectName.GenericityData;\n',
        JavaCustomNestedImports(model.inputFile, options, fields: model.fields)
            .build());
    expect(
        "import 'genericity_data.dart';\n",
        DartCustomNestedImports(model.inputFile, options, fields: model.fields)
            .build());
  });

  test('test model 属性声明:带泛型(生成代码和定义模板保持一致)', () {
    final model = analyzer
        .results()
        .models
        .where((element) => element.name == 'GenericityModel')
        .first;

    // Dart
    final dartCls = DartClass(fields: model.fields);
    var code = CodeUnit.join([...dartCls.dartFields()]);
    expect(
        '${CodeUnit.tab}List<String>? a;\n${CodeUnit.tab}Map<String, List<String>?>? b;\n${CodeUnit.tab}List<Map<String, List<String>?>>? c;\n${CodeUnit.tab}List<Map<String, List<Map<String, List<GenericityData>?>>?>>? d;\n${CodeUnit.tab}int? e;\n',
        code);

    // OC
    final ocCls = OCClassDeclaration(properties: model.fields);
    code = CodeUnit.join([...ocCls.ocFields()]);
    expect(
        "@property(nonatomic, strong) NSArray<NSString*>* a; // Origin dart type is 'List'\n@property(nonatomic, strong) NSDictionary<NSString*, NSArray<NSString*>*>* b; // Origin dart type is 'Map'\n@property(nonatomic, strong) NSArray<NSDictionary<NSString*, NSArray<NSString*>*>*>* c; // Origin dart type is 'List'\n@property(nonatomic, strong) NSArray<NSDictionary<NSString*, NSArray<NSDictionary<NSString*, NSArray<GenericityData*>*>*>*>*>* d; // Origin dart type is 'List'\n@property(nonatomic, strong) NSNumber* e; // Origin dart type is 'int'\n",
        code);
    // Java
    final javaCls =
        JavaClass(className: model.name, privateFields: model.fields);
    code = CodeUnit.join([...javaCls.javaPrivateFields()]);
    expect(
        '${CodeUnit.tab}private List<String> a;\n${CodeUnit.tab}private Map<String, List<String>> b;\n${CodeUnit.tab}private List<Map<String, List<String>>> c;\n${CodeUnit.tab}private List<Map<String, List<Map<String, List<GenericityData>>>>> d;\n${CodeUnit.tab}private long e;\n',
        code);

    log(ModelGenerator.dartCode(model, options));
  });

  test('test flutter module : 带复杂泛型', () {
    final module = analyzer
        .results()
        .flutterModules
        .where((element) => element.name == 'GenericityFlutterModule')
        .first;

    // 自定义type导入测试 泛型嵌套的深层含有自定义类型
    var i = JavaCustomNestedImports(module.inputFile, options,
            methods: module.methods)
        .build();
    expect(true, i.contains('GenericityModel'));

    i = OCCustomNestedImports(module.inputFile, options,
            methods: module.methods, isForwardDeclaration: true)
        .build();

    expect(true, i.contains('GenericityModel'));

    log(FlutterModuleGenerator.ocHeader(module, options));

    log(FlutterModuleGenerator.dartCode(module, options));
  });
  test('test native module : 带复杂泛型', () {
    final module = analyzer
        .results()
        .nativeModules
        .where((element) => element.name == 'GenericityNativeModule')
        .first;

    // log('============== generate interface ====================');
    // log(ModuleGenerator.javaCode(module, options, module.inputFile));

    // log('============== generate module register ====================');
    // log(ModuleGenerator.javaRegisterCode(module, options, module.inputFile));

    // log('============== generate oc module Header ====================');
    // log(ModuleGenerator.ocHeader(module, options));

    // log('============== generate oc module Source ====================');
    // log(ModuleGenerator.ocSource(module, options));

    log('============== generate dart module Source ====================');
    log(ModuleGenerator.dartCode(module, options));

    // log(
    //     '============== generate dart UniCallbackManager ====================');
    // log(ModuleGenerator.dartCallbackManagerCode(options));
  });
}
