import 'package:unify/generator/widgets/code_unit.dart';

class CodeTemplate extends CodeUnit {
  CodeTemplate({
    this.children = const [],
  }) : super(0);

  List<CodeUnit> children;

  @override
  String build() {
    return children.map((cu) => cu.build()).join();
  }
}
