// 代码的基本单元
abstract class CodeUnit {
  CodeUnit(this.depth);

  static const space = ' ';
  static const newLine = '\n';
  static const tab = '    ';

  final int depth;

  static String join(List<CodeUnit> parts, {String separator = ''}) {
    return parts.map((p) => p.build()).join(separator);
  }

  String depthTabs() {
    final sb = StringBuffer();
    for (var i = 0; i < depth; i++) {
      sb.write(tab);
    }
    return sb.toString();
  }

  // 生成当前代码单元的字符串
  String build();
}
