import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/string/string_template_extensions.dart';

void main() {
  group('substituteTemplate', () {
    test('single placeholder', () {
      expect(
        'Hello {{name}}!'.substituteTemplate({'name': 'World'}),
        'Hello World!',
      );
    });
    test('missing key left unchanged', () {
      expect(
        '{{a}}-{{b}}'.substituteTemplate({'a': '1'}),
        '1-{{b}}',
      );
    });
    test('empty string', () {
      expect(''.substituteTemplate({'x': 'y'}), '');
    });
    test('empty map', () {
      expect('{{a}}'.substituteTemplate({}), '{{a}}');
    });
    test('multiple same key', () {
      expect(
        '{{x}} and {{x}}'.substituteTemplate({'x': 'ok'}),
        'ok and ok',
      );
    });
  });
}
