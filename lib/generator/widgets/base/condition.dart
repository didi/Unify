import 'package:unify/generator/widgets/base/line.dart';
import 'package:unify/generator/widgets/code_unit.dart';
import 'package:unify/generator/widgets/lang/java/java_class.dart';

class IfBlock extends CodeUnit {
  IfBlock(this.ifCondition, this.ifContent, {int depth = 0, this.elseContent})
      : super(depth);

  CodeUnit ifCondition;
  InjectCodeUnit ifContent;

  InjectCodeUnit? elseContent;

  @override
  String build() {
    final ret = <CodeUnit>[];
    ret.add(OneLine(depth: depth, body: 'if (${ifCondition.build()}) {'));
    ret.addAll(ifContent(depth + 1));
    if (elseContent == null) {
      ret.add(OneLine(depth: depth, body: '}'));
      return CodeUnit.join(ret);
    } else {
      ret.add(OneLine(depth: depth, body: '} else {'));
      ret.addAll(elseContent!(depth + 1));
      ret.add(OneLine(depth: depth, body: '}'));
      return CodeUnit.join(ret);
    }
  }
}
