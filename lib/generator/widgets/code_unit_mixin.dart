import 'package:unify/analyzer/analyzer_lib.dart';
import 'package:unify/ast/uniapi/ast_model.dart';
import 'package:unify/generator/widgets/code_unit.dart';

mixin CodeUnitMixin on CodeUnit {
  List<Model> collectModels(List<String> names) {
    final models = <Model>[];
    for (final element in names) {
      models.addAll(UniApiAnalyzer.allModels()
              ?.where((model) => model.name == element)
              .toList() ??
          []);
    }

    return models;
  }
}
