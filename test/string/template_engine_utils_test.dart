import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/string/template_engine_utils.dart';

void main() {
  // cspell: disable
  group('substituteTemplate', () {
    test('should replace a single placeholder', () {
      expect(substituteTemplate('Hello {{name}}', <String, String>{'name': 'Sam'}), 'Hello Sam');
    });

    test('should replace multiple placeholders', () {
      expect(
        substituteTemplate('{{a}}-{{b}}', <String, String>{'a': '1', 'b': '2'}),
        '1-2',
      );
    });

    test('should substitute missing keys with empty string', () {
      expect(substituteTemplate('Hi {{missing}}!', <String, String>{}), 'Hi !');
    });

    test('should leave text without placeholders unchanged', () {
      expect(substituteTemplate('plain text', <String, String>{'x': 'y'}), 'plain text');
    });

    test('should ignore non-word placeholder syntax', () {
      // {{ a }} has spaces, so it does not match the \w+ placeholder pattern.
      expect(substituteTemplate('{{ a }}', <String, String>{'a': 'X'}), '{{ a }}');
    });

    test('should return empty string for empty template', () {
      expect(substituteTemplate('', <String, String>{'a': 'b'}), '');
    });

    test('should substitute the same key multiple times', () {
      expect(
        substituteTemplate('{{x}}{{x}}', <String, String>{'x': 'ab'}),
        'abab',
      );
    });
  });
}
