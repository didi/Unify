import 'package:test/test.dart';
import 'package:unify_flutter/generator/widgets/base/comment.dart';
import 'package:unify_flutter/generator/widgets/code_unit.dart';

void main() {
  test('Comment OneLine COMMENT_DOUBLE_BACK_SLASH', () {
    expect(Comment(comments: ['comment1']).build(), '// comment1\n');
  });

  test('Comment OneLine COMMENT_DOUBLE_BACK_SLASH with Tabs', () {
    expect(Comment(depth: 2, comments: ['comment1']).build(),
        '${CodeUnit.tab}${CodeUnit.tab}// comment1\n');
  });

  test('Comment MultiLine COMMENT_DOUBLE_BACK_SLASH', () {
    expect(Comment(comments: ['comment1', 'comment2', 'comment3']).build(),
        '// comment1\n// comment2\n// comment3\n');
  });

  test('Comment MultiLine COMMENT_DOUBLE_BACK_SLASH with Tabs', () {
    expect(
        Comment(depth: 2, comments: ['comment1', 'comment2', 'comment3'])
            .build(),
        '${CodeUnit.tab + CodeUnit.tab}// comment1\n${CodeUnit.tab + CodeUnit.tab}// comment2\n${CodeUnit.tab + CodeUnit.tab}// comment3\n');
  });
}
