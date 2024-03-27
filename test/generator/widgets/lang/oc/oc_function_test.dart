import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';
import 'package:unify/ast/basic/ast_int.dart';
import 'package:unify/ast/basic/ast_string.dart';
import 'package:unify/ast/basic/ast_variable.dart';
import 'package:unify/generator/widgets/lang/java/java_function.dart';
import 'package:unify/generator/widgets/lang/oc/oc_function.dart';

void main() {
  // java signature test
  test('simple function', () {
    expect(
        OCFunction(functionName: 'testFunc', returnType: AstInt())
            .functionSignature(),
        '(NSNumber*)testFunc');
  });

  test('simple public function', () {
    expect(
        OCFunction(
                functionName: 'testFunc',
                returnType: AstInt(),
                isClassMethod: true)
            .functionSignature(),
        '+ (NSNumber*)testFunc');
  });

  test('simple abstract function', () {
    expect(
        JavaFunction(
                functionName: 'testFunc',
                returnType: AstString(),
                isAbstract: true,
                isPublic: true)
            .functionSignature(),
        'public String testFunc()');
  });

  test('simple public static function', () {
    expect(
        JavaFunction(
                functionName: 'testFunc',
                returnType: AstInt(),
                isPublic: true,
                isStatic: true)
            .functionSignature(),
        'public static long testFunc()');
  });

  test('simple private function', () {
    expect(
        JavaFunction(
                functionName: 'testFunc', returnType: AstInt(), isPrivate: true)
            .functionSignature(),
        'private long testFunc()');
  });

  test('public && private will assert failed', () {
    expect(
        () => JavaFunction(
                functionName: 'testFunc',
                returnType: AstInt(),
                isPrivate: true,
                isPublic: true)
            .functionSignature(),
        throwsA(isA<AssertionError>()));
  });

  // java getter test
  test('simple getter', () {
    final field = Variable(AstString(), 'name');
    expect(JavaFunctionGetter(field).build(),
        'public String getName() { return name; }\n');
  });

  test('simple setter', () {
    final field = Variable(AstString(), 'name');
    expect(JavaFunctionSetter(field).build(),
        'public void setName(String name) { this.name = name; }\n');
  });
}
