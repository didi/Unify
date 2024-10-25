import 'package:unify_flutter/generator/widgets/code_unit.dart';

class OneLine extends CodeUnit {
  OneLine({int depth = 0, this.body = '', this.hasNewline = true})
      : super(depth);

  String body;
  bool hasNewline;

  @override
  String build() {
    return depthTabs() + body + (hasNewline ? CodeUnit.newLine : '');
  }
}

class EmptyLine extends OneLine {
  EmptyLine({int depth = 0}) : super(depth: depth);
}

class LineExpand extends OneLine {
  LineExpand(this.originLine, this.extendContent);

  CodeUnit originLine;

  String extendContent;

  @override
  String build() {
    body = originLine.build().replaceAll('\n', '') + extendContent;
    return super.build();
  }
}
