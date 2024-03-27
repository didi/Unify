import 'package:unify/analyzer/analyzer_lib.dart';
import 'package:unify/ast/basic/ast_bool.dart';
import 'package:unify/ast/basic/ast_custom.dart';
import 'package:unify/ast/basic/ast_double.dart';
import 'package:unify/ast/basic/ast_int.dart';
import 'package:unify/ast/basic/ast_list.dart';
import 'package:unify/ast/basic/ast_map.dart';
import 'package:unify/ast/basic/ast_string.dart';
import 'package:unify/ast/basic/ast_variable.dart';
import 'package:unify/ast/uniapi/ast_method.dart';
import 'package:unify/ast/uniapi/ast_model.dart';
import 'package:unify/ast/uniapi/ast_module.dart';
import 'package:unify/cli/options.dart';
import 'package:unify/generator/module_native.dart';
import 'package:unify/utils/constants.dart';
import 'package:unify/utils/file/input_file.dart';
import 'package:unify/utils/log.dart';

void main() {
  // 嵌套依赖类型 A
  final inputFile = InputFile();
  inputFile.parts = ['tts', 'model'];
  inputFile.path = 'tts/model/PlayData.dart';
  final dependModelPlayData = Model('PlayData', inputFile);

  // 嵌套依赖类型 B
  final inputFile1 = InputFile();
  inputFile1.parts = ['tts', 'model'];
  inputFile1.path = 'tts/model/Data.dart';
  final dependModelData = Model('Data', inputFile1);

  final options = UniAPIOptions();
  options.javaPackageName = 'com.didi.uniapi';

  final inputFile3 = InputFile();
  inputFile3.parts = ['tts'];
  inputFile3.path = 'tts/AudioManager.dart';

  final module = Module(inputFile3, name: 'AudioManager', methods: [
    Method(name: 'play', parameters: [
      Variable(AstCustomType('PlayData'), 'playData'),
      Variable(AstInt(), 'type'),
    ]),
    Method(name: 'complex', returnType: AstDouble(), parameters: [
      Variable(AstCustomType('PlayData'), 'a'),
      Variable(AstInt(), 'b'),
      Variable(AstBool(), 'c'),
      Variable(AstDouble(), 'd'),
      Variable(AstString(), 'e'),
      Variable(AstList(generics: [AstInt()]), 'f'),
      Variable(AstList(generics: [AstString()]), 'g'),
      Variable(AstMap(keyType: AstString(), valueType: AstString()), 'h'),
    ]),
    Method(
        name: 'stop',
        ignoreError: true,
        returnType: AstString(),
        parameters: []),
    Method(name: 'isPlaying', returnType: AstBool()),
    Method(name: 'onCompleted', returnType: AstInt()),
    Method(
        name: 'testHello',
        returnType: AstDouble(),
        parameters: [Variable(AstCustomType('Data'), 'data')],
        isAsync: true),
    Method(name: 'coolCallback', parameters: [
      Variable(
          AstCustomType(typeUniCallback, generics: [AstCustomType('Data')]),
          'callback')
    ]),
    Method(name: 'coolCallback2', parameters: [
      Variable(
          AstCustomType(typeUniCallback, generics: [AstBool()]), 'callback')
    ]),
    Method(name: 'coolCallback3', parameters: [
      Variable(
          AstCustomType(typeUniCallback, generics: [
            AstList(generics: [AstString()])
          ]),
          'callback')
    ]),
    Method(
        name: 'getData',
        returnType: AstList(generics: [AstCustomType('Data')]),
        parameters: [
          Variable(AstList(generics: [AstCustomType('Data')]), 'datas')
        ]),
  ]);

  final analyzer = UniApiAnalyzer([inputFile3]);
  analyzer.addCustomType(['PlayData', 'Data', 'AudioManager']);
  UniApiAnalyzer.mockParseResults(
      models: [dependModelPlayData, dependModelData], nativeModules: [module]);

  log('============== generate interface ====================');
  log(ModuleGenerator.javaCode(module, options));

  log('============== generate module register ====================');
  log(ModuleGenerator.javaRegisterCode(module, options));

  log('============== generate oc module Header ====================');
  log(ModuleGenerator.ocHeader(module, options));

  log('============== generate oc module Source ====================');
  log(ModuleGenerator.ocSource(module, options));

  log('============== generate dart module Source ====================');
  log(ModuleGenerator.dartCode(module, options));

  log('============== generate dart UniCallbackManager ====================');
  log(ModuleGenerator.dartCallbackManagerCode(options));
}
