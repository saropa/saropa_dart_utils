import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/map/map_default_extensions.dart';

void main() {
  group('MapDefaultExtensions', () {
    test('returns the default for a missing key', () {
      final MapDefaultExtensions<String, int> m =
          MapDefaultExtensions<String, int>(<String, int>{'a': 1}, 0);
      expect(m['a'], 1);
      expect(m['missing'], 0);
    });

    test('addEntries writes through to the wrapped map', () {
      final MapDefaultExtensions<String, int> m =
          MapDefaultExtensions<String, int>(<String, int>{}, 0);
      m.addEntries(<MapEntry<String, int>>[const MapEntry<String, int>('b', 2)]);
      expect(m['b'], 2);
    });

    test('removeWhere drops matching entries', () {
      final MapDefaultExtensions<String, int> m =
          MapDefaultExtensions<String, int>(<String, int>{'a': 1, 'b': 2, 'c': 3}, 0);
      m.removeWhere((String k, int v) => v.isEven);
      expect(m.keys.toSet(), <String>{'a', 'c'});
    });

    test('updateAll transforms every value', () {
      final MapDefaultExtensions<String, int> m =
          MapDefaultExtensions<String, int>(<String, int>{'a': 1, 'b': 2}, 0);
      m.updateAll((String k, int v) => v * 10);
      expect(m['a'], 10);
      expect(m['b'], 20);
    });
  });
}
