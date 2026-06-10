import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/parsing/json_pretty_print_utils.dart';

void main() {
  group('prettyPrintJson', () {
    test('indents with two spaces by default', () {
      expect(
        prettyPrintJson(<String, Object?>{'a': 1}),
        '{\n  "a": 1\n}',
      );
    });

    test('sorts object keys recursively when sortKeys is true', () {
      expect(
        prettyPrintJson(<String, Object?>{'b': 1, 'a': 2}, sortKeys: true),
        '{\n  "a": 2,\n  "b": 1\n}',
      );
    });

    test('preserves insertion order when sortKeys is false', () {
      expect(
        prettyPrintJson(<String, Object?>{'b': 1, 'a': 2}),
        '{\n  "b": 1,\n  "a": 2\n}',
      );
    });

    test('honors a custom indent width', () {
      expect(
        prettyPrintJson(<String, Object?>{'a': 1}, indent: 4),
        '{\n    "a": 1\n}',
      );
    });

    test('indent <= 0 produces compact single-line output', () {
      expect(prettyPrintJson(<String, Object?>{'a': 1, 'b': 2}, indent: 0), '{"a":1,"b":2}');
    });

    test('sorts nested object keys', () {
      final String out = prettyPrintJson(
        <String, Object?>{
          'z': <String, Object?>{'y': 1, 'x': 2},
        },
        indent: 0,
        sortKeys: true,
      );
      expect(out, '{"z":{"x":2,"y":1}}');
    });

    test('handles lists and scalars', () {
      expect(prettyPrintJson(<Object?>[1, 'a', true], indent: 0), '[1,"a",true]');
    });
  });
}
