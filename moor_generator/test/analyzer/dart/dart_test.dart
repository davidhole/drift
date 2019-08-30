import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:moor_generator/src/analyzer/dart/parser.dart';
import 'package:test/test.dart';

import '../../utils/test_backend.dart';

void main() {
  test('return expression of methods', () async {
    final backend = TestBackend({
      'test_lib|main.dart': r'''
      class Test {
        String get getter => 'foo';
        String function() => 'bar';
        String invalid() {
         return 'baz';
        }
      }
    '''
    });

    final backendTask = backend.startTask('test_lib|main.dart');
    final dartTask = await backend.session.startDartTask(backendTask);
    final parser = MoorDartParser(dartTask);

    Future<MethodDeclaration> _loadDeclaration(Element element) async {
      final declaration = await parser.loadElementDeclaration(element);
      return declaration.node as MethodDeclaration;
    }

    void _verifyReturnExpressionMatches(Element element, String source) async {
      final node = await _loadDeclaration(element);
      expect(parser.returnExpressionOfMethod(node).toSource(), source);
    }

    final testClass = dartTask.library.getType('Test');

    _verifyReturnExpressionMatches(testClass.getGetter('getter'), "'foo'");
    _verifyReturnExpressionMatches(testClass.getMethod('function'), "'bar'");

    final invalidDecl = await _loadDeclaration(testClass.getMethod('invalid'));
    expect(parser.returnExpressionOfMethod(invalidDecl), isNull);
    expect(dartTask.errors.errors, isNotEmpty);

    backend.finish();
  });
}
