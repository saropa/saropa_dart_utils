import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/list/list_nullable_string_sort_extensions.dart';

void main() {
  group('sortNullableStringListInPlace', () {
    group('spec sample cases', () {
      test('when list is empty', () {
        final List<String?> list = <String?>[];
        expect(sortNullableStringListInPlace(list), isTrue);
        expect(list, equals(<String>[]));
      });

      test('when list has one null element', () {
        final List<String?> list = <String?>[null];
        expect(sortNullableStringListInPlace(list), isTrue);
        expect(list, equals(<void>[null]));
      });

      test('when list has one non-null element', () {
        final List<String?> list = <String?>['test'];
        expect(sortNullableStringListInPlace(list), isTrue);
        expect(list, equals(<String>['test']));
      });

      test('when list has multiple identical elements', () {
        final List<String?> list = <String?>['test', 'test', 'test'];
        expect(sortNullableStringListInPlace(list), isTrue);
        expect(list, equals(<String>['test', 'test', 'test']));
      });

      test('when list has multiple distinct elements', () {
        final List<String?> list = <String?>['test2', 'test1', 'test3'];
        expect(sortNullableStringListInPlace(list), isTrue);
        expect(list, equals(<String>['test1', 'test2', 'test3']));
      });

      test('when list has null and non-null elements', () {
        final List<String?> list = <String?>['test2', null, 'test1'];
        expect(sortNullableStringListInPlace(list), isTrue);
        expect(list, equals(<String?>[null, 'test1', 'test2']));
      });

      test('when list has empty and non-empty strings', () {
        final List<String?> list = <String?>['test', ''];
        expect(sortNullableStringListInPlace(list), isTrue);
        expect(list, equals(<String>['', 'test']));
      });

      test('when list has large number of identical elements', () {
        final List<String?> list = List<String?>.filled(10_000, 'test');
        expect(sortNullableStringListInPlace(list), isTrue);
        expect(list, equals(List<String?>.filled(10_000, 'test')));
      });

      test('when list has large number of distinct elements', () {
        final List<String?> list = List<String?>.generate(10_000, (int i) => 'test$i');
        final List<String?> sortedList = List<String?>.of(list)..sort();
        expect(sortNullableStringListInPlace(list), isTrue);
        expect(list, equals(sortedList));
      });

      test('when list has large number of null elements', () {
        final List<String?> list = List<String?>.filled(10_000, null);
        expect(sortNullableStringListInPlace(list), isTrue);
        expect(list, equals(List<String?>.filled(10_000, null)));
      });
    });

    group('case-insensitivity', () {
      test('mixed case sorts ignoring case', () {
        // The comparator lowercases both sides, so 'B' (0x42) does not jump
        // ahead of 'a' (0x61) the way a raw case-sensitive compare would.
        final List<String?> list = <String?>['B', 'a', 'C'];
        expect(sortNullableStringListInPlace(list), isTrue);
        expect(list, equals(<String>['a', 'B', 'C']));
      });

      test("'a' and 'A' tie under lowercasing and both are retained", () {
        // Both lowercase to 'a' -> compare returns 0. A stable in-place sort
        // keeps BOTH elements (unlike a tree map, which would drop one on a
        // zero comparison). Length and contents must be preserved.
        final List<String?> list = <String?>['A', 'a'];
        expect(sortNullableStringListInPlace(list), isTrue);
        expect(list, hasLength(2));
        expect(list.toSet(), <String>{'a', 'A'});
      });
    });

    group('null and empty-string grouping', () {
      test('multiple nulls interleaved with values group first', () {
        // null collates as '' (the smallest comparison value), so every null
        // sinks to the front; the non-null values follow in lowercase order.
        final List<String?> list = <String?>[null, 'b', null, 'a'];
        expect(sortNullableStringListInPlace(list), isTrue);
        expect(list, equals(<String?>[null, null, 'a', 'b']));
      });

      test('empty string and null both collate as empty, both retained', () {
        // null -> '' and '' -> '' both compare equal (0); a stable sort keeps
        // both, and neither is dropped.
        final List<String?> list = <String?>['', null, 'x'];
        expect(sortNullableStringListInPlace(list), isTrue);
        expect(list, hasLength(3));
        // 'x' must sort last; the two empty-collating values lead.
        expect(list.last, 'x');
        expect(list.take(2).toSet(), <String?>{null, ''});
      });
    });

    group('Unicode and emoji (code-unit ordering, not locale-aware)', () {
      test('accented Latin sorts after ASCII by code unit', () {
        // String.compareTo is UTF-16 code-unit order, NOT locale collation:
        // 'é' (U+00E9) sorts AFTER 'z' (U+007A), so it is NOT grouped near 'e'.
        final List<String?> list = <String?>['é', 'e', 'z'];
        expect(sortNullableStringListInPlace(list), isTrue);
        expect(list, equals(<String>['e', 'z', 'é']));
      });

      test('emoji element does not throw and uses code-unit ordering', () {
        // 'a' (0x61) precedes the high surrogate of U+1F4A9.
        final List<String?> list = <String?>['\u{1F4A9}', 'a'];
        expect(sortNullableStringListInPlace(list), isTrue);
        expect(list, equals(<String>['a', '\u{1F4A9}']));
      });
    });

    group('return contract', () {
      test('always returns true for any String? input (defensive false path)', () {
        // String.compareTo cannot throw, so the false branch is unreachable
        // here; this asserts the documented always-true behavior for callers.
        expect(sortNullableStringListInPlace(<String?>['c', null, 'a']), isTrue);
      });
    });
  });
}
