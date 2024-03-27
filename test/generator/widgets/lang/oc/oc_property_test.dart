import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';
import 'package:unify/ast/basic/ast_bool.dart';
import 'package:unify/ast/basic/ast_int.dart';
import 'package:unify/ast/basic/ast_list.dart';
import 'package:unify/ast/basic/ast_map.dart';
import 'package:unify/ast/basic/ast_string.dart';
import 'package:unify/ast/basic/ast_variable.dart';
import 'package:unify/generator/widgets/lang/oc/oc_property.dart';

void main() {
  test('int field', () {
    final field = Variable(AstInt(), 'a');
    expect(OCProperty(field).build(),
        '@property(nonatomic, strong) NSNumber* a;\n');
  });

  test('String field', () {
    final field = Variable(AstString(), 'a');
    expect(
        OCProperty(field).build(), '@property(nonatomic, copy) NSString* a;\n');
  });

  test('bool field', () {
    final field = Variable(AstBool(), 'a');
    expect(OCProperty(field).build(),
        '@property(nonatomic, strong) NSNumber* a;\n');
  });

  test('List field', () {
    final field = Variable(AstList(generics: [AstString()]), 'a');
    expect(OCProperty(field).build(),
        '@property(nonatomic, strong) NSArray<NSString*>* a;\n');
  });

  test('Map field', () {
    final field = Variable(AstMap(keyType: AstString()), 'a');
    expect(OCProperty(field).build(),
        '@property(nonatomic, strong) NSDictionary<NSString*, NSObject*>* a;\n');
  });
}
