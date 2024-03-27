import 'package:unify/ast/uniapi/ast_model.dart';
import 'package:unify/ast/uniapi/ast_module.dart';

class ParseResults {
  ParseResults(
      {required this.models,
      required this.flutterModules,
      required this.nativeModules});

  List<Model> models;
  List<Module> flutterModules;
  List<Module> nativeModules;

  @override
  String toString() =>
      'models:"${models.toString()}" \n flutterModules:"${flutterModules.toString()}" \n nativeModules:"${nativeModules.toString()}"';
}
