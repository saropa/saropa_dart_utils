import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/parsing/nested_query_parser_utils.dart';

void main() {
  group('parseNestedQuery', () {
    test('flat key value', () {
      expect(parseNestedQuery('a=1'), <String, Object?>{'a': '1'});
    });

    test('scalar/nested collision does not leak the leaf to the root', () {
      // `a=1` then `a[b]=2`: cannot nest under the scalar `a`, so the second
      // pair is skipped rather than writing a stray `b` at the root level.
      expect(parseNestedQuery('a=1&a[b]=2'), <String, Object?>{'a': '1'});
    });

    test('multiple flat pairs', () {
      expect(parseNestedQuery('a=1&b=2'), <String, Object?>{'a': '1', 'b': '2'});
    });

    test('nested bracket key builds nested map', () {
      expect(
        parseNestedQuery('a[b]=1'),
        <String, Object?>{
          'a': <String, Object?>{'b': '1'},
        },
      );
    });

    test('deeply nested bracket key', () {
      expect(
        parseNestedQuery('a[b][c]=1'),
        <String, Object?>{
          'a': <String, Object?>{
            'b': <String, Object?>{'c': '1'},
          },
        },
      );
    });

    test('empty string yields empty map', () {
      expect(parseNestedQuery(''), <String, Object?>{});
    });

    test('pair without equals is skipped', () {
      expect(parseNestedQuery('a=1&noequals&b=2'), <String, Object?>{'a': '1', 'b': '2'});
    });

    test('url-encoded value decoded', () {
      expect(parseNestedQuery('a=hello%20world'), <String, Object?>{'a': 'hello world'});
    });

    test('url-encoded key decoded', () {
      expect(parseNestedQuery('a%20b=1'), <String, Object?>{'a b': '1'});
    });

    test('empty value preserved', () {
      expect(parseNestedQuery('a='), <String, Object?>{'a': ''});
    });

    test('value containing equals keeps remainder', () {
      expect(parseNestedQuery('a=1=2'), <String, Object?>{'a': '1=2'});
    });
  });
}
