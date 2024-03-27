import 'package:unify/generator/widgets/base/line.dart';
import 'package:unify/generator/widgets/code_unit.dart';
import 'package:unify/generator/widgets/lang/java/java_class.dart';

class ScopeBlock extends CodeUnit {
  ScopeBlock({int depth = 0, this.body}) : super(depth);

  InjectCodeUnit? body;

  @override
  String build() => CodeUnit.join([
        OneLine(depth: depth, body: '{'),
        if (body != null) ...body!(depth + 1),
        OneLine(depth: depth, body: '}')
      ]);
}
