import 'package:unify_flutter/ast/base.dart';
import 'package:unify_flutter/ast/basic/ast_variable.dart';
import 'package:unify_flutter/utils/file/input_file.dart';

class Model extends UniApiNode with Serializable {
  Model(
    this.name,
    this.inputFile, {
    this.fields = const [],
    this.isEnum = false,
    this.codeComments = const <String>[],
  });

  String name;
  List<Variable> fields;
  InputFile inputFile;
  bool isEnum;
  List<String> codeComments;

  @override
  String toString() => '[$name]';
}
