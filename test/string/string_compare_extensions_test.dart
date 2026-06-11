import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/string/string_compare_extensions.dart';

void main() {
  group('compareStringNullable', () {
    group('null handling', () {
      test('should return 0 when both are null', () {
        expect(null.compareStringNullable(null), 0);
      });

      test('should sort null before non-null by default', () {
        expect(null.compareStringNullable('a'), -1);
        expect('a'.compareStringNullable(null), 1);
      });

      test('should sort null after non-null when nullsLast is true', () {
        expect(null.compareStringNullable('a', nullsLast: true), 1);
        expect('a'.compareStringNullable(null, nullsLast: true), -1);
      });

      test('should return 0 for two nulls regardless of nullsLast', () {
        expect(null.compareStringNullable(null, nullsLast: true), 0);
      });
    });

    group('case-insensitive (default)', () {
      test('should treat differing case as equal', () {
        expect('Apple'.compareStringNullable('apple'), 0);
      });

      test('should order ignoring case', () {
        expect('apple'.compareStringNullable('Banana'), lessThan(0));
        expect('Banana'.compareStringNullable('apple'), greaterThan(0));
      });

      test('should return 0 for identical strings', () {
        expect('same'.compareStringNullable('same'), 0);
      });
    });

    group('case-sensitive', () {
      test('should order by code unit when caseSensitive is true', () {
        // 'B' (0x42) sorts before 'a' (0x61) in raw code-unit order.
        expect('apple'.compareStringNullable('Banana', caseSensitive: true), greaterThan(0));
      });

      test('should distinguish case', () {
        expect('Apple'.compareStringNullable('apple', caseSensitive: true), isNot(0));
      });
    });

    group('diacritics (code-unit ordering, not collation)', () {
      test('ASCII letters sort before accented Latin-1 letters', () {
        // 'é' is U+00E9, above every ASCII letter, so 'z' precedes 'é'.
        expect('z'.compareStringNullable('é'), lessThan(0));
      });
    });

    group('sorting a List<String?>', () {
      test('should place nulls first by default', () {
        final List<String?> list = <String?>['banana', null, 'Apple', null, 'cherry'];
        list.sort((String? a, String? b) => a.compareStringNullable(b));
        expect(list, <String?>[null, null, 'Apple', 'banana', 'cherry']);
      });

      test('should place nulls last when nullsLast is true', () {
        final List<String?> list = <String?>['banana', null, 'apple'];
        list.sort((String? a, String? b) => a.compareStringNullable(b, nullsLast: true));
        expect(list, <String?>['apple', 'banana', null]);
      });
    });
  });
}
