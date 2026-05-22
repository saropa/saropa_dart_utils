// ignore_for_file: saropa_lints/prefer_setup_teardown -- per-test arrange kept explicit for readability; a shared setUp would hide each test's inputs
import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/map/map_more_extensions.dart';

void main() {
  group('MapFromIterableExtension.toMapWith', () {
    // NOTE: toMapWith's K/V are extension-level type params (on
    // MapFromIterableExtension<T, K, V>), not method-level, so they cannot be
    // inferred from the Iterable<T> receiver and resolve to dynamic. The result
    // is therefore typed Map<dynamic, dynamic> at every call site; the values
    // themselves are still correct.
    test('builds a map from key and value selectors', () {
      final Map<dynamic, dynamic> result = <String>['a', 'bb', 'ccc'].toMapWith(
        (String s) => s.length,
        (String s) => s.toUpperCase(),
      );
      expect(result, <int, String>{1: 'A', 2: 'BB', 3: 'CCC'});
    });

    test('later elements overwrite earlier ones on key collision', () {
      final Map<dynamic, dynamic> result = <String>['a', 'x'].toMapWith(
        (String s) => 1,
        (String s) => s,
      );
      expect(result, <int, String>{1: 'x'});
    });

    test('empty iterable yields empty map', () {
      final Map<dynamic, dynamic> result = <String>[].toMapWith(
        (String s) => s.length,
        (String s) => s,
      );
      expect(result, <int, String>{});
    });
  });

  group('MapKeysValuesList', () {
    test('keysList returns keys in iteration order', () {
      expect(<String, int>{'a': 1, 'b': 2}.keysList, <String>['a', 'b']);
    });

    test('valuesList returns values in iteration order', () {
      expect(<String, int>{'a': 1, 'b': 2}.valuesList, <int>[1, 2]);
    });

    test('empty map yields empty key and value lists', () {
      expect(<String, int>{}.keysList, <String>[]);
      expect(<String, int>{}.valuesList, <int>[]);
    });
  });

  group('MapFindKey.findKeyByValue', () {
    test('returns the first key mapping to the value', () {
      expect(<String, int>{'a': 1, 'b': 2}.findKeyByValue(2), 'b');
    });

    test('returns null when no key maps to the value', () {
      expect(<String, int>{'a': 1}.findKeyByValue(99), isNull);
    });

    test('returns the first matching key on duplicate values', () {
      expect(<String, int>{'a': 1, 'b': 1}.findKeyByValue(1), 'a');
    });
  });

  group('MapRenameKey', () {
    group('renameKey', () {
      test('renames an existing key preserving the value', () {
        expect(
          <String, int>{'a': 1, 'b': 2}.renameKey('a', 'c'),
          <String, int>{'b': 2, 'c': 1},
        );
      });

      test('returns an unchanged copy when the old key is absent', () {
        expect(
          <String, int>{'a': 1}.renameKey('x', 'y'),
          <String, int>{'a': 1},
        );
      });

      test('does not mutate the original map', () {
        final Map<String, int> original = <String, int>{'a': 1};
        final Map<String, int> renamed = original.renameKey('a', 'b');
        expect(renamed, <String, int>{'b': 1});
        expect(original, <String, int>{'a': 1});
      });
    });

    group('renameKeys', () {
      test('renames multiple keys', () {
        expect(
          <String, int>{'a': 1, 'b': 2, 'c': 3}.renameKeys(<String, String>{'a': 'x', 'c': 'z'}),
          <String, int>{'b': 2, 'x': 1, 'z': 3},
        );
      });

      test('skips keys not present', () {
        expect(
          <String, int>{'a': 1}.renameKeys(<String, String>{'missing': 'new'}),
          <String, int>{'a': 1},
        );
      });
    });
  });

  group('MapEnsureKey.ensureKey', () {
    test('adds the key when absent', () {
      final Map<String, int> map = <String, int>{};
      map.ensureKey('a', () => 5);
      expect(map, <String, int>{'a': 5});
    });

    test('leaves an existing key untouched', () {
      final Map<String, int> map = <String, int>{'a': 1};
      map.ensureKey('a', () => 99);
      expect(map, <String, int>{'a': 1});
    });
  });

  group('MapUpsert.upsert', () {
    test('inserts when the key is absent', () {
      final Map<String, int> map = <String, int>{};
      map.upsert('a', () => 1, (int existing) => existing + 1);
      expect(map, <String, int>{'a': 1});
    });

    test('updates when the key is present', () {
      final Map<String, int> map = <String, int>{'a': 10};
      map.upsert('a', () => 1, (int existing) => existing + 5);
      expect(map, <String, int>{'a': 15});
    });
  });
}
