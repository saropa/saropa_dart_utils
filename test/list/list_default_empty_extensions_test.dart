// ignore_for_file: saropa_lints/prefer_setup_teardown -- per-test arrange kept explicit for readability; a shared setUp would hide each test's inputs
import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/list/list_default_empty_extensions.dart';

void main() {
  group('ListDefaultEmptyExtension.orEmpty', () {
    test('returns empty list for null', () {
      const List<int>? list = null;
      expect(list.orEmpty(), <int>[]);
    });

    test('returns the same contents for a non-null list', () {
      final List<int> list = <int>[1, 2, 3];
      expect(list.orEmpty(), <int>[1, 2, 3]);
    });

    test('returns the same instance for a non-null list', () {
      final List<int> list = <int>[1, 2, 3];
      expect(list.orEmpty(), same(list));
    });
  });

  group('MapDefaultEmptyExtension.orEmpty', () {
    test('returns empty map for null', () {
      const Map<String, int>? map = null;
      expect(map.orEmpty(), <String, int>{});
    });

    test('returns the same contents for a non-null map', () {
      final Map<String, int> map = <String, int>{'a': 1};
      expect(map.orEmpty(), <String, int>{'a': 1});
    });
  });

  group('ListSecondThirdExtension', () {
    group('secondOrNull', () {
      test('returns element at index 1', () {
        expect(<int>[1, 2, 3].secondOrNull, 2);
      });

      test('returns null for a single-element list', () {
        expect(<int>[1].secondOrNull, isNull);
      });

      test('returns null for an empty list', () {
        expect(<int>[].secondOrNull, isNull);
      });
    });

    group('thirdOrNull', () {
      test('returns element at index 2', () {
        expect(<int>[1, 2, 3].thirdOrNull, 3);
      });

      test('returns null for a two-element list', () {
        expect(<int>[1, 2].thirdOrNull, isNull);
      });

      test('returns null for an empty list', () {
        expect(<int>[].thirdOrNull, isNull);
      });
    });
  });
}
