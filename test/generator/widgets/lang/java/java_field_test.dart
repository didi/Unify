import 'package:test/test.dart';
import 'package:unify_flutter/ast/basic/ast_bool.dart';
import 'package:unify_flutter/ast/basic/ast_int.dart';
import 'package:unify_flutter/ast/basic/ast_list.dart';
import 'package:unify_flutter/ast/basic/ast_map.dart';
import 'package:unify_flutter/ast/basic/ast_string.dart';
import 'package:unify_flutter/ast/basic/ast_variable.dart';
import 'package:unify_flutter/generator/widgets/lang/java/java_field.dart';

void main() {
  test('int field', () {
    final field = Variable(AstInt(), 'a');
    expect(JavaField(field).build(), 'long a;\n');
  });

  test('String field', () {
    final field = Variable(AstString(), 'a');
    expect(JavaField(field).build(), 'String a;\n');
  });

  test('bool field', () {
    final field = Variable(AstBool(), 'a');
    expect(JavaField(field).build(), 'boolean a;\n');
  });

  test('List field', () {
    final field = Variable(AstList(generics: [AstString()]), 'a');
    expect(JavaField(field).build(), 'List<String> a;\n');
  });

  test('Map field', () {
    final field = Variable(AstMap(keyType: AstString()), 'a');
    expect(JavaField(field).build(), 'Map<String, Object> a;\n');
  });
}
