import 'dart:io';

import 'package:test/test.dart';
import 'package:unify/analyzer/analyzer_lib.dart';
import 'package:unify/ast/basic/ast_void.dart';
import 'package:unify/utils/file/file.dart';

/// input path parse & ast parse testing
Future<void> main() async {
  final tempDir = createTempDir();
  final inputPath = '${Directory.current.path}/test/interface';
  final inputFiles = await parseInputFiles(inputPath, tempDir.path);

  final analyzer = UniApiAnalyzer(inputFiles)..parseFile(inputPath);

  test('input path parse', () {
    expect(11, inputFiles.length);
    final audio = inputFiles.firstWhere((element) => element.name == 'audio');
    expect('tts/model/audio.dart', audio.path);
    expect('$inputPath/tts/model/audio.dart', audio.absolutePath);
  });

  test('model ast parse', () {
    final model = analyzer
        .results()
        .models
        .where((element) => element.name == 'TtsData')
        .first;
    expect(2, model.fields.length);
    expect('audio', model.fields[1].name);
    expect(
        'Audio',
        model.fields
            .where((element) => element.name == 'audio')
            .first
            .type
            .astType());
    expect(
        true,
        model.fields
            .where((element) => element.name == 'name')
            .first
            .type
            .maybeNull);

    // UniModel数量
    final models = analyzer.results().models;
    expect(6, models.length);

    // 注释测试
    expect(true, model.codeComments.isNotEmpty);
    expect(true, model.codeComments.first.contains('注释:存储TTS数据内容')); // 类注释
    expect(
        true,
        model.fields
            .where((element) => element.name == 'name')
            .first
            .codeComments
            .first
            .contains('注释:TTS文件名称')); // 属性注释
  });

  test('flutter module ast parse', () {
    final ttsService = analyzer
        .results()
        .nativeModules
        .where((element) => element.name == 'TtsService')
        .first;

    expect(
        2,
        ttsService.methods
            .where((element) => element.name != 'TtsService')
            .length);
    expect('playTts', ttsService.methods[0].name);

    // return测试
    expect(
        true,
        ttsService.methods[0].returnType.realType().astType() ==
            const AstVoid().realType().astType());
    expect(0, ttsService.methods[0].returnType.generics.length);
    expect('int', ttsService.methods[1].returnType.realType().astType());
    expect(
        false,
        ttsService.methods[1].returnType.realType().astType() ==
            const AstVoid().realType().astType());

    // 参数测试
    expect(1, ttsService.methods[0].parameters.length);
    expect('TtsData',
        ttsService.methods[0].parameters[0].type.realType().astType());
    expect(true, ttsService.methods[0].parameters.first.type.maybeNull); // 参数可空

    // 方法注释 测试
    expect(
        true,
        ttsService.methods
            .where((element) => element.name == 'playTts')
            .first
            .codeComments
            .first
            .contains('方法注释:播放'));
  });
}
