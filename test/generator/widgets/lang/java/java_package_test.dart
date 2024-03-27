import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';
import 'package:unify/ast/basic/ast_bool.dart';
import 'package:unify/ast/basic/ast_int.dart';
import 'package:unify/ast/basic/ast_string.dart';
import 'package:unify/ast/basic/ast_variable.dart';
import 'package:unify/ast/uniapi/ast_model.dart';
import 'package:unify/cli/options.dart';
import 'package:unify/generator/widgets/lang/java/java_package.dart';
import 'package:unify/utils/file/input_file.dart';

void main() {
  final inputFile = InputFile();
  inputFile.parts = ['sub1', 'sub2', 'sub3'];
  final model = Model('TestModel', inputFile, fields: [
    Variable(AstInt(), 'a'),
    Variable(AstString(), 'b'),
    Variable(AstBool(), 'c')
  ]);

  final options = UniAPIOptions();
  options.javaPackageName = 'com.didi.uniapi';

  test('JavaPackage', () {
    expect(JavaPackage(model.inputFile, options).build(),
        'package com.didi.uniapi.sub1.sub2.sub3;\n');
  });
}
